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
  bot.telegram.sendMessage(keyStore.getItem(address), msg);
}


//Example usage:

sendTelegramMsg("0x361D3d0AE98b84dAd452104B27ceA24464C16367", "Hello World!");


