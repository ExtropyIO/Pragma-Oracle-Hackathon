import 'dotenv/config';
import { Telegraf } from 'telegraf';
import Web3 from 'web3';
import { LocalStorage } from 'node-localstorage';
/* 
  Persist data to local storage as mapping (address => msgId)
  Maps an ethereum address to telegram conversation id
*/
const keyStore = new LocalStorage('./scratch');

// telegram listener
export default async function telegram() {
  const telegram = new Telegraf(process.env.TELEGRAM_TOKEN as string);
  const web3 = new Web3(process.env.RPC_URL as string);
  telegram.start((ctx) => { ctx.reply('Welcome to Custard Watchtower. Enter /track followed by a valid Ethereum address to get started.') })
  telegram.help((ctx) => {
    ctx.reply('Use /track [Your-ethereum account]')
  })
  telegram.command('track', async (ctx) => {
    let account = ctx.message.text;
    //Check address is valid
    if (web3.utils.isAddress(account) === false) {
      if (account === undefined) {
        ctx.reply("Please enter /track followed by a valid Ethereum address")
      } else { ctx.reply(`${account} is not a valid Ethereum address`) }
    } else {
      keyStore.setItem(account, ctx.message.chat.id);
      ctx.reply("done " + account);
      /*
      Code should take account and pass to backend here. 
      */

    }
  });
  telegram.launch()
  // Enable graceful stop
  process.once('SIGINT', () => telegram.stop('SIGINT'))
  process.once('SIGTERM', () => telegram.stop('SIGTERM'))
};

telegram();
