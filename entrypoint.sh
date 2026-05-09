#!/bin/bash
# Coixia Rust Server Entrypoint
# support@coixia.com

# ----------------------------------------
# Colors
# ----------------------------------------
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
echo "  ██████╗ ██████╗ ██╗██╗  ██╗██╗ █████╗ "
echo " ██╔════╝██╔═══██╗██║╚██╗██╔╝██║██╔══██╗"
echo " ██║     ██║   ██║██║ ╚███╔╝ ██║███████║"
echo " ██║     ██║   ██║██║ ██╔██╗ ██║██╔══██║"
echo " ╚██████╗╚██████╔╝██║██╔╝ ██╗██║██║  ██║"
echo "  ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${GREEN}  Coixia Rust Dedicated Server Image${NC}"
echo -e "${GREEN}  support@coixia.com${NC}"
echo ""

cd /home/container

# ----------------------------------------
# Strip -beta flag from startup if no branch set
# Wisp pre-substitutes ${SRCDS_BETAID} before the container starts,
# so an empty value leaves "-beta " with no argument. Strip it here.
# ----------------------------------------
if [[ -z "${SRCDS_BETAID}" ]]; then
    STARTUP=$(echo "${STARTUP}" | sed 's/ -beta[[:space:]]*//')
fi

# ----------------------------------------
# Bootstrap SteamCMD into the persistent volume on first boot.
# It must live in /home/container/steamcmd so it can self-update
# normally — Pterodactyl mounts a volume at /home/container so
# anything baked into the image there gets masked.
# ----------------------------------------
if [[ ! -f "/home/container/steamcmd/steamcmd.sh" ]]; then
    echo -e "${CYAN}[Coixia] Installing SteamCMD...${NC}"
    mkdir -p /home/container/steamcmd
    curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
        | tar -xzvf - -C /home/container/steamcmd
    echo -e "${GREEN}[Coixia] SteamCMD installed.${NC}"
fi

# ----------------------------------------
# SteamCMD Auto Update
# ----------------------------------------
if [[ "${AUTO_UPDATE}" == "1" ]] || [[ -z "${AUTO_UPDATE}" ]]; then
    echo -e "${CYAN}[Coixia] Running SteamCMD update...${NC}"

    # Build beta flag for SteamCMD
    BETA_FLAG=""
    if [[ -n "${SRCDS_BETAID}" ]]; then
        BETA_FLAG="-beta ${SRCDS_BETAID}"
        echo -e "${YELLOW}[Coixia] Using branch: ${SRCDS_BETAID}${NC}"
    else
        echo -e "${CYAN}[Coixia] Using branch: public (standard)${NC}"
    fi

    /home/container/steamcmd/steamcmd.sh \
        +force_install_dir /home/container \
        +login anonymous \
        +app_update ${SRCDS_APPID:-258550} ${BETA_FLAG} \
        +quit

    echo -e "${GREEN}[Coixia] Update complete.${NC}"
else
    echo -e "${YELLOW}[Coixia] Auto update disabled, skipping SteamCMD.${NC}"
fi

# ----------------------------------------
# Modding Framework Setup
# ----------------------------------------
FRAMEWORK=${FRAMEWORK:-vanilla}

if [[ "${FRAMEWORK}" == "oxide" ]]; then
    echo -e "${CYAN}[Coixia] Setting up uMod/Oxide...${NC}"
    OXIDE_URL="https://umod.org/games/rust/download/develop"
    
    mkdir -p /home/container/oxide/plugins /home/container/oxide/data /home/container/oxide/config
    
    curl -sSL -o /tmp/oxide.zip "${OXIDE_URL}"
    if [[ $? -eq 0 ]]; then
        unzip -o /tmp/oxide.zip -d /home/container > /dev/null 2>&1
        rm /tmp/oxide.zip
        echo -e "${GREEN}[Coixia] uMod/Oxide (develop) installed successfully.${NC}"
    else
        echo -e "${RED}[Coixia] Failed to download Oxide.${NC}"
    fi
elif [[ "${FRAMEWORK}" == "carbon" ]]; then
    echo -e "${CYAN}[Coixia] Setting up Carbon...${NC}"
    CARBON_URL="https://github.com/CarbonCommunity/Carbon/releases/download/latest/Carbon.zip"
    
    mkdir -p /home/container/carbon/plugins /home/container/carbon/data /home/container/carbon/config
    
    curl -sSL -L -o /tmp/carbon.zip "${CARBON_URL}"
    if [[ $? -eq 0 ]]; then
        unzip -o /tmp/carbon.zip -d /home/container > /dev/null 2>&1
        rm /tmp/carbon.zip
        echo -e "${GREEN}[Coixia] Carbon (latest) installed successfully.${NC}"
    else
        echo -e "${RED}[Coixia] Failed to download Carbon.${NC}"
    fi
elif [[ "${FRAMEWORK}" == "vanilla" ]]; then
    echo -e "${CYAN}[Coixia] Framework: vanilla (no mods).${NC}"
else
    echo -e "${RED}[Coixia] Unknown framework: ${FRAMEWORK}. Use 'vanilla', 'oxide', or 'carbon'.${NC}"
fi

# ----------------------------------------
# Set library path for Rust
# ----------------------------------------
export LD_LIBRARY_PATH=$(pwd)/RustDedicated_Data/Plugins/x86_64:$(pwd)

echo ""
echo -e "${GREEN}[Coixia] Starting server...${NC}"
echo ""

# ----------------------------------------
# Run the server via Wisp wrapper
# The STARTUP env var is set by Wisp with
# all {{VAR}} substitutions already done.
# We eval it through bash to handle quoting.
# ----------------------------------------
node /wrapper.js "${STARTUP}"
