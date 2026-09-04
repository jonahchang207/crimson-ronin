# Installation and recovery

## Existing Arch installation

Use a normal user account that can run `sudo`. Do not run `install.sh` as root.

The complete path performs these phases:

1. Updates and installs required packages from official Arch repositories.
2. Installs `yay-bin` when no AUR helper exists, then installs Caelestia Shell.
3. Downloads the pinned Helium release and verifies its detached signature and
   published signing fingerprint before installing it under `~/.local/opt`.
4. Backs up every user configuration path it will replace.
5. Deploys Hyprland, Caelestia, Ghostty, Fastfetch, GTK, Qt, and theme assets.
6. Installs the root-owned SDDM theme and preserves the previous SDDM config.
7. Enables NetworkManager, Bluetooth, and SDDM.
8. Runs the repository doctor and reloads the live desktop when possible.

Preview the operations without changing anything:

```bash
./install.sh --dry-run --yes
```

## Full Arch installation

`install-arch.sh` only runs inside the official Arch live environment. It
refuses to start elsewhere. The script installs or updates `archinstall`, then
opens its advanced guided interface.

Recommended choices for this setup:

- UEFI with systemd-boot
- Btrfs or ext4
- Optional LUKS encryption
- PipeWire audio
- NetworkManager
- A regular user with sudo privileges
- The `linux` or `linux-zen` kernel

Review Archinstall’s final summary carefully. The disk confirmation belongs to
Archinstall, not Crimson Ronin. When installation completes, do not unmount the
target until the repository has been staged for the chosen user.

After reboot, sign into the console and run:

```bash
~/.local/share/crimson-ronin/boot.sh
```

## Helium first launch

Helium requires the user to review its service consent on first launch. The
installer does not accept terms, import browser history, or select an online
password manager on someone’s behalf. The visual theme is already active while
that screen is shown.

The bundled theme manifest contains no permissions, content scripts, network
requests, or executable extension code. It only declares browser colors and a
new-tab background image.

## Backups

User backups are stored beneath:

```text
~/.local/state/crimson-ronin/backups/YYYYMMDD-HHMMSS/
```

List or restore the newest backup:

```bash
ls ~/.local/state/crimson-ronin/backups
bin/crimson-restore
```

To restore the previous SDDM selector manually:

```bash
sudo cp /etc/sddm.conf.before-crimson-ronin /etc/sddm.conf
```

## Different monitor

Edit the first `hl.monitor(...)` line in `config/hypr/hyprland.lua` before
installation. The shipped default is deliberately capped at 144 Hz:

```lua
hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })
```
