pragma solidity ^0.5.0;

import "contracts/Libraries/base64_decoding/Base64.sol";
import "contracts/Libraries/Json_parsing/JsmnSolLib.sol";
import "contracts/Libraries/base64_decoding/Strings.sol";
import "contracts/Libraries/base64_decoding/SolRsaVerify.sol";





contract Proxy {
   
    address agent;
    string did;
    string didMethod= ""; // We initialize the didMethod to an empty string
    string didID= ""; // We initialize the didID to an empty string
    string payload = ""; // We initialize the payload to an empty string
    bool _proxy;
    using StringUtils for *;
    using SolRsaVerify for *;
    bool ack;
    
    constructor (string memory _did, string memory _payload) public {
        did = _did;
        payload = _payload;
        setAgent();
    }
    
    
    modifier OnlyAgent(){ // Modifier which permits the proxy verification
        require(msg.sender == agent);
        _;
    }
   
    
    function proxy (string memory _did,string memory _payload,string memory didMethod,string memory didID) public OnlyAgent returns (bool) {
        


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

        // We get the DID's parameters
        
       
        
        // We check for the first requirement
        
        string memory EOA_string = toString_1(EOA);
        StringUtils.slice memory didID_slice = didID.toSlice();  

        
        StringUtils.slice memory EOA_slice  = EOA_string.toSlice();  
        
        
        
        firstCheck = StringUtils.equals(EOA_slice, didID_slice);
        require(firstCheck == true);
        
        _proxy = true;
        return _proxy;
    }
    
    function setAgent () public {
        agent = msg.sender;
    }
    
    function toString_1(address addr) public returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
          b[i] = byte(uint8(uint(addr) / (2**(8*(19 - i)))));
        }
        return string(b);
  }
    
}
    
    
    
   

contract IdentityRegistry is Proxy {
    bool createdIdentity;
    bool option;
    string public _publicKey;

    
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
    string method="";
    
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
    
    
        
    function verifySignature (string memory _publicKey , string memory _payload, string memory _modulus, string memory _exponent) public OnlyAgent IsSet {
        
        bytes memory _data = bytes(_payload);
        bytes memory _s = bytes(publicKey);
        bytes memory _e = bytes(_exponent);
        bytes memory _m = bytes(_modulus);
        
        uint result = SolRsaVerify.pkcs1Sha256VerifyRaw(_data,_s,_e,_m);
        require (result == 1);
        
    }
    
    function parsePayload (string memory payload) public OnlyAgent IsSet {
        
    }
    
    function parseParam (string memory payload) public OnlyAgent IsSet {
        
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
    
}

contract EntityManagement is SignatureVerifier {
    
    function getEntity(string memory _did) public OnlyAgent isGetEntity returns (bool){
        
        
    }
    
    function setEntity(string memory _did, string memory _publicKey) public OnlyAgent isSetEntity returns (bool) {
        
        
    }
    
}

contract EntityDocument is SignatureVerifier {
    
    function getDidDoc(string memory _did) public OnlyAgent isGetDidDoc returns (bool){
        
    }
    
    function setDidDoc(string memory _did, string memory _diddoc) public OnlyAgent isSetDidDoc returns (bool){
        
    }
    
    
    
}

// Extra functions