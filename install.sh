#!/usr/bin/env bash

set -Eeuo pipefail

CRIMSON_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CRIMSON_ROOT

mode="full"
install_helium=1
install_sddm=1

usage() {
    cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --theme-only     Deploy configuration and visual assets; do not install packages
  --skip-helium    Leave the current default browser unchanged
  --skip-sddm      Leave the current display-manager theme unchanged
  --dry-run        Print actions without changing the system
  --yes            Accept the single installation confirmation
  -h, --help       Show this help
USAGE
}

while (($#)); do
    case "$1" in
        --theme-only) mode="theme" ;;
        --skip-helium) install_helium=0 ;;
        --skip-sddm) install_sddm=0 ;;
        --dry-run) export CRIMSON_DRY_RUN=1 ;;
        --yes) export CRIMSON_ASSUME_YES=1 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

source "$CRIMSON_ROOT/install/helpers.sh"
source "$CRIMSON_ROOT/install/packages.sh"
source "$CRIMSON_ROOT/install/system.sh"
source "$CRIMSON_ROOT/install/theme.sh"
source "$CRIMSON_ROOT/install/helium.sh"

crimson_banner
crimson_require_arch
crimson_require_user

crimson_note "mode: $mode"
crimson_note "backup: $CRIMSON_BACKUP"
crimson_note "monitor invariant: DP-1 1920x1080 @ 144 Hz"

crimson_confirm "Install Crimson Ronin for user $USER?" || crimson_die "Installation cancelled."

if [[ "$mode" == "full" ]]; then
    crimson_install_packages
    crimson_install_aur_packages
    crimson_enable_services
fi

crimson_deploy_theme

if [[ "$install_helium" == 1 ]]; then
    if [[ "$mode" == "full" || -x "$HOME/.local/opt/helium/helium" ]]; then
        [[ "$mode" == "theme" ]] || crimson_install_helium
        crimson_configure_helium
    else
        crimson_note "Helium is not installed; rerun without --theme-only to install it."
    fi
fi

if [[ "$install_sddm" == 1 ]]; then
    crimson_install_sddm
fi

crimson_activate_live

if [[ "$CRIMSON_DRY_RUN" != 1 ]]; then
    mkdir -p "$CRIMSON_STATE"
    printf '%s\n' "$(date -Is)" > "$CRIMSON_STATE/installed-at"
    "$CRIMSON_ROOT/bin/crimson-doctor" --quiet
fi

printf '\n%sInstalled.%s Backups: %s\n' "$CRIMSON_RED" "$CRIMSON_RESET" "$CRIMSON_BACKUP"
printf 'Log out once for every environment and portal setting to take effect.\n'
if [[ "$install_helium" == 1 ]]; then
    printf 'On Helium’s first launch, review its service consent and import choices.\n'
fi
