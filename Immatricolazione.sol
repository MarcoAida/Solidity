// SPDX-License-Identifier: UNKNOWN
// Specifies the version of Solidity, using semantic versioning.
// Learn more: https://solidity.readthedocs.io/en/v0.5.10/layout-of-source-files.html#pragma

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./GestioneVeicoli.sol";

contract Immatricolazione is GestioneVeicoli {

    address private _owner; // 'owner' si riferisce a chi controlla questo contratto
    bool public contractStopped = false;     /* Emergency Stop Pattern */

    constructor() {
        _owner = msg.sender;
    }

    event VeicoloTransferito(string targa, address from, address to);

    /* Emergency Stop Pattern */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    /* */
    modifier onlyVehicleOwner(string memory _targa) {
        require(veicoli[_targa].proprietarioVeicolo == msg.sender,
            "Caller is not the owner of this vehicle");
        _;
    }

    /* */
    modifier haltEmergency() {
        require(!contractStopped, "Contract is stopped");
        _;
    }

    /* */
    modifier enableEmergency() {
        require(contractStopped, "Contract is not stopped");
        _;
    }

     // Funzione per immatricolare un nuovo veicolo
    function immatricolaVeicolo(
        string memory _targa,
        string memory _modello,
        uint _annoImmatricolazione
    ) public haltEmergency {
        //require(isTargaValid(_targa), "Targa non valida.");
        require(isTargaValid(_targa), string(abi.encodePacked("Targa non valida: ", _targa)));
        require(veicoli[_targa].annoImmatricolazione == 0, "Veicolo gia' immatricolato.");

        veicoli[_targa] = DatiVeicolo({
            proprietarioVeicolo: msg.sender,
            targa: _targa,
            modello: _modello,
            annoImmatricolazione: _annoImmatricolazione
        });

        emit VeicoloImmatricolato(
            msg.sender,
            _targa,
            _modello,
            _annoImmatricolazione
        );
    }

    // Funzione per ottenere i dettagli di un veicolo
    function carToString(string memory _targa) public view returns (string memory) {
        require(veicoli[_targa].annoImmatricolazione != 0, "Veicolo non trovato");

        DatiVeicolo memory car = veicoli[_targa];
        return string(
            abi.encodePacked(
                "Proprietario: ",
                addressToString(car.proprietarioVeicolo),
                ", Targa: ",
                car.targa,
                ", Modello: ",
                car.modello,
                ", Anno di Immatricolazione: ",
                car.annoImmatricolazione.toString()
            )
        );
    }

    // Funzione per cambiare il proprietario di un veicolo
    function cambiaProprietarioVeicolo(string memory _targa, address newOwner) public onlyVehicleOwner(_targa) {
        require(newOwner != address(0), "Indirizzo nuovo proprietario non valido.");

        address oldOwner = veicoli[_targa].proprietarioVeicolo;
        veicoli[_targa].proprietarioVeicolo = newOwner;

        emit VeicoloTransferito(_targa, oldOwner, newOwner);
    }

    // Funzione per cambiare il proprietario del contratto
    function cambiaProprietarioContratto(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Indirizzo nuovo proprietario non valido.");
        _owner = newOwner;
    }

    // Funzione per ottenere l'indirizzo del proprietario del contratto
    function owner() public view returns (address) {
        return _owner;
    }

    function ContractStopped() public onlyOwner {
        contractStopped = !contractStopped;
    }

    function deposit() public payable haltEmergency {
        // Code for deposit
    }

    function withdraw() public enableEmergency {
        // Code for withdraw
    }

    using Strings for uint256;
    using Strings for address;

    // Funzione per convertire un address in string
    function addressToString(address _address) internal pure returns (string memory) {
        return uint256(uint160(_address)).toHexString(20);
    }

    // Funzione per verificare la validità della targa
    function isTargaValid(string memory _targa) internal pure returns (bool) {
        bytes memory targaBytes = bytes(_targa);
    
        // Verifica che la lunghezza sia esattamente 7 caratteri e controlla i caratteri specifici
        if (targaBytes.length != 7) return false;

        return (targaBytes[0] >= 'A' && targaBytes[0] <= 'Z') &&
                (targaBytes[1] >= 'A' && targaBytes[1] <= 'Z') &&
                (targaBytes[2] >= '0' && targaBytes[2] <= '9') &&
                (targaBytes[3] >= '0' && targaBytes[3] <= '9') &&
                (targaBytes[4] >= '0' && targaBytes[4] <= '9') &&
                (targaBytes[5] >= 'A' && targaBytes[5] <= 'Z') &&
                (targaBytes[6] >= 'A' && targaBytes[6] <= 'Z');
    }

}
