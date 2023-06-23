import { hexStrArrToStr, toAddress } from './utils';
import type { CheckpointWriter } from '@snapshot-labs/checkpoint';
import { getChecksumAddress, validateChecksumAddress } from 'starknet';

import { Telegraf } from 'telegraf';
import { LocalStorage } from 'node-localstorage';
const keyStore = new LocalStorage('./scratch');

export async function handleEscapeGuardianTriggered({ block, tx, rawEvent, mysql }: Parameters<CheckpointWriter>[0]) {
  if (!rawEvent) return
  handleAnything({
    eventName: 'Escape Guardian Triggered',
    block,
    tx,
    rawEvent,
    mysql
  })
}

export async function handleGuardianChanged({ block, tx, rawEvent, mysql }: Parameters<CheckpointWriter>[0]) {
  if (!rawEvent) return
  handleAnything({
    eventName: 'Guardian Changed',
    block,
    tx,
    rawEvent,
    mysql
  })

}

export async function handleAnything({ eventName, block, tx, rawEvent, mysql }) {
  if (!rawEvent) return;
  let wallet = toAddress(rawEvent.from_address);
  wallet = getChecksumAddress(wallet) || true
  const msg = `${eventName} event for ${wallet}`
  sendTelegramMsg(wallet, msg)
}

function sendTelegramMsg(address: string, msg: string) {
  const bot = new Telegraf(process.env.TELEGRAM_TOKEN as string);
  let msgID = keyStore.getItem(address);
  if (msgID !== null) {
    bot.telegram.sendMessage(msgID, msg);
  } else {
    console.log("No chat ID found for address " + address);
  };
}
