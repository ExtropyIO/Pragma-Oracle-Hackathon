import { Account, ec, json, stark, Provider, hash } from "starknet";

// Generate public and private key pair.
const privateKey = stark.randomAddress();
console.log("New account :\nprivateKey=", privateKey);
const starkKeyPub = ec.starkCurve.getStarkKey(privateKey);
console.log("publicKey=", starkKeyPub);

// calculate future account address
