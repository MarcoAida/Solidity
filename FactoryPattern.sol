// SPDX-License-Identifier: UNKNOWN
// Specifies the version of Solidity, using semantic versioning.
// Learn more: https://solidity.readthedocs.io/en/v0.5.10/layout-of-source-files.html#pragma

pragma solidity ^0.8.0;

import "./Immatricolazione.sol";

contract FactoryPattern {
    Immatricolazione[] private _immatricolazioni;
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    // Crea una nuova immatricolazione e la aggiunge all'array
    function createImmatricolazione() public onlyOwner returns (Immatricolazione) {
        Immatricolazione newImmatricolazione = new Immatricolazione();
        _immatricolazioni.push(newImmatricolazione);
        return newImmatricolazione;
    }

    // Restituisce tutte le immatricolazioni create
    function getImmatricolazioni() public view returns (Immatricolazione[] memory) {
        return _immatricolazioni;
    }
}
