# Custard Watchtower  

## How to run  

- `docker run -it -p 3306:3306 -e MYSQL_ROOT_PASSWORD="default_password" -e MYSQL_DATABASE="checkpoint" mysql:8.0 "--default-authentication-plugin=mysql_native_password"`

- Fill in `.env' file with DATABASE_URL and TELEGRAM_TOKEN. For docker use mysql://root:default_password@localhost:3306/checkpoint as your .env files DATABASE_URL value .  

- `yarn`

- `yarn dev`

## How to use 

- Go to `https://t.me/CustardWalletBot` and track your wallet.
- Invoke `escape_guardian` on `https://testnet.starkscan.co/contract/0x06bb338b361107aa231c134b3b147bb630ae6cba39bdb02927ce11ae62f3291a#read-write-contract-sub-write` from your Starknet Testnet wallet

This will change when we have actual Cairo 1 smart contract wallet to trigger recovery.

## Troubleshooting

- For an error message saying something about `starknet_undefined` network:
    - restart the script
    - ev. restart the docker mysql
- For an error message saying something abouut `checkpoint reset`:
    - delete mysql contrainer and start a new one
- If your script is too many blocks behind:
    - change `start` value in `backend/src/config.json`

# Pragma-Oracle-Hackathon  

Hackathon: https://taikai.network/pragma-oracle/hackathons/Cairo1hackathon  

Description  

For two weeks, the hackathon will be ongoing. The focus of this hackathon is to use starknet projects such as Madara, Cartrige, ### Dojo, etc.. to build something specific.  

Kick-off video: https://www.twitch.tv/videos/1843493291  

# Checkpoint  

https://docs.checkpoint.fyi/tutorials/ep1-get-started  
https://www.twitch.tv/videos/1845974575  
https://www.youtube.com/watch?v=OY6NJQtVO20  

# Dojo:  

Information about the goal: https://www.notion.so/Hack-Information-Realms-db86705480c34dd9a2a6472d8637c461  

Bounties:  

dojo: [here](https://astraly.notion.site/Hack-information-Dojo-6db435246b5b4d5b9e0fd17b67ede2d2)  

Cartridge/Roll your own/ DopeWars: [here](https://astraly.notion.site/Hack-information-Cartridge-a06821c72c8c49b19907c3045f6660c5)  

Realms: [here](https://www.notion.so/Hack-Information-Realms-db86705480c34dd9a2a6472d8637c461#a78c7ed74c30446fa675a34b6dc4a051)  

briq: [here](https://astraly.notion.site/Hack-information-briq-51a1a8def49042418fbe90c281fbad9d)  


To do:  
[ ] Game Idea  
[ ] Game Design  
[ ] ..  

Resources:  

Presentation: [here](https://docs.google.com/presentation/d/1hPY3vLmkJWRULVK4e8OvpJkufgTWevtmkeOKHJYZT3k/edit#slide=id.g221159b8a87_0_9)  

Dojo engine & installation: [here](https://github.com/dojoengine)  

Dojo book: [here](https://github.com/dojoengine/book)  

Dojo template: [here](https://github.com/dojoengine/dojo-starter)  


Other:  
https://twitter.com/LootRealms/status/1666787146940973056  

https://twitter.com/LordSecretive/status/1667223214366289920  
