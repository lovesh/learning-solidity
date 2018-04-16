Sharetrip

Overview
Split-wise for trips: add members till trip finalised, each member can add expenses he did and optionally for members he did (default being made for all), each member can add expenses with invoice (hash of invoice), each member can add money to contract, once contract is closed and sum of payments reach are above expenses, money is returned appropriately. Contract has a spend function which can be used to pay any outsider (non-member but on ethereum).

Details:
1. Only one owner
2. Owner speicifies the minimum ether needed by members to participate
3. Anyone can request to join trip but owner's confirmation needed to add members. Joining allowed till trip starts.
4. Members record each expenditure in the contract specifying the hash of invoice, amount of the expenditure and members for which the expenditure was made. The amount of expenditure cannot exceed `(balance in contract/no. of members)*no. of participants`
5. Members can send confirmation for their participation in any expenditure.
6. Once an expense has received confirmation from all partipants, it can be used to pay any ethereum address.
7. Members can deposit money to the contract.
8. Owner can finish trip at any time. The contract returns ether to members appropriately and destroys itself.


Deployment:
Testrpc instructions:
Start as `testrpc --account="0xd9e777f8c9e846c6cde0189da989fad8248aee58e87bbbedb3a6ffb636d528dd, 1000000000000000000000" --account="0xb980e7b19df1a2a80b7c585d9f2357debc21ecd3a6871e9e3814afd30a11dd4f, 1000000000000000000000" --account="0xa9fbf1e9e870ff2fcfe3308682a5e3ed76b55a5f68d16eeb36b02defe4613243, 1000000000000000000000" --account="0x69e76f45e0bb693f6836f879306e388ef28ecc22744104e8b9bfc619d002557e, 1000000000000000000000" --account="0xbab7124ec55ea2938e8d50b0259031d32d488220d49cc215cb1e55bef80e3074, 1000000000000000000000" --account="0x797ead5b5f9a0b07e69eabc30f03846a3c4d8d787ec447940996a67e7fb21347, 1000000000000000000000" --account="0xfdc840b6644b19dff6d8603b04ce48db8bc196f9b6a56a8d51d348517327bed1, 1000000000000000000000" --account="0x94585c6f1e57729499fa8e8b1b2680ed3ccb88c35aff7712c5865f87d6313f93, 1000000000000000000000"`

Console:
`Sharetrip1.deployed().then(inst => { trip = inst })`