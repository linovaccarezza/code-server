<div align="center">
  <img src="https://raw.githubusercontent.com/linovaccarezza/code-server/main/docs/assets/screenshot.png" alt="code-server screenshot" width="600"/>
  <h1>code-server LXC</h1>
  <p>
    <b>VS Code in the browser</b> — self-hosted on Proxmox LXC, ready in one command.
  </p>
  <p>
    <a href="https://coder.com/docs/code-server"><img src="https://img.shields.io/badge/docs-code--server-blue" alt="Docs"/></a>
    <a href="https://open-vsx.org/extension/Kelvin/vscode-sshfs"><img src="https://img.shields.io/badge/extension-SSH%20FS-green" alt="SSH FS"/></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-lightgrey" alt="MIT License"/></a>
  </p>
</div>

---

## What is this?

This script creates a **Proxmox LXC container** running [code-server](https://github.com/coder/code-server) — VS Code accessible from any browser — with:

- ✅ **HTTPS enabled** out of the box (required for full functionality)
- ✅ **SSH FS extension** pre-installed — edit files on remote servers via SSH, directly in the browser
- ✅ **Random password** generated at install time
- ✅ **Systemd service** — starts automatically on boot
- ✅ **Debian 13** base — lean and stable

## Why HTTPS?

code-server requires a secure context (HTTPS) for webviews, clipboard, and extensions like SSH FS to work correctly. This script enables HTTPS automatically using a self-signed certificate. Your browser will show a security warning — click **Advanced → Proceed** to continue.

## Installation

Run this command from the **Proxmox shell** (not inside a container):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/linovaccarezza/code-server/main/code-server.sh)"
```

The script will:
1. Create a Debian 13 LXC with 1 CPU, 1 GB RAM, 8 GB disk
2. Install and configure code-server with HTTPS
3. Pre-install the SSH FS extension
4. Display the generated password at the end

## Default settings

| Parameter | Default |
|-----------|---------|
| OS | Debian 13 (Trixie) |
| CPU | 1 core |
| RAM | 1024 MiB |
| Disk | 8 GB |
| Port | 8080 (HTTPS) |
| Auth | Password |
| FUSE | Enabled |
| Nesting | Enabled |

## First access

After installation, open your browser at:

```
https://<LXC_IP>:8080
```

The password is shown at the end of the installation log and saved inside the container at:

```
/root/.config/code-server/password.txt
```

## Using SSH FS

SSH FS lets you mount remote folders over SSH and edit them directly in the browser — no additional software needed on the remote server.

1. Click the SSH FS icon in the left sidebar
2. Click **New configuration**
3. Enter the remote host, username, and authentication details
4. Click **Save**, then connect

> **Note:** When opening a remote folder for the first time, code-server will show a **Workspace Trust** dialog. Click **Trust** to enable all features.

## Updating

To update Debian packages, code-server, and the SSH FS extension, access the container shell from the Proxmox web UI or via SSH, then run:

```bash
update
```

This command is installed automatically during setup and handles all three updates in one step.

## Network note

By default, the LXC is created on **vmbr0**. If your LAN runs on a different bridge (e.g. vmbr1), choose **Advanced** during installation to select the correct bridge, or change it afterwards from the Proxmox web UI.

## Credits

- [code-server](https://github.com/coder/code-server) by Coder
- [vscode-sshfs](https://github.com/SchoofsKelvin/vscode-sshfs) by Kelvin Schoofs
- Script structure inspired by [community-scripts/ProxmoxVE](https://github.com/community-scripts/ProxmoxVE)
