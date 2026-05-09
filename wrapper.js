'use strict';

const { execSync, spawn } = require('child_process');
const WebSocket = require('/node_modules/ws');

// Get startup command from args
const args = process.argv.slice(2);
const startup = args.join(' ');

if (!startup) {
    console.error('[Coixia] No startup command provided.');
    process.exit(1);
}

console.log(`[Coixia] Starting: ${startup}`);

// Parse startup into command + args using shell
const child = spawn('/bin/bash', ['-c', startup], {
    cwd: '/home/container',
    env: process.env,
    stdio: ['pipe', 'pipe', 'pipe'],
});

child.stdout.on('data', (data) => {
    process.stdout.write(data);
});

child.stderr.on('data', (data) => {
    process.stderr.write(data);
});

child.on('close', (code) => {
    console.log(`[Coixia] Server process exited with code ${code}`);
    process.exit(code);
});

// Handle SIGTERM/SIGINT - graceful shutdown via RCON quit
const rconPort = process.env.RCON_PORT || 28016;
const rconPass = process.env.RCON_PASS || '';

let ws = null;
let connected = false;

function connectRcon() {
    if (!rconPort || !rconPass) return;

    try {
        ws = new WebSocket(`ws://localhost:${rconPort}/${rconPass}`);

        ws.on('open', () => {
            connected = true;
            console.log('[Coixia] Connected to RCON');
        });

        ws.on('error', () => {
            connected = false;
            // Retry connection after 5 seconds on error
            setTimeout(() => connectRcon(), 5000);
        });

        ws.on('close', () => {
            connected = false;
            // Retry connection after 5 seconds on close
            setTimeout(() => connectRcon(), 5000);
        });
    } catch (e) {
        // Ignore connection errors during startup, retry later
        setTimeout(() => connectRcon(), 5000);
    }
}

// Start attempting RCON connection after 30s to give server time to boot
setTimeout(() => {
    connectRcon();
}, 30000);

process.on('SIGTERM', () => {
    console.log('[Coixia] Received SIGTERM, sending quit to server...');
    if (connected && ws) {
        ws.send(JSON.stringify({ Identifier: -1, Message: 'quit', Name: 'WebRcon' }));
        setTimeout(() => process.exit(0), 5000);
    } else {
        child.kill('SIGTERM');
    }
});

process.on('SIGINT', () => {
    console.log('[Coixia] Received SIGINT, shutting down...');
    if (connected && ws) {
        ws.send(JSON.stringify({ Identifier: -1, Message: 'quit', Name: 'WebRcon' }));
        setTimeout(() => process.exit(0), 5000);
    } else {
        child.kill('SIGINT');
    }
});
