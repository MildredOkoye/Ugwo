# UGWO - Towards Cryptocurrency Lending 

The creditscore contract is at the center of the lending structure. Therefore all other contracts reference the address of the contract.
Once the Credit score cntract is created, the address has to be hard coded to the other contracts such as bond, collateral, loan etc before executing the contracts.

This API uses an oracle called Oraclize.

Due to the inability for the oracle to funtion with the latest ethereum walllet, this code runs on Ethereum-Wallet-win32-0-8-9 version. 


