pragma solidity ^0.5.0;

import "contracts/Libraries/base64_decoding/Strings.sol";
import "contracts/Libraries/Signature_Verification/SignVerify.sol";
import "contracts/Libraries/didDoc_Creation/didDoc_create.sol";




contract Proxy {
   
    using StringUtils for *;
    using SignVerify for *;
    using didDoc_Creation  for *;
   
   /*
    string  did="";
    string  didMethod= ""; // We initialize the didMethod to an empty string
    string  didID= ""; // We initialize the didID to an empty string
    string  payload = ""; // We initialize the payload to an empty string
    string  publicKey = ""; // We initialize the variable that will store the pubKey
    string  didDoc=""; // Variable that will store the didDoc
    bytes32  nonce;
    */
    address public agent;
    string  did1="";
    bool  proxy; // Proxy function bool
    bool  ack;
    uint public counter = 0;
    uint public counter1 = 0;
    
    
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
    address[] public userAdress;
    address[] public registDidDoc;
    
    constructor() public{
        address init = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
        userAdress.push(agent) -1;
        registDidDoc.push(agent) -1;
    }

    
    modifier OnlyAgent(){ // Modifier which permits the proxy verification
        require(msg.sender == agent);
        _;
    }
    
    
    function proxy1 (string memory _did,string memory _payload) public returns (bool) {
        
        // We set the agent to the one sending the transaction to the proxy
        setAgent();
        bool firstCheck;
        bool _proxy;
        users[agent].did = _did;
        users[agent].payload = _payload;
        
        // We slice the did in order to get the did, didMethod and the didID
        
        StringUtils.slice memory didSlice = _did.toSlice();  
        StringUtils.slice memory needle = ":".toSlice(); 
        did1 = didSlice.split(needle).toString();
        users[agent].didMethod = didSlice.split(needle).toString();
        users[agent].didID = didSlice.split(needle).toString(); 

        _proxy = false;

        
        // We check for the first requirement
        
       // string memory EOA_string = StringUtils.toString_1(agent);
        //StringUtils.slice memory didID_slice = didID.toSlice();  

        
    //    StringUtils.slice memory EOA_slice  = EOA_string.toSlice();  
        
        
        
        //firstCheck = StringUtils.equals(EOA_slice, didID_slice);
        // require(firstCheck == true); Se agregara cuando tengamos el par de claves
        
        generateNonce();

        _proxy = true;
        return _proxy;
    }
    
    function setAgent () public returns (uint){
        agent = msg.sender;
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

    function generateNonce() public OnlyAgent{
        users[agent].nonce = keccak256(abi.encodePacked(agent, counter)); 
    }
    
}

contract SignatureVerifier is Proxy{
    
    bool verifiedSignature = false;
    string sign;
    /*
    bytes signature="";
    string public typeOfKey = "";
    string public method_Str = "";
    */
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
        
        StringUtils.slice memory payloadSlice = users[agent].payload.toSlice();  
        StringUtils.slice memory needle = ".".toSlice(); 
        method_Slice = payloadSlice.split(needle);
        users[agent].method = method_Slice.toString();
        // users[agent].method = method_uint;
        
        if (StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_setEntity) == true){ // SET IDENTITY METHOD
        
            users[agent].did = payloadSlice.split(needle).toString();
            users[agent].publicKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_getEntity) == true){ // GET IDENTITY METHOD
        
            users[agent].did = payloadSlice.split(needle).toString();
            //publicKey = payloadSlice.split(needle).toString();
            sign = payloadSlice.split(needle).toString();
            users[agent].signature = StringUtils.stringToBytesArray(sign);
            users[agent].typeOfKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_setDidDoc) == true){ // SET DIDDOC METHOD
        
            users[agent].did = payloadSlice.split(needle).toString();
            users[agent].publicKey = payloadSlice.split(needle).toString();
            sign = payloadSlice.split(needle).toString();
            users[agent].signature = StringUtils.stringToBytesArray(sign);
            users[agent].typeOfKey = payloadSlice.split(needle).toString();
        }
        
        if (StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_getDidDoc) == true){  // GET DIDDOC METHOD
            
            users[agent].did = payloadSlice.split(needle).toString();
            users[agent].publicKey = payloadSlice.split(needle).toString();
            sign = payloadSlice.split(needle).toString();
            users[agent].signature = StringUtils.stringToBytesArray(sign);
            users[agent].typeOfKey = payloadSlice.split(needle).toString();
        }
        
    }
    
    modifier isGetDidDoc (){
        require(StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_getDidDoc) == true);
        _;
    }
    
    modifier isSetDidDoc (){
        require(StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_setDidDoc) == true);
        _;
    }
    
    modifier isSetEntity(){
        require(StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_setEntity) == true);
        _;
    }
    
    modifier isGetEntity(){
        require(StringUtils.hashCompareWithLengthCheck(users[agent].method,meth_getEntity) == true);
        _;
    }
    
}



contract EntityManagement is SignatureVerifier {
    
    bool createdIdentity = false;
    bool option;
    string _publicKey;
    bool public verif;

    function setEntity() public OnlyAgent isSetEntity  returns(bool){
        counter++;
        
        for (uint i=0; i< counter; i++){
            verif = true;
            address compare = userAdress[i];
            if(agent == compare){
                verif = false;
            }
            require (verif == true);
        }
        
        createdIdentity = true;
        userAdress.push(agent) -1;
        return createdIdentity;
    }
    
    
    function getEntity() public OnlyAgent isGetEntity returns (string memory){
        
        verif = false;
        for (uint i=0; i<= counter; i++){
            address compare = userAdress[i];
            if (agent == compare){
                verif = true;
            }
        }
        require(verif == true);
        
        
        
        bytes32 sha_256 = StringUtils.getSha(users[agent].publicKey);
        

        /*
        string memory sha_256_string = StringUtils.bytes32ToString(sha_256);
        
        
        require (StringUtils.hashCompareWithLengthCheck(sha_256_string,didID) == true);
        */
        
        return users[agent].publicKey;
    }
    
    function setDidDoc1() public OnlyAgent   isSetDidDoc returns (bool){
        
        //Completed set
        verif = false;
        for (uint i=0; i<= counter; i++){
            address compare = userAdress[i];
            if (agent == compare){
                verif = true;
            }
        }
        require(verif == true);
        
        verif = true;
        // Already Doc
        for (uint i=0; i<= counter1; i++){
            address compare = registDidDoc[i];
            if (agent == compare){
                verif = false;
            }
            require(verif == true);
        }
        
        counter1++;
        users[agent].didDoc = didDoc_Creation.setDidDoc(users[agent].didDoc,users[agent].did,users[agent].typeOfKey, users[agent].publicKey);
        registDidDoc.push(agent) -1;
        bool createDidDoc = true;
        return createDidDoc;
        
    }
    
    
    function getDidDoc() public  OnlyAgent isGetDidDoc returns (string memory){
        
        verif = false;
        //completedSet
        verif = false;
        for (uint i=0; i<= counter; i++){
            address compare = userAdress[i];
            if (agent == compare){
                verif = true;
            }
        }
        require(verif == true);
        
        //completedDoc
        
        verif = false;
        for (uint i=0; i<= counter1; i++){
            address compare = registDidDoc[i];
            if (agent == compare){
                verif = true;
            }
        }   
        require (verif == true);
        
        return users[agent].didDoc;
    }
    
    function getCounter() public view returns(uint){
        return counter;
    }
    

    /*
    modifier alreadySet() {
        for (uint i=0; i< counter; i++){
            address compare = userAdress[i];
            require(agent != compare);
            _;
        }
    }
    
    modifier completedSet(){
        for (uint i=0; i< counter; i++){
            address compare = userAdress[i];
            require(agent == compare);
            _;
        }
    }
    
    modifier alreadyDoc(){
        for (uint i=0; i< counter1; i++){
            address compare = registDidDoc[i];
            require(agent != compare);
            _;
        }
    }
    
    modifier completedDoc(){
        for (uint i=0; i< counter1; i++){
            address compare = registDidDoc[i];
            require(agent == compare);
            _;
        }
    }
    */
    
} 
