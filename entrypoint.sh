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
# SteamCMD Auto Update
# ----------------------------------------
if [[ "${AUTO_UPDATE}" == "1" ]] || [[ -z "${AUTO_UPDATE}" ]]; then
    echo -e "${CYAN}[Coixia] Running SteamCMD update...${NC}"

    # Build beta flag
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
        +app_update 258550 ${BETA_FLAG} \
        +quit

    echo -e "${GREEN}[Coixia] Update complete.${NC}"
else
    echo -e "${YELLOW}[Coixia] Auto update disabled, skipping SteamCMD.${NC}"
fi

# ----------------------------------------
# uMod (Oxide) Update
# ----------------------------------------
if [[ "${FRAMEWORK}" == "oxide" ]]; then
    echo -e "${CYAN}[Coixia] Updating uMod/Oxide...${NC}"
    OXIDE_URL="https://umod.org/games/rust/download/develop"
    curl -sSL -o /tmp/oxide.zip "${OXIDE_URL}"
    if [[ $? -eq 0 ]]; then
        unzip -o /tmp/oxide.zip -d /home/container > /dev/null 2>&1
        rm /tmp/oxide.zip
        echo -e "${GREEN}[Coixia] uMod updated.${NC}"
    else
        echo -e "${RED}[Coixia] Failed to download uMod, skipping.${NC}"
    fi
else
    echo -e "${CYAN}[Coixia] Framework: ${FRAMEWORK:-vanilla}, skipping uMod update.${NC}"
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
