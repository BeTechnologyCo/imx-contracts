// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Bytes.sol";
import "./String.sol";

library Minting {
    // Split the minting blob into token_id and blueprint portions
    // {token_id}:{blueprint}

    function split(bytes calldata blob)
        internal
        pure
        returns (uint256, bytes memory)
    {
        int256 index = Bytes.indexOf(blob, ":", 0);
        require(index >= 0, "Separator must exist");
        // Trim the { and } from the parameters
        uint256 tokenID = Bytes.toUint(blob[1:uint256(index) - 1]);
        uint256 blueprintLength = blob.length - uint256(index) - 3;
        if (blueprintLength == 0) {
            return (tokenID, bytes(""));
        }
        bytes calldata blueprint = blob[uint256(index) + 2:blob.length - 1];
        return (tokenID, blueprint);
    }

     function deserializeMintingBlob(bytes memory mintingBlob) internal pure returns (uint256, uint16, uint256[]) {
        string[] memory idParams = String.split(string(mintingBlob), ":");
        require(idParams.length == 2, "Invalid blob");
        string memory tokenIdString = String.substring(idParams[0], 1, bytes(idParams[0]).length - 1);
        string memory paramsString = String.substring(idParams[1], 1, bytes(idParams[1]).length - 1);

        string[] memory paramParts = String.split(paramsString, ",");
        require(paramParts.length == 2, "Invalid param count");

        uint256 tokenId = String.toUint(tokenIdString);
        uint16 proto = uint16(String.toUint(paramParts[0]));
        uint256[] quality = uint256[](String.toUint(paramParts[1]));

        return (tokenId, proto, quality);
    }
}
