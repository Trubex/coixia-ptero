# Coixia Rust Dedicated Server Image

Docker image for running Rust dedicated servers on Wisp/Pterodactyl panels.

**Maintained by:** [Coixia LLC](https://coixia.com) | support@coixia.com

## Image

```
ghcr.io/coixia/rust:latest
```

## What's included

- Debian Bookworm Slim base
- Node.js 20
- SteamCMD (bundled)
- ws WebSocket package for Wisp RCON wrapper
- All Rust dedicated server dependencies (lib32gcc, lib32stdc++, libgdiplus)
- Auto-update on startup via SteamCMD
- uMod/Oxide auto-update support
- Staging/aux branch support via `SRCDS_BETAID`

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `AUTO_UPDATE` | Run SteamCMD update on startup | `1` |
| `SRCDS_BETAID` | Branch: `public`, `staging`, `aux01`, `aux02`, `aux03` | `public` |
| `FRAMEWORK` | Modding framework: `vanilla`, `oxide` | `vanilla` |
| `STARTUP` | Full startup command (set by Wisp automatically) | - |
| `RCON_PORT` | RCON port for graceful shutdown | `28016` |
| `RCON_PASS` | RCON password for graceful shutdown | - |

## Building locally

```bash
docker build -t coixia-rust:latest .
```

## Notes

- The image handles SteamCMD updates internally — no need for it in the egg install script
- Startup command is passed via the `STARTUP` env var set by Wisp after variable substitution
- The wrapper runs startup through `/bin/bash -c` so quoting is handled correctly
