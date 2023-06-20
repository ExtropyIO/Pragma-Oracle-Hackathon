import 'dotenv/config';
import { Telegraf } from 'telegraf';
import { LocalStorage } from 'node-localstorage';

/* 
  Persist data to local storage as mapping (address => msgId)
  Maps an ethereum address to telegram conversation id
  Don't use this in production as it's not secure
*/
const keyStore = new LocalStorage('./scratch');

/*
Data validation for Starknet addresses is not yet implemented. Should be added in future.Sudo code:

  import { Address } from 'starknet.js';

  const checksummedAddress = Address.getChecksumAddress(account);
  if (Address.validateChecksumAddress(checksummedAddress) === false) {
    ctx.reply("Please enter /track followed by a valid Starknet address")
  } else {
    ////Code should take account and pass to backend here.
  }

*/

// telegram listener
export default async function telegram() {
  const telegram = new Telegraf(process.env.TELEGRAM_TOKEN as string);

  telegram.start((ctx) => { ctx.reply('Welcome to Custard Watchtower. Enter /track followed by a valid Starknet address to get started.') })

  telegram.help((ctx) => {
    ctx.reply('Use /track [Starknet Address]')
  })

  telegram.command('track', async (ctx) => {
    let account = ctx.message.text.split(" ")[1]

    if (account === undefined) {
      ctx.reply("Please enter /track followed by a valid Ethereum address")
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
