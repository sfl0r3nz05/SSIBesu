pragma solidity >=0.7.0 <0.9.0;

import "contracts/strings.sol";



contract Proxy {
   
    address agent;
    string did;
    string didMethod= ""; // We initialize the didMethod to an empty string
    string didID= ""; // We initialize the didID to an empty string
    string payload = ""; // We initialize the payload to an empty string
    bool _proxy;
    using strings for *;
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
        
        //Definition of variables
        string memory did;


        strings.slice memory didSlice = _did.toSlice();  
        strings.slice memory needle = ":".toSlice(); 
        did = didSlice.split(needle).toString();
        didMethod = didSlice.split(needle).toString();
        didID = didSlice.split(needle).toString();

        // parts[i] = s.split(delim).toString();                               

        bool _proxy = false;
        address EOA = msg.sender;

        // We get the DID's parameters
        
       
        
        // We check for the first requirement
        
        bytes32 EOA_SHA256;
        bytes32 didID_32 = bytes32(didID);
        EOA_SHA256 = keccak256(abi.encodePacked(EOA));
        require (EOA_SHA256 == didID_32); 
        _proxy = true;
        return _proxy;
    }
    
    function setAgent () public {
        agent = msg.sender;
    }
    
    
}
    
    
    
   

abstract contract IdentityRegistry is Proxy {
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
    string 
    function verifySignature (string memory _publicKey , string memory _payload) public OnlyAgent IsSet{
        
    }
    
}

contract EntityManagement {
    
    
}

contract EntityDocument {
    
    
    
}

// Extra functions


