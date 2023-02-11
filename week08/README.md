# Lab8 - report

Please, note. I created account with the following login **tasneemtoolba.testnet**, and ID of my contract is **nft-tutorial.tasneemtoolba.testnet**.

### Results of commands
`near login`

`near create-account $NFT_CONTRACT_ID --masterAccount $MAIN_ACCOUNT --initialBalance 10`

`near deploy --accountId $NFT_CONTRACT_ID --wasmFile out/main.wasm`

![img.png](images/1.png)

### Screenshot of the first transaction

![img.png](images/t1.png)

### Result of the command 
`near call $NFT_CONTRACT_ID new_default_meta '{"owner_id": "'$NFT_CONTRACT_ID'"}' --accountId $NFT_CONTRACT_ID`

`near view $NFT_CONTRACT_ID nft_metadata`

`near call $NFT_CONTRACT_ID nft_mint '{"token_id": "some id", "metadata": {"title": "some title", "description": "some description", "media": "a link to a media file"}, "receiver_id": "'$MAIN_ACCOUNT'"}' --accountId $MAIN_ACCOUNT --amount 0.1`

![img.png](images/2.png)
![img.png](images/3.png)

### Screenshot of the second transaction

![img.png](images/t2.png)

### Result of the rest of commands 

![img.png](images/4.png)
![img.png](images/5.png)

### Screenshot of the last transactions

![img.png](images/t3.png)
