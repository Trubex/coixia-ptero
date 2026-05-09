# Coixia Rust Server - Wisp Mod Installation Guide

This guide helps Wisp panel admins and server owners set up and manage Rust mods with the Coixia Rust image.

## Quick Start

### 1. Create Server with Coixia Egg
- In Wisp panel: **New Server → Select Coixia Rust egg**
- Allocate **4 ports** minimum:
  1. Server port (default 28015)
  2. Query port (default 28017)
  3. RCON port (default 28016)
  4. App port (Rust+ integration, optional)

### 2. Choose Your Modding Framework

#### **Vanilla (No Mods)**
- **FRAMEWORK**: `vanilla`
- **OXIDE_CHANNEL**: (ignored)
- **CARBON_VERSION**: (ignored)
- Fastest performance, official Rust only

#### **Oxide/uMod (Most Popular)**
- **FRAMEWORK**: `oxide`
- **OXIDE_CHANNEL**: 
  - `develop` - Latest features (may be less stable)
  - `legacy` - Stable releases
- Mods directory: `/oxide/plugins/` (in Wisp file manager)
- Config directory: `/oxide/config/`

#### **Carbon (Modern Alternative)**
- **FRAMEWORK**: `carbon`
- **CARBON_VERSION**: 
  - `latest` - Newest release
  - Specific: `v1.1.5` or other GitHub release tags
- Mods directory: `/carbon/plugins/` (in Wisp file manager)
- Config directory: `/carbon/config/`

---

## Installing Mods

### Method 1: Auto-Install from URLs (Easiest)

Perfect for quick setup or deploying server templates!

1. In Wisp: **Server Settings → Variables**
2. Find **Auto-Install Plugins** field
3. Enter plugin URLs (comma or semicolon-separated):
   ```
   https://example.com/plugin1.cs,https://example.com/plugin2.cs
   ```
   Or paste multiple lines:
   ```
   https://raw.githubusercontent.com/user/repo/main/plugin1.cs
   https://raw.githubusercontent.com/user/repo/main/plugin2.cs
   ```
4. **Save and restart server**
5. Plugins auto-download and install during startup

**Note**: Only works if FRAMEWORK is set to `oxide` or `carbon`

### Method 2: Via Wisp File Manager (Recommended for Manual Management)

1. **Start the server** with your chosen framework (oxide or carbon)
2. In Wisp: **File Manager → Navigate to mod directory**
   - Oxide: `oxide/plugins/`
   - Carbon: `carbon/plugins/`
3. **Upload** `.cs` plugin files
4. **Restart server** - plugins auto-load on startup

### Method 3: Via SFTP/SSH

```bash
# Connect to your server via SFTP
sftp://your.server.ip:port

# Navigate to plugins folder
cd oxide/plugins/    # for Oxide
cd carbon/plugins/   # for Carbon

# Upload .cs files
put my_plugin.cs
```

---

## Auto-Install Examples

### Popular Free Plugins

**Oxide Plugins** (from uMod):
```
https://umod.org/plugins/AdminUI.cs,https://umod.org/plugins/Kits.cs,https://umod.org/plugins/Economics.cs
```

**GitHub-Hosted Plugins**:
```
https://raw.githubusercontent.com/Oxide-Community/Oxide.Rust/develop/plugins/Kits.cs
https://raw.githubusercontent.com/OxideMod/Oxide.Rust/develop/plugins/Economics.cs
```

### Template Setup (Copy & Paste)

**Vanilla Server (No Mods)**:
- FRAMEWORK: `vanilla`
- AUTO_INSTALL_PLUGINS: (leave empty)

**Modded Server (Essential Plugins)**:
- FRAMEWORK: `oxide`
- OXIDE_CHANNEL: `develop`
- AUTO_INSTALL_PLUGINS: `[list your URLs here]`

**Carbon Server**:
- FRAMEWORK: `carbon`
- CARBON_VERSION: `latest`
- AUTO_INSTALL_PLUGINS: `[list your URLs here]`

---

## Common Mod Management Tasks

### Installing Oxide Plugins
Popular Oxide plugin sources:
- **uMod Repository**: https://umod.org/plugins
- **GitHub**: Search "rust oxide plugin"

Steps:
1. Find plugin `.cs` file
2. Upload to `oxide/plugins/`
3. Restart server
4. Check **Console** for plugin load messages

### Installing Carbon Plugins
Popular Carbon sources:
- **Carbon Community**: https://github.com/CarbonCommunity
- **uMod plugins** (some compatible)

Steps:
1. Download `.cs` file or clone repository
2. Place in `carbon/plugins/`
3. Restart server

### Managing Plugin Permissions (Oxide)
Permission files are in `/oxide/config/`

Example config layout:
```
oxide/
├── plugins/
│   ├── MyAwesomePlugin.cs
│   └── AnotherPlugin.cs
├── config/
│   ├── MyAwesomePlugin.json
│   └── AnotherPlugin.json
└── data/
    └── plugin-specific-data.json
```

---

## Troubleshooting

### Mods not loading?
1. **Check console** for error messages in Wisp panel
2. **Verify FRAMEWORK setting** - must match your plugins
3. **Restart server** - new plugins require restart
4. **Check file location** - must be in `/oxide/plugins/` or `/carbon/plugins/`

### Server won't start
1. **Syntax error in plugin** - check console for errors
2. **Incompatible plugin** - remove problematic `.cs` file
3. **Out of memory** - reduce number of plugins, increase server RAM

### Switch between Oxide and Carbon
⚠️ **Cannot run both simultaneously**
1. Set `FRAMEWORK` to desired platform
2. **Stop and restart server**
3. Plugins from opposite framework will not load

---

## Performance Tips

- **Oxide** is lighter and more stable
- **Carbon** is modern but uses slightly more resources
- Start with fewer plugins, add as needed
- Monitor **Console** for plugin errors consuming CPU

---

## Advanced Configuration

### Custom Oxide Channel
In Wisp variables, change:
- **OXIDE_CHANNEL** to `develop` or `legacy`

### Custom Carbon Version
In Wisp variables, change:
- **CARBON_VERSION** to specific release (e.g., `v1.1.5`)
- Check https://github.com/CarbonCommunity/Carbon/releases for valid versions

### Additional Startup Parameters
Use the **Additional Arguments** variable to pass custom Rust server parameters:
```
+server.levelurl "https://example.com/custom.map" +other.param value
```

---

## Support

For issues:
1. Check Console in Wisp panel
2. Verify mod compatibility with your framework
3. Check plugin documentation
4. Contact: support@coixia.com

---

**Last Updated**: May 2026 | **Image**: ghcr.io/trubex/rust:latest
