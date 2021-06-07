pragma solidity ^0.5.0;

import "contracts/Libraries/base64_decoding/Base64.sol";
import "contracts/Libraries/Json_parsing/JsmnSolLib.sol";
import "contracts/Libraries/base64_decoding/Strings.sol";
import "contracts/Libraries/base64_decoding/SolRsaVerify.sol";
import "contracts/Libraries/Signature_Verification/SignVerify.sol";





contract Proxy {
   
    address agent;
    string did="";
    string didMethod= ""; // We initialize the didMethod to an empty string
    string didID= ""; // We initialize the didID to an empty string
    string payload = ""; // We initialize the payload to an empty string
    string publicKey = "";
    string didDoc="";
    bool _proxy;
    using StringUtils for *;
    using SolRsaVerify for *;
    using SignVerify for *;
    bool ack;
    // We set the mapping and the struct
    struct User{
        string publicKey;
        string did;
        string didMethod;
        string payload;
        string didDoc;
    }
    mapping (address => User) users;
    address[] public userAdress;


    
    modifier OnlyAgent(){ // Modifier which permits the proxy verification
        require(msg.sender == agent);
        _;
    }
   
    
    function proxy (string memory _did,string memory _payload) public returns (bool) {
        
        // We set the agent to the one sending the transaction to the proxy
        
        setAgent(agent);
        bool firstCheck;
        
        // We slice the did in order to get the did, didMethod and the didID
        
        StringUtils.slice memory didSlice = _did.toSlice();  
        StringUtils.slice memory needle = ":".toSlice(); 
        did = didSlice.split(needle).toString();
        didMethod = didSlice.split(needle).toString();
        didID = didSlice.split(needle).toString(); 
        
        // parts[i] = s.split(delim).toString();                               

        _proxy = false;
        address EOA = msg.sender;

        
       
        
        // We check for the first requirement
        
        string memory EOA_string = toString_1(EOA);
        StringUtils.slice memory didID_slice = didID.toSlice();  

        
        StringUtils.slice memory EOA_slice  = EOA_string.toSlice();  
        
        
        
        firstCheck = StringUtils.equals(EOA_slice, didID_slice);
        require(firstCheck == true);
        
        // We set the mapping of the user who has just logged in
        setUser(agent, publicKey,_did,didMethod,_payload);

        _proxy = true;
        return _proxy;
    }
    
    function setAgent (address _agent) public {
        _agent = msg.sender;
    }
    
    // Function to set the User in the mapping and in the struct
    function setUser(address _address, string memory _publicKey,string memory _did, string memory _didMethod, string memory _payload) public OnlyAgent{
        User storage user = users[_address];
        
        user.publicKey = _publicKey;
        user.did = _did;
        user.didMethod = _didMethod;
        user.payload = _payload;
        userAdress.push(_address) -1;
    }
    
    // Function to get the info about the user in the mapping and in the struct
    function getUser(address _address) view public OnlyAgent returns (string memory,string memory,string memory,string memory){
        return (users[_address].publicKey, users[_address].did, users[_address].didMethod, users[_address].payload);
    }
    
    function updatePubKey(address _address,string memory _publicKey) public OnlyAgent returns (bool){
        users[_address].publicKey = _publicKey;
    }
    
    function getPublicKey(address _address) public OnlyAgent returns(string memory){
        string memory _pubKey="";
        _pubKey = users[_address].publicKey;
        StringUtils.slice memory _pubKeySlice = _pubKey.toSlice(); 
        require (StringUtils.empty(_pubKeySlice)== false);
        return (_pubKey);
    }
    
    function getDidDoc_Struct(address _address) public OnlyAgent returns(string memory){
        string memory _didDoc="";
        _didDoc = users[_address].didDoc;
        StringUtils.slice memory  _didDocSlice = _didDoc.toSlice(); 
        require (StringUtils.empty(_didDocSlice)== false);
        return (_didDoc);
    }
    
    function getDid_Struct(address _address) public OnlyAgent returns(string memory){
        string memory _did="";
        _did = users[_address].did;
        StringUtils.slice memory  _didSlice = _did.toSlice(); 
        require (StringUtils.empty(_didSlice)== false);
        return (_did);
    }
    
    function setDidDoc_Struct(address _address, string memory _didDoc) public OnlyAgent returns (bool) {
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
    function generateNonce(uint _counter) public OnlyAgent returns (bytes32){
        return keccak256(abi.encodePacked(agent, _counter));    
    }
    
}
    
    
    
   

contract IdentityRegistry is Proxy {
    
    bool createdIdentity;
    bool option;
    string public _publicKey;
    string typeOfKey;

    
    function setIdentity() public OnlyAgent{
        option = true; // We just use this function to specify the option. The process of setting the identity will be handled in the SignatureVerifier
    }
    
    function getIdentity() public OnlyAgent{
        option = false;  // We just use this function to specify the option. The process of setting the identity will be handled in the SignatureVerifier.
    }
    
    modifier IsSet(){ // Modifier which permits the proxy verification
        require(option == true);
        _;
    }
    modifier IsGet(){ // Modifier which permits the proxy verification
        require(option == false);
        _;
    }

    
}

contract SignatureVerifier is IdentityRegistry{
    
    bool verifiedSignature;
    string publicKey;
    string  method="";
    bytes signature="";
    
    // We define the variable in order to implement the method checking modifier
    
    StringUtils.slice  methodSlice = method.toSlice();  
    string  meth_getDidDoc = "getDidDoc";
    StringUtils.slice  meth_getDidDoc_Slice = meth_getDidDoc.toSlice();  
    
    string  meth_setDidDoc = "setDidDoc";
    StringUtils.slice  meth_setDidDoc_Slice = meth_setDidDoc.toSlice();  
    
    string  meth_getEntity = "getEntity";
    StringUtils.slice  meth_getEntity_Slice = meth_getEntity.toSlice();  
    
    string  meth_setEntity = "setEntity";
    StringUtils.slice  meth_setEntity_Slice = meth_setEntity.toSlice();  
    
    
        
    function verifySignature (string memory _message, bytes memory _signature, bytes32 _nonce) public OnlyAgent {
      
     address _signer = msg.sender;
     require(SignVerify.verify(_signer, _message,  _nonce, _signature) == true);
        
        
    }
    
    //function parsePayload (string memory payload) public OnlyAgent IsSet {
        
    //}
    
    function parseParam (string memory _payload) public OnlyAgent IsSet {
        
        StringUtils.slice memory payloadSlice = _payload.toSlice();  
        StringUtils.slice memory needle = ".".toSlice(); 
        StringUtils.slice memory  method_Slice = payloadSlice.split(needle);
        
        if (StringUtils.equals(method_Slice,meth_setEntity_Slice)){ // SET IDENTITY METHOD
        
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.equals(method_Slice,meth_getEntity_Slice)){ // GET IDENTITY METHOD
        
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.equals(method_Slice,meth_setDidDoc_Slice)){ // SET DIDDOC METHOD
        
            did = payloadSlice.split(needle).toString();
            didDoc = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.equals(method_Slice,meth_getDidDoc_Slice)){  // GET DIDDOC METHOD
            
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
            
            
        }
        
        
        
        didMethod = payloadSlice.split(needle).toString();
        didID = payloadSlice.split(needle).toString(); 
    }
    
    modifier isGetDidDoc (){
        //First we convert strings to slices

    
        require(StringUtils.equals(meth_getDidDoc_Slice,methodSlice));
        _;
    }
    
    modifier isSetDidDoc (){
        require(StringUtils.equals(meth_setDidDoc_Slice,methodSlice) == true);
        _;
    }
    
    modifier isSetEntity(){
        require(StringUtils.equals(meth_setEntity_Slice,methodSlice) == true);
        _;
    }
    
    modifier isGetEntity(){
        require(StringUtils.equals(meth_getEntity_Slice,methodSlice) == true);
        _;
    }
    
    function bytesArrayToString(bytes memory _bytes) public pure returns (string memory) {
        return string(_bytes);
    } //

    function stringToBytesArray(string memory str) public pure returns (bytes memory){
        return bytes(str);
    } //

    
}

contract EntityManagement is SignatureVerifier {
    
    function getEntity(string memory _did) public OnlyAgent isGetEntity returns (bool){
        
        
    }
    
    function setEntity(string memory _did, string memory _publicKey) public OnlyAgent isSetEntity returns (bool) {
        
        
    }
    
}

contract EntityDocument is SignatureVerifier {
    
    function getDidDoc() public OnlyAgent isGetDidDoc returns (string memory){
        return getDidDoc_Struct(agent);
    }
    
    function setDidDoc(string memory _did, string memory _diddoc) public OnlyAgent isSetDidDoc returns (bool){
        
        //concat(slice memory self, slice memory other)
        
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

// Extra functions


