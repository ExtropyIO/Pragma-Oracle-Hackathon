import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import path from 'path';
import fs from 'fs';
import Checkpoint, { LogLevel } from '@snapshot-labs/checkpoint';
import config from './config.json';
import * as writers from './writers';
import checkpointBlocks from './checkpoints.json';

// TELEGRAF
import { Telegraf } from 'telegraf';
import { LocalStorage } from 'node-localstorage';
const keyStore = new LocalStorage('./scratch');

const dir = __dirname.endsWith('dist/src') ? '../' : '';
const schemaFile = path.join(__dirname, `${dir}../src/schema.gql`);
const schema = fs.readFileSync(schemaFile, 'utf8');

const checkpointOptions = {
  logLevel: LogLevel.Info,
  prettifyLogs: true, // uncomment in local dev
};

// Initialize checkpoint
// @ts-ignore
const checkpoint = new Checkpoint(config, writers, schema, checkpointOptions);

// resets the entities already created in the database
// ensures data is always fresh on each re-run
checkpoint
  .reset()
  .then(() => checkpoint.seedCheckpoints(checkpointBlocks))
  .then(() => {
    // start the indexer
    checkpoint.start();
  });

const app = express();
app.use(express.json({ limit: '4mb' }));
app.use(express.urlencoded({ limit: '4mb', extended: false }));
app.use(cors({ maxAge: 86400 }));

// mount Checkpoint's GraphQL API on path /
app.use('/', checkpoint.graphql);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Listening at http://localhost:${PORT}`));


// TELEGRAF
(() => {
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
    }
  });
  telegram.launch()
  // Enable graceful stop
  process.once('SIGINT', () => telegram.stop('SIGINT'))
  process.once('SIGTERM', () => telegram.stop('SIGTERM'))
})()
