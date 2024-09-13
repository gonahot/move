# SuiPet
All NFT images involved in SuiPet have been uploaded to Walrus. The website deployment address is: https://2766kjzwi03jtjzdd5858shp4zic8aivm1nw4y8njrci8ejnu2.walrus.site/home

## Project Description
SuiPet is a growth-oriented pet on Sui with NFT dressing-up as the core gameplay logic, while also incorporating a question bank to make the learning process less tedious.<br>
In the game, players need to sign in and answer questions to earn points and increase their pet's level, using points to purchase outfits and make their pet's appearance more varied.<br>
The question bank can be sourced from external platforms, which means the pet can closely relate to your current studies, providing you with immense enjoyment in learning!

## Game Flow
1. Connect Wallet
While connecting to the SUI Wallet, generate a user struct stored under the address.
2. Mint Pet
Mint a pet with an initial appearance and send it to the user (the pet will move!)
3. Daily Check-in
Checking in daily will earn 2 points, which can be used to exchange for mystery box outfits.
4. Answer Questions
Answering questions will earn corresponding points. The built-in question bank allows for integration with various learning platforms.
5. Redeem Outfits
Spend 10 points to exchange for a mystery box outfit on the outfits page and dress your pet in it!
*"Action" accessories will override any other existing accessories!*

## Interface Description
`create_user`: No parameters needed, sends an event to create a new user (including user id, address, total score)<br>
`create_pet`: Pass in the pet's name, send an event to create a pet (including pet id, name, user's address)<br>
`mint_item`: Pass in the accessory type and user id, the user receives an outfit<br>
`update_pet`: Pass in a pet id to update the pet's level<br>

### Types
There are currently 3 accessory types: Action, Hat, and Clothing (when an action is displayed, other outfits are not visible)<br>
const Type_cap:u64 = 1;<br>
const Type_action:u64 = 2;<br>
const Type_item:u64 = 3;<br>

## Function Description
`add_score`: Increase user score by passing in the user ID and the amount to increase<br>
`remove_item_from_pet`: Take off an outfit from the pet by passing in the pet id and accessory id<br>
`add_item_to_pet`: Dress the pet in an outfit by passing in the pet id and outfit type<br>
