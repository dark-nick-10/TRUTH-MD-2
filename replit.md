# TRUTH-MD WhatsApp Bot

## Overview
TRUTH-MD is a WhatsApp Multi-Device bot relay built on Node.js using the `@whiskeysockets/baileys` library. It runs as a background worker process.

## Tech Stack
- **Runtime:** Node.js 20
- **Package Manager:** npm
- **Core Library:** @whiskeysockets/baileys (WhatsApp Web API)
- **Databases:** PostgreSQL (session/auth persistence), SQLite (local data)
- **Media:** sharp (image processing), ffmpeg, imagemagick

## Project Structure
- `index.js` — Main entry point (relay loader, obfuscated)
- `package.json` — Dependencies and scripts
- `scripts/patch-baileys.cjs` — Post-install patches for baileys library
- `Dockerfile` — Docker build instructions (for reference)
- `app.json` — Heroku deployment config (for reference)

## Running the Bot
The workflow `Start application` runs `node index.js`.

On first boot the relay:
1. Syncs bot code from secure relay server
2. Installs dependencies
3. Applies baileys patches
4. Connects to databases
5. Prompts for WhatsApp authentication (Session ID or phone number)

## Authentication
Set the `SESSION_ID` environment variable to your WhatsApp session ID (must start with `TRUTH-MD:~`) to skip the QR/phone auth prompt.

Without `SESSION_ID`, the bot will prompt for authentication on the console.

## Environment Variables
- `SESSION_ID` — WhatsApp session ID for persistent login (optional, prompts if missing)

## Workflow
- **Start application** — `node index.js` (console output type, background worker)
