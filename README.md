# Custard Watchtower

## Project Description

Custard Watchtower is a watchtower project where users can submit their account address through an interface and get notified when their wallet enters through a recovery phase mode.

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

## Hackathon Resources:

### General

Hackathon: https://taikai.network/pragma-oracle/hackathons/Cairo1hackathon

Kick-off video: https://www.twitch.tv/videos/1843493291

### Checkpoint

https://docs.checkpoint.fyi/tutorials/ep1-get-started

https://www.twitch.tv/videos/1845974575

https://www.youtube.com/watch?v=OY6NJQtVO20
