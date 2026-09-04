#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[[ "$EUID" -eq 0 ]] || die "Run this entry point with sudo or as root from the Arch ISO."
[[ -e /run/archiso/bootmnt ]] || die "Full installation is allowed only from the official Arch live environment."
command -v pacman >/dev/null || die "pacman is unavailable."

cat <<'INTRO'

CRIMSON RONIN // ARCH INSTALL

The next screen is Arch Linux's official advanced installer. It owns all
destructive disk operations and lets you choose:

  • disk layout and filesystem
  • optional LUKS encryption
  • systemd-boot, GRUB, Limine, or another supported boot method
  • kernel, locale, timezone, hostname, networking, and user accounts

No disk is touched before archinstall shows its final configuration and asks
for confirmation. Crimson Ronin does not replace that safety boundary.

INTRO

read -r -p 'Launch official archinstall now? [y/N] ' answer
[[ "$answer" =~ ^[Yy]$ ]] || die "Cancelled before any disk changes."

pacman -Sy --needed --noconfirm archinstall git rsync
archinstall --advanced

target=""
for candidate in /mnt/archinstall /mnt; do
    if [[ -f "$candidate/etc/os-release" ]]; then
        target="$candidate"
        break
    fi
done

if [[ -z "$target" ]]; then
    printf '\nArchinstall exited without a mounted target. No Crimson Ronin files were staged.\n'
    exit 0
fi

mapfile -t users < <(find "$target/home" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
if ((${#users[@]} == 0)); then
    printf '\nBase installation found at %s, but no regular user home exists.\n' "$target"
    printf 'Create a sudo-capable user in archinstall, then rerun this staging step.\n'
    exit 0
fi

if ((${#users[@]} == 1)); then
    target_user="${users[0]}"
else
    printf '\nInstalled user homes:\n'
    printf '  %s\n' "${users[@]}"
    read -r -p 'User that should receive Crimson Ronin: ' target_user
    [[ " ${users[*]} " == *" $target_user "* ]] || die "That installed user was not found."
fi

destination="$target/home/$target_user/.local/share/crimson-ronin"
install -d -m 0755 "$destination"
rsync -a --delete --exclude .git "$ROOT/" "$destination/"
arch-chroot "$target" chown -R "$target_user:$target_user" "/home/$target_user/.local/share/crimson-ronin"

profile_note="$target/etc/profile.d/crimson-ronin-first-login.sh"
cat > "$profile_note" <<EOF
if [[ \$- == *i* && -x /home/$target_user/.local/share/crimson-ronin/boot.sh && ! -e /home/$target_user/.local/state/crimson-ronin/installed-at ]]; then
    printf '\nCrimson Ronin is staged. Run:\n  ~/.local/share/crimson-ronin/boot.sh\n\n'
fi
EOF
chmod 0644 "$profile_note"

printf '\nCrimson Ronin was staged for %s.\n' "$target_user"
printf 'After reboot, log in on the console and run ~/.local/share/crimson-ronin/boot.sh\n'
