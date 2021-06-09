pragma solidity ^0.5.0;

import "contracts/Libraries/base64_decoding/Base64.sol";
import "contracts/Libraries/Json_parsing/JsmnSolLib.sol";
import "contracts/Libraries/base64_decoding/Strings.sol";
import "contracts/Libraries/base64_decoding/SolRsaVerify.sol";
import "contracts/Libraries/Signature_Verification/SignVerify.sol";





contract Proxy {
   
    using StringUtils for *;
    using SolRsaVerify for *;
    using SignVerify for *;
   
   
    address public agent;
    string public did="";
    string public didMethod= ""; // We initialize the didMethod to an empty string
    string public didID= ""; // We initialize the didID to an empty string
    string public payload = ""; // We initialize the payload to an empty string
    string public publicKey = ""; // We initialize the variable that will store the pubKey
    string public didDoc=""; // Variable that will store the didDoc
    bytes32 public nonce;
    bool public proxy; // Proxy function bool
    bool public ack;
    uint public counter;
    
    
    
    // We set the mapping and the struct
    struct User{
        string publicKey;
        string did;
        string didID;
        string didMethod;
        string payload;
        string didDoc;
        bytes32 nonce;
        bytes signature;
        string typeOfKey;
        uint method;
    }
    mapping (address => User) users;
    address[] public userAdress;


    
    modifier OnlyAgent(){ // Modifier which permits the proxy verification
        require(msg.sender == agent);
        _;
    }
   
    
    function proxy1 (string memory _did,string memory _payload) public returns (bool) {
        
        // We set the agent to the one sending the transaction to the proxy
        
        counter = setAgent(counter);
        bool firstCheck;
        bool _proxy;
        
        // We slice the did in order to get the did, didMethod and the didID
        
        StringUtils.slice memory didSlice = _did.toSlice();  
        StringUtils.slice memory needle = ":".toSlice(); 
        users[agent].did = didSlice.split(needle).toString();
        users[agent].didMethod = didSlice.split(needle).toString();
        users[agent].didID = didSlice.split(needle).toString(); 
        users[agent].payload = _payload;

        _proxy = false;

        
       
        
        // We check for the first requirement
        
        string memory EOA_string = toString_1(agent);
        StringUtils.slice memory didID_slice = didID.toSlice();  

        
        StringUtils.slice memory EOA_slice  = EOA_string.toSlice();  
        
        
        
        firstCheck = StringUtils.equals(EOA_slice, didID_slice);
        // require(firstCheck == true); Se agregara cuando tengamos el par de claves
        
        generateNonce(counter);

        _proxy = true;
        return _proxy;
    }
    
    function setAgent (uint _counter) public returns (uint){
        agent = msg.sender;
        _counter++;
        return _counter;
    }
    
    
    // Function to set the User in the mapping and in the struct
    function setUser(address _address, string memory _publicKey,string memory _did, string memory _didMethod, string memory _payload, string memory _didDoc, bytes32 _nonce) public OnlyAgent{
        User storage user = users[_address];
        
        user.publicKey = _publicKey;
        user.did = _did;
        user.didMethod = _didMethod;
        user.payload = _payload;
        user.didDoc = _didDoc;
        user.nonce = _nonce;
        userAdress.push(_address) -1;
    }
    
    // Function to get the info about the user in the mapping and in the struct
    function getUser() view public OnlyAgent returns (string memory,string memory,string memory,string memory){
        return (users[agent].did, users[agent].didMethod, users[agent].didID, users[agent].payload);
    }
    
    function getUser2() view public OnlyAgent returns (string memory, string memory, bytes32, string memory, uint) {
        return (users[agent].publicKey, users[agent].didDoc,users[agent].nonce,users[agent].typeOfKey,users[agent].method);
    }
    
    function updatePubKey(string memory _publicKey) public  OnlyAgent returns (bool){
        users[agent].publicKey = _publicKey;
    }
    
    function getPublicKey(address _address) public view OnlyAgent returns(string memory){
        string memory _pubKey="";
        _pubKey = users[_address].publicKey;
        StringUtils.slice memory _pubKeySlice = _pubKey.toSlice(); 
        require (StringUtils.empty(_pubKeySlice)== false);
        return (_pubKey);
    }
    
    function getDidDoc_Struct(address _address) public view OnlyAgent returns(string memory){
        string memory _didDoc="";
        _didDoc = users[_address].didDoc;
        StringUtils.slice memory  _didDocSlice = _didDoc.toSlice(); 
        require (StringUtils.empty(_didDocSlice)== false);
        return (_didDoc);
    }
    
    function getDid_Struct(address _address) public view OnlyAgent returns(string memory){
        string memory _did="";
        _did = users[_address].did;
        StringUtils.slice memory  _didSlice = _did.toSlice(); 
        require (StringUtils.empty(_didSlice)== false);
        return (_did);
    }
    
    function setDidDoc_Struct(address _address, string memory _didDoc) public  OnlyAgent returns (bool) {
         users[_address].didDoc = _didDoc;
    }
    
    function setDid(address _address, string memory _did) public OnlyAgent returns (bool) {
         users[_address].did = _did;
    }
    
    
    function toString_1(address addr) pure public returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
          b[i] = byte(uint8(uint(addr) / (2**(8*(19 - i)))));
        }
        return string(b);
  }
    function generateNonce(uint _counter) public OnlyAgent{
        users[agent].nonce = keccak256(abi.encodePacked(agent, _counter));    
    }
    
}
    
    
    
   



contract SignatureVerifier is Proxy{
    
    bool verifiedSignature = false;
    bytes public signature="";
    string public typeOfKey = "";
    string public method_Str = "";
    StringUtils.slice  method_Slice;
    
    uint setIdentity_uint = 1;
    uint getIdentity_uint = 2;
    uint setdidDoc_uint = 3;
    uint getdidDoc_uint = 4;
    uint method_uint;
    

    
    // We define the variable in order to implement the method checking modifier
    
    /* StringUtils.slice  methodSlice = didMethod.toSlice();  
    string  meth_getDidDoc = "getDidDoc";
    StringUtils.slice  meth_getDidDoc_Slice = meth_getDidDoc.toSlice();  
    
    string  meth_setDidDoc = "setDidDoc";
    StringUtils.slice  meth_setDidDoc_Slice = meth_setDidDoc.toSlice();  
    
    string  meth_getEntity = "getEntity";
    StringUtils.slice  meth_getEntity_Slice = meth_getEntity.toSlice();  
    
    string  meth_setEntity = "setEntity";
    StringUtils.slice  meth_setEntity_Slice = meth_setEntity.toSlice(); 
    */
    
    
        
    function verifySignature (string memory _message, bytes memory _signature, bytes32 _nonce) public OnlyAgent returns (bool) {
      
     
        require(SignVerify.verify(agent, _message,  _nonce, _signature) == true);
        verifiedSignature = true;
        return verifiedSignature;
        
    }
    
    //function parsePayload (string memory payload) public OnlyAgent IsSet {
        
    //}
    
    function parseParam () public OnlyAgent  {
        
        string memory _payload = users[agent].payload;
        StringUtils.slice memory payloadSlice = _payload.toSlice();  
        StringUtils.slice memory needle = ".".toSlice(); 
        method_Slice = payloadSlice.split(needle);
        method_Str = method_Slice.toString();
        method_uint = parseInt(method_Str);
        users[agent].method = method_uint;
        
        if (method_uint == setIdentity_uint){ // SET IDENTITY METHOD
            
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            updatePubKey(publicKey);
        }
        
        if (method_uint == getIdentity_uint){ // GET IDENTITY METHOD
        
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
            updatePubKey(publicKey);
            users[agent].signature=signature;
            users[agent].typeOfKey = typeOfKey;
        }
        
        if (method_uint == setdidDoc_uint){ // SET DIDDOC METHOD
        
            did = payloadSlice.split(needle).toString();
            didDoc = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
            updatePubKey(publicKey);
            users[agent].signature = signature;
            users[agent].typeOfKey = typeOfKey;
            users[agent].didDoc = didDoc;
        }
        
        if (method_uint == getdidDoc_uint){  // GET DIDDOC METHOD
            
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
            updatePubKey(publicKey);
            users[agent].signature = signature;
            users[agent].typeOfKey = typeOfKey;
        }
        
    }
    
    modifier isGetDidDoc (){
        //First we convert strings to slices

        require(method_uint == getdidDoc_uint);
        _;
    }
    
    modifier isSetDidDoc (){
        require(method_uint == setdidDoc_uint);
        _;
    }
    
    modifier isSetEntity(){
        require(method_uint == setIdentity_uint);
        _;
    }
    
    modifier isGetEntity(){
        require(getIdentity_uint == method_uint);
        _;
    }
    
    function bytesArrayToString(bytes memory _bytes) public pure returns (string memory) {
        return string(_bytes);
    } //

    function stringToBytesArray(string memory str) public pure returns (bytes memory){
        return bytes(str);
    } //
    
    function parseInt(string memory _value)
        public
        pure
        returns (uint _ret) {
        bytes memory _bytesValue = bytes(_value);
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(uint8(_bytesValue[i]) >= 48 && uint8(_bytesValue[i]) <= 57);
            _ret += (uint8(_bytesValue[i]) - 48)*j;
            j*=10;
        }
    }
    
}

//contract IdentityRegistry is SignatureVerifier {
    
  //  bool createdIdentity = false;
    // bool option;


    
    //function setEntity() public OnlyAgent isSetEntity returns(bool){
    //    setUser(agent, publicKey , did , didMethod , payload, didDoc, nonce);
    //    createdIdentity = true;
    //    return createdIdentity;
    //}
    

    
//}


contract EntityManagement is SignatureVerifier {
    
    bool createdIdentity = false;
    bool option;
    string public _publicKey;


    
    function setEntity() public OnlyAgent isSetEntity returns(bool){
        setUser(agent, publicKey , did , didMethod , payload, didDoc, nonce);
        createdIdentity = true;
        return createdIdentity;
    }
    
    
    function getEntity(address _address) public OnlyAgent isGetEntity returns (string memory){
        _publicKey = users[_address].publicKey;
        bytes32 sha_256 = sha256(abi.encodePacked(_publicKey));
        string memory sha_256_string;
        sha_256_string = bytes32ToString(sha_256);
        
        StringUtils.slice memory compr1 = users[agent].didID.toSlice();
        StringUtils.slice memory compr2 = sha_256_string.toSlice();
        
        require (StringUtils.equals(compr1,compr2) == true);
        return _publicKey;
    }
    
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
      function getDidDoc() public OnlyAgent isGetDidDoc view returns (string memory){
        return getDidDoc_Struct(agent);
    }
}
    /*function setDidDoc(address _address) public OnlyAgent isSetDidDoc returns (bool){
        
        //concat(slice memory self, slice memory other)
        
        string memory _diddoc = users[_address].didDoc;
        string memory _did = users[_address].did;
        
        _diddoc = "{ \"id\" : \"";
        StringUtils.slice memory part1 = _diddoc.toSlice();
        StringUtils.slice memory part2 = _did.toSlice();

        string memory result = StringUtils.concat(part1,part2);
        StringUtils.slice memory resultSlice = result.toSlice();
        
        string memory part3 = "\", \"authentication\": [{ \"id\": ";
        StringUtils.slice memory part3_Slice = part3.toSlice();
        result = StringUtils.concat(resultSlice,part3_Slice);
        resultSlice = result.toSlice();
        
        result = StringUtils.concat(resultSlice,part2);
        resultSlice = result.toSlice();

        string memory part4 = "\", \"type\": \"";
        StringUtils.slice memory part4_Slice = part4.toSlice();

        result = StringUtils.concat(resultSlice,part4_Slice);
        resultSlice = result.toSlice();

        
        StringUtils.slice memory typeOfKey_Slice = typeOfKey.toSlice();
        
        result = StringUtils.concat(resultSlice,typeOfKey_Slice);
        resultSlice = result.toSlice();
        
        string memory part5 = "\", \"controller\": \"";
        StringUtils.slice memory part5_Slice = part5.toSlice();
        
        result = StringUtils.concat(resultSlice,part5_Slice);
        resultSlice = result.toSlice();
        
        
        result = StringUtils.concat(resultSlice,part2);
        resultSlice = result.toSlice();

        string memory part6 = "\", \"publicKey\": \"";
        StringUtils.slice memory part6_Slice = part6.toSlice();
        
        result = StringUtils.concat(resultSlice,part6_Slice);
        resultSlice = result.toSlice();
        
        StringUtils.slice memory  _publicKeySlice = publicKey.toSlice();
       
        result = StringUtils.concat(resultSlice,_publicKeySlice);
        resultSlice = result.toSlice();
        
        string memory part7 = "\" }] }";
        StringUtils.slice memory part7_Slice = part7.toSlice();
        result = StringUtils.concat(resultSlice,part7_Slice);
        
        setDidDoc_Struct(agent,result);

    }
}
*/
//contract Main is EntityManagement {
  //      bool requerimientos;
        
    //    function flujo() public {
            
      //      proxy = proxy1(_did,_payload);
        //    require(proxy == true);
          //  parseParam();
        //    requerimientos = verifySignature (_payload, signature, nonce);
//            require (requerimientos == true);
            
  //          setEntity();
    //        getEntity(agent);
      //      setDidDoc(agent);
        //    getDidDoc();
        //}
//}



