
pragma solidity ^0.5.0;
import "contracts/Libraries/base64_decoding/Strings.sol";


library didDoc_Creation{
    
    using StringUtils for *;
    function setDidDoc(string memory didDoc,string memory did,string memory typeOfKey, string memory publicKey) public  returns (string memory){
            
            //concat(slice memory self, slice memory other)
            
            
            didDoc = "{ \"id\" : \"";
            StringUtils.slice memory part1 = didDoc.toSlice();
            StringUtils.slice memory part2 = did.toSlice();
    
            string memory result = StringUtils.concat(part1,part2);
            StringUtils.slice memory resultSlice = result.toSlice();
            
            string memory part3 = "\", \"authentication\": [{ \"id\": ";
            part1= part3.toSlice();
            result = StringUtils.concat(resultSlice,part1);
            resultSlice = result.toSlice();
            
            result = StringUtils.concat(resultSlice,part2);
            resultSlice = result.toSlice();
    
            part3 = "\", \"type\": \"";
            part1 = part3.toSlice();
    
            result = StringUtils.concat(resultSlice,part1);
            resultSlice = result.toSlice();
    
            
            part1 = typeOfKey.toSlice();
            
            result = StringUtils.concat(resultSlice,part1);
            resultSlice = result.toSlice();
            
            part3 = "\", \"controller\": \"";
            part1 = part3.toSlice();
            
            result = StringUtils.concat(resultSlice,part1);
            resultSlice = result.toSlice();
            
            
            result = StringUtils.concat(resultSlice,part2);
            resultSlice = result.toSlice();
    
            part3 = "\", \"publicKey\": \"";
            part1 = part3.toSlice();
            
            result = StringUtils.concat(resultSlice,part1);
            resultSlice = result.toSlice();
            
            part1 = publicKey.toSlice();
           
            result = StringUtils.concat(resultSlice,part1);
            resultSlice = result.toSlice();
            
            part3= "\" }] }";
            part1 = part3.toSlice();
            result = StringUtils.concat(resultSlice,part1);
            
            return result;
        }
}
