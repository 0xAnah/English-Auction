// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract myNft is ERC721 {

    constructor() ERC721("MYNFT", "MYNFT") {
        _mint(msg.sender, 0);
    }

}