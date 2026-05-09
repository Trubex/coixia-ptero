#!/bin/bash
# Coixia Plugin Auto-Installer
# Downloads and installs plugins from URLs specified in environment variables
# Usage: source install-plugins.sh

FRAMEWORK=${FRAMEWORK:-vanilla}

if [[ "${FRAMEWORK}" == "vanilla" ]] || [[ -z "${FRAMEWORK}" ]]; then
    echo "[Coixia] Framework is vanilla - skipping plugin installation."
    return
fi

# Determine plugin directory based on framework
if [[ "${FRAMEWORK}" == "oxide" ]]; then
    PLUGIN_DIR="/home/container/oxide/plugins"
    FRAMEWORK_NAME="Oxide"
elif [[ "${FRAMEWORK}" == "carbon" ]]; then
    PLUGIN_DIR="/home/container/carbon/plugins"
    FRAMEWORK_NAME="Carbon"
else
    echo "[Coixia] Unknown framework: ${FRAMEWORK}"
    return
fi

# Create plugin directory if it doesn't exist
mkdir -p "${PLUGIN_DIR}"

# Process plugin URLs from environment variable
# Format: comma or semicolon separated URLs
# Example: https://example.com/plugin1.cs,https://example.com/plugin2.cs

if [[ -z "${AUTO_INSTALL_PLUGINS}" ]]; then
    echo "[Coixia] No plugins to auto-install (AUTO_INSTALL_PLUGINS not set)."
    return
fi

echo "[Coixia] Installing plugins for ${FRAMEWORK_NAME}..."

# Convert semicolons and newlines to commas for consistency
PLUGIN_URLS=$(echo "${AUTO_INSTALL_PLUGINS}" | tr ';\n' ',')

# Split by comma and process each URL
IFS=',' read -ra URLS <<< "$PLUGIN_URLS"

for url in "${URLS[@]}"; do
    # Trim whitespace
    url=$(echo "$url" | xargs)
    
    # Skip empty lines
    [[ -z "$url" ]] && continue
    
    # Extract filename from URL
    filename=$(basename "$url" | cut -d'?' -f1)
    
    # Only process .cs files
    if [[ ! "$filename" =~ \.cs$ ]]; then
        echo "[Coixia] Skipping non-.cs file: $filename"
        continue
    fi
    
    echo "[Coixia] Downloading plugin: $filename from $url"
    
    # Download plugin
    if curl -sSL -o "${PLUGIN_DIR}/${filename}" "$url"; then
        echo "[Coixia] ✓ Installed: $filename"
    else
        echo "[Coixia] ✗ Failed to download: $filename"
    fi
done

echo "[Coixia] Plugin installation complete."
