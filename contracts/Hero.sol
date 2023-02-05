// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol)

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Mintable.sol";
import "./utils/String.sol";

contract Hero is ERC721, Mintable, IERC2981 {
    address public bank;

    // type of item give position too
    mapping(uint256 => uint16) nftType;
    mapping(uint256 => uint256[]) nftItems;

    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        address _imx
    ) ERC721(_name, _symbol) Mintable(_owner, _imx) {
        bank = _owner;
    }

    modifier onlyOwnerOf(uint256 tokenId) {
        require(ownerOf(tokenId) == _msgSender(), "Not owner of nft");
        _;
    }

    function _mintFor(
        address user,
        uint256 id,
        bytes memory
    ) internal override {
        _safeMint(user, id);
        
    }

    function royaltyInfo(
        uint256, /*tokenId*/
        uint256 value
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        // 10% royalties
        return (bank, (value * 10) / 100);
    }

    function getItems(uint256 tokenId) public view returns (uint256[] memory) {
        return nftItems[tokenId];
    }

    function getItemsLength(uint256 tokenId) public view returns (uint256) {
        return nftItems[tokenId].length;
    }

    function withdrawItem(uint256 tokenId, uint256 itemPos)
        public
        onlyOwnerOf(tokenId)
    {
        uint256 itemId = nftItems[tokenId][itemPos];
        require(itemId > 0, "no item to withdraw");
        transferFrom(address(this), msg.sender, itemId);
        // reinit item
        nftItems[tokenId][itemPos] = 0;
    }

    function putItem(uint256 tokenId, uint256 itemTokenId)
        public
        onlyOwnerOf(tokenId)
    {
         require(
                ownerOf(itemTokenId) == _msgSender(),
                "Not owner of item"
            );
        _addItem(tokenId, itemTokenId);
    }

    function putMultipleItems(uint256 tokenId, uint256[] calldata itemTokenIds)
        public
        onlyOwnerOf(tokenId)
    {
        for (uint256 i = 0; i < itemTokenIds.length; i++) {
            require(
                ownerOf(itemTokenIds[i]) == _msgSender(),
                "Not owner of item"
            );
            _addItem(tokenId, itemTokenIds[i]);
        }
    }

    function _addItem(uint256 tokenId, uint256 itemTokenId) internal {
        uint16 itemPos = nftType[itemTokenId];
        // nft type 1 one is for character
        require(itemPos > 1, "Can't put this item");
        uint256 itemId = nftItems[tokenId][itemPos];
        require(itemId == 0, "Already an item");
        transferFrom(msg.sender, address(this), itemTokenId);
        nftItems[tokenId][itemPos] = itemTokenId;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
