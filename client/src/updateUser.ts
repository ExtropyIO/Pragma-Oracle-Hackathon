import 'dotenv/config';
import { Telegraf } from 'telegraf';
import Web3 from 'web3';
import { LocalStorage } from 'node-localstorage';

/* 
  Persist data to local storage as mapping (address => msgId)
  Maps an ethereum address to telegram conversation id
*/
const keyStore = new LocalStorage('./scratch');


export default function sendTelegramMsg(address: string, msg: string) {
  const bot = new Telegraf(process.env.TELEGRAM_TOKEN as string);
  let msgID = keyStore.getItem(address);
  if (msgID !== null) {
    bot.telegram.sendMessage(msgID, msg);
  } else {
    console.log("No chat ID found for address " + address);
  };
}


//Example usage:



