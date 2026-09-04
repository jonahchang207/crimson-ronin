#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

choose_mode() {
    if command -v whiptail >/dev/null && [[ -t 0 ]]; then
        whiptail --title "Crimson Ronin" --menu \
            "Choose a setup path" 17 72 6 \
            1 "Complete desktop on an existing Arch installation" \
            2 "Theme-only refresh with automatic backups" \
            3 "Install Arch first using official archinstall" \
            4 "Verify this repository and the current machine" \
            5 "Exit" \
            3>&1 1>&2 2>&3
        return
    fi

    printf '%s\n' \
        'CRIMSON RONIN' \
        '1) Complete desktop on existing Arch' \
        '2) Theme-only refresh' \
        '3) Install Arch with official archinstall' \
        '4) Verify repository and machine' \
        '5) Exit' >&2
    read -r -p 'Selection: ' choice >&2
    printf '%s\n' "$choice"
}

case "$(choose_mode)" in
    1) exec "$ROOT/install.sh" ;;
    2) exec "$ROOT/install.sh" --theme-only ;;
    3)
        if (( EUID == 0 )); then
            exec "$ROOT/install-arch.sh"
        fi
        exec sudo "$ROOT/install-arch.sh"
        ;;
    4) exec "$ROOT/bin/crimson-doctor" ;;
    5|"") exit 0 ;;
    *) printf 'Invalid selection.\n' >&2; exit 2 ;;
esac
