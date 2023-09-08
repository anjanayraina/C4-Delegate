// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";
import {OrderParameters} from "seaport/contracts/lib/ConsiderationStructs.sol";
import {SeaportHashLib} from "./SeaportHashLib.t.sol";
import {SeaportInterface} from "seaport/contracts/interfaces/SeaportInterface.sol";

struct User {
    address addr;
    uint256 key;
}

abstract contract SeaportHelpers is Test {
    using SeaportHashLib for OrderParameters;
    using SeaportHashLib for bytes32;

    function makeUser(string memory _name) internal returns (User memory) {
        (address addr, uint256 key) = makeAddrAndKey(_name);
        return User(addr, key);
    }

    function signERC712(User memory _user, bytes32 _domainSeparator, bytes32 _structHash) internal pure returns (bytes memory sig, bytes32 erc721Hash) {
        erc721Hash = _domainSeparator.erc712DigestOf(_structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_user.key, erc721Hash);
        sig = abi.encodePacked(r, s, v);
    }

    function signOrder(SeaportInterface seaport, User memory user, OrderParameters memory orderParams) internal view returns (bytes memory sig) {
        (, bytes32 seaportDomainSeparator,) = seaport.information();
        (sig,) = signERC712(user, seaportDomainSeparator, orderParams.hash(seaport.getCounter(user.addr)));
    }
}
