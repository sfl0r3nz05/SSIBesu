pragma solidity ^0.5.0;

import "contracts/Libraries/base64_decoding/Base64.sol";
import "contracts/Libraries/Json_parsing/JsmnSolLib.sol";
import "contracts/Libraries/base64_decoding/Strings.sol";
import "contracts/Libraries/base64_decoding/SolRsaVerify.sol";
import "contracts/Libraries/Signature_Verification/SignVerify.sol";
import "contracts/Libraries/didDoc_Creation/didDoc_create.sol";





contract Proxy {
   
    using StringUtils for *;
    using SolRsaVerify for *;
    using SignVerify for *;
    using didDoc_Creation  for *;
   
    address  agent;
    string  did="";
    string  did1="";
    string  didMethod= ""; // We initialize the didMethod to an empty string
    string  didID= ""; // We initialize the didID to an empty string
    string  payload = ""; // We initialize the payload to an empty string
    string  publicKey = ""; // We initialize the variable that will store the pubKey
    string  didDoc=""; // Variable that will store the didDoc
    bytes32  nonce;
    bool  proxy; // Proxy function bool
    bool  ack;
    uint  counter;
    
    
    
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
        string method;
    }
    mapping (address => User) users;
    // address[] public userAdress;


    
    modifier OnlyAgent(){ // Modifier which permits the proxy verification
        require(msg.sender == agent);
        _;
    }
   
    
    function proxy1 (string memory _did,string memory _payload) public returns (bool) {
        
        // We set the agent to the one sending the transaction to the proxy
        counter = setAgent(counter);
        bool firstCheck;
        bool _proxy;
        did = _did;
        
        // We slice the did in order to get the did, didMethod and the didID
        
        StringUtils.slice memory didSlice = _did.toSlice();  
        StringUtils.slice memory needle = ":".toSlice(); 
        did1 = didSlice.split(needle).toString();
        didMethod = didSlice.split(needle).toString();
        didID = didSlice.split(needle).toString(); 
        payload = _payload;

        _proxy = false;

        setEntry(did,payload);
       
        
        // We check for the first requirement
        
       // string memory EOA_string = StringUtils.toString_1(agent);
        //StringUtils.slice memory didID_slice = didID.toSlice();  

        
    //    StringUtils.slice memory EOA_slice  = EOA_string.toSlice();  
        
        
        
        //firstCheck = StringUtils.equals(EOA_slice, didID_slice);
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
    
    function setEntry (string memory _did, string memory _payload) OnlyAgent public {
        users[agent].payload = _payload;
        users[agent].did = _did;
    }
    
    // Function to set the User in the mapping and in the struct
    function setUser(string memory _publicKey,string memory _did,string memory _didID, string memory _didMethod, string memory _payload, string memory _didDoc, bytes32 _nonce, bytes memory _signature, string memory _typeOfKey, string memory _method) public OnlyAgent{

        
        users[agent].publicKey = _publicKey;
        users[agent].did = _did;
        users[agent].didID = _didID;
        users[agent].didMethod = _didMethod;
        users[agent].payload = _payload;
        users[agent].didDoc = _didDoc;
        users[agent].nonce = _nonce;
        users[agent].signature = _signature;
        users[agent].typeOfKey = _typeOfKey;
        users[agent].method = _method;
    }
    
    // Function to get the info about the user in the mapping and in the struct
    function getUser() view public OnlyAgent returns (string memory,string memory,string memory,string memory){
        return (users[agent].did, users[agent].didMethod, users[agent].didID, users[agent].payload);
    }
    
    function getUser2() view public OnlyAgent returns (string memory, string memory, bytes32, string memory, string memory, bytes memory) {
        return (users[agent].publicKey, users[agent].didDoc,users[agent].nonce,users[agent].typeOfKey,users[agent].method,users[agent].signature);
    }
    
    function getDidDoc_Struct(address _address) public view OnlyAgent returns(string memory){

        return (users[agent].didDoc);
    }
    
    
    function setDidDoc_Struct(string memory _didDoc) public  OnlyAgent returns (bool) {
         users[agent].didDoc = _didDoc;
    }


    function generateNonce(uint _counter) public OnlyAgent{
        nonce = keccak256(abi.encodePacked(agent, _counter));    
    }
    
}

contract SignatureVerifier is Proxy{
    
    bool verifiedSignature = false;
    bytes signature="";
    string public typeOfKey = "";
    string public method_Str = "";
    StringUtils.slice  method_Slice;
    
    bool public value;
    
    // We define the variable in order to implement the method checking modifier
    
    string  meth_getDidDoc = "getDidDoc";
    string  meth_setDidDoc = "setDidDoc";
    string  meth_getEntity = "getEntity";
    string  meth_setEntity = "setEntity";
    
    
    //modifier isRegistered(){
        
    //}
    /*function verifySignature (string memory _message, bytes memory _signature, bytes32 _nonce) public OnlyAgent returns (bool) {
      
     
        require(SignVerify.verify(agent, _message,  _nonce, _signature) == true);
        verifiedSignature = true;
        return verifiedSignature;
        
    }*/
    
    //function parsePayload (string memory payload) public OnlyAgent {
        
    //}
    
    function parseParam () public OnlyAgent  {
        
        StringUtils.slice memory payloadSlice = payload.toSlice();  
        StringUtils.slice memory needle = ".".toSlice(); 
        method_Slice = payloadSlice.split(needle);
        method_Str = method_Slice.toString();
        value = StringUtils.hashCompareWithLengthCheck(method_Str,meth_setEntity);
        // users[agent].method = method_uint;
        
        if (StringUtils.hashCompareWithLengthCheck(method_Str,meth_setEntity) == true){ // SET IDENTITY METHOD
        
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.hashCompareWithLengthCheck(method_Str,meth_getEntity) == true){ // GET IDENTITY METHOD
        
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = StringUtils.stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.hashCompareWithLengthCheck(method_Str,meth_setDidDoc) == true){ // SET DIDDOC METHOD
        
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = StringUtils.stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.hashCompareWithLengthCheck(method_Str,meth_getDidDoc) == true){  // GET DIDDOC METHOD
            
            did = payloadSlice.split(needle).toString();
            publicKey = payloadSlice.split(needle).toString();
            string memory sign = payloadSlice.split(needle).toString();
            signature = StringUtils.stringToBytesArray(sign);
            typeOfKey = payloadSlice.split(needle).toString();
        }
        
    }
    
    modifier isGetDidDoc (){
        //First we convert strings to slices

        require(StringUtils.hashCompareWithLengthCheck(method_Str,meth_getDidDoc) == true);
        _;
    }
    
    modifier isSetDidDoc (){
        require(StringUtils.hashCompareWithLengthCheck(method_Str,meth_setDidDoc) == true);
        _;
    }
    
    modifier isSetEntity(){
        require(StringUtils.hashCompareWithLengthCheck(method_Str,meth_setEntity) == true);
        _;
    }
    
    modifier isGetEntity(){
        require(StringUtils.hashCompareWithLengthCheck(method_Str,meth_getEntity) == true);
        _;
    }
    
    
    
}



contract EntityManagement is SignatureVerifier {
    
    bool createdIdentity = false;
    bool option;
    string public _publicKey;

    
    function setEntity() public OnlyAgent isSetEntity returns(bool){
        setUser(publicKey, did, didID, didMethod, payload, didDoc, nonce, signature, typeOfKey, method_Str);
        createdIdentity = true;
        return createdIdentity;
        
    }
    
    
    function getEntity() public OnlyAgent isGetEntity returns (string memory){
        
        users[agent].method = method_Str;
        users[agent].signature = signature;
        users[agent].typeOfKey = typeOfKey;
        
        bytes32 sha_256 = StringUtils.getSha(publicKey);
        

        
        string memory sha_256_string = StringUtils.bytes32ToString(sha_256);
        
        
        require (StringUtils.hashCompareWithLengthCheck(sha_256_string,didID) == true);
        return publicKey;
    }
    
    function see() public view returns(string memory){
        return sha_256_string;
    }
    
     function getDidDoc() public OnlyAgent isGetDidDoc returns (string memory){
         _publicKey = users[agent].publicKey;
        users[agent].method = method_Str;
        users[agent].signature = signature;
        users[agent].typeOfKey = typeOfKey;
        return users[agent].didDoc;
    }
    

    
    function setDidDoc1() public OnlyAgent isSetDidDoc returns (bool){
        _publicKey = users[agent].publicKey;
        users[agent].method = method_Str;
        users[agent].signature = signature;
        users[agent].typeOfKey = typeOfKey;
        users[agent].didDoc = didDoc_Creation.setDidDoc(users[agent].didDoc,users[agent].did,users[agent].typeOfKey, users[agent].publicKey);
        
        bool createDidDoc = true;
        return createDidDoc;
    }
    
    
} 
