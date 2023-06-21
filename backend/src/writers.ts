import { hexStrArrToStr, toAddress } from './utils';
import type { CheckpointWriter } from '@snapshot-labs/checkpoint';
import { getChecksumAddress, validateChecksumAddress } from 'starknet';

import { Telegraf } from 'telegraf';
import { LocalStorage } from 'node-localstorage';
const keyStore = new LocalStorage('./scratch');

export async function handleDeploy() {
  // Run logic as at the time Contract was deployed.
}

export async function handleAnything({ block, tx, rawEvent, mysql }: Parameters<CheckpointWriter>[0]) {
console.log('HANDLE ANYTHING')
//  if (!event) return;
console.log('EVENT')
console.log({rawEvent})
console.log('send message')
  let wallet = rawEvent && toAddress(rawEvent.data[0]);
  wallet = getChecksumAddress(wallet) || true
  const msg = 'Recovery'
  sendTelegramMsg(wallet, msg)
}

// This decodes the new_post events data and stores successfully
// decoded information in the `posts` table.
//
// See here for the original logic used to create post transactions:
// https://gist.github.com/perfectmak/417a4dab69243c517654195edf100ef9#file-index-ts
export async function handleNewPost({ block, tx, event, mysql }: Parameters<CheckpointWriter>[0]) {
  if (!event) return;

  const author = toAddress(event.data[0]);
  let content = '';
  let tag = '';
  const contentLength = BigInt(event.data[1]);
  const tagLength = BigInt(event.data[2 + Number(contentLength)]);
  const timestamp = block && block.timestamp;
  const blockNumber = block && block.block_number;

  // parse content bytes
  try {
    content = hexStrArrToStr(event.data, 2, contentLength);
  } catch (e) {
    console.error(`failed to decode content on block [${blockNumber}]: ${e}`);
    return;
  }

  // parse tag bytes
  try {
    tag = hexStrArrToStr(event.data, 3 + Number(contentLength), tagLength);
  } catch (e) {
    console.error(`failed to decode tag on block [${blockNumber}]: ${e}`);
    return;
  }

  // post object matches fields of Post type in schema.gql
  const post = {
    id: `${author}/${tx.transaction_hash}`,
    author,
    content,
    tag,
    tx_hash: tx.transaction_hash,
    created_at: timestamp,
    created_at_block: blockNumber
  };

  // table names are `lowercase(TypeName)s` and can be interacted with sql
  await mysql.queryAsync('INSERT IGNORE INTO posts SET ?', [post]);
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
