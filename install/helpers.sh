#!/usr/bin/env bash

set -Eeuo pipefail

CRIMSON_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRIMSON_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/crimson-ronin"
CRIMSON_BACKUP="$CRIMSON_STATE/backups/$(date +%Y%m%d-%H%M%S)"
CRIMSON_DRY_RUN="${CRIMSON_DRY_RUN:-0}"
CRIMSON_ASSUME_YES="${CRIMSON_ASSUME_YES:-0}"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    CRIMSON_RED=$'\033[38;2;226;26;40m'
    CRIMSON_WHITE=$'\033[38;2;245;242;239m'
    CRIMSON_MUTED=$'\033[38;2;144;137;139m'
    CRIMSON_RESET=$'\033[0m'
else
    CRIMSON_RED=""
    CRIMSON_WHITE=""
    CRIMSON_MUTED=""
    CRIMSON_RESET=""
fi

crimson_log() {
    printf '%s==>%s %s\n' "$CRIMSON_RED" "$CRIMSON_RESET" "$*"
}

crimson_note() {
    printf '%s    %s%s\n' "$CRIMSON_MUTED" "$*" "$CRIMSON_RESET"
}

crimson_die() {
    printf '%serror:%s %s\n' "$CRIMSON_RED" "$CRIMSON_RESET" "$*" >&2
    exit 1
}

crimson_run() {
    if [[ "$CRIMSON_DRY_RUN" == 1 ]]; then
        printf '%s[dry-run]%s' "$CRIMSON_MUTED" "$CRIMSON_RESET"
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

crimson_confirm() {
    local prompt="$1"
    [[ "$CRIMSON_ASSUME_YES" == 1 ]] && return 0
    [[ -t 0 ]] || crimson_die "Confirmation requires a terminal. Use --yes only after reviewing the script."
    read -r -p "$prompt [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

crimson_require_arch() {
    [[ -r /etc/arch-release ]] || crimson_die "This installer supports Arch Linux only."
    command -v pacman >/dev/null || crimson_die "pacman is required."
}

crimson_require_user() {
    [[ "${EUID:-$(id -u)}" -ne 0 ]] || crimson_die "Run as your regular user, not root. The installer requests sudo only for system steps."
}

crimson_backup() {
    local target="$1" relative
    [[ -e "$target" || -L "$target" ]] || return 0
    relative="${target#"$HOME"/}"
    [[ "$relative" != "$target" ]] || relative="system/${target#/}"
    crimson_run mkdir -p "$CRIMSON_BACKUP/$(dirname "$relative")"
    crimson_run cp -a "$target" "$CRIMSON_BACKUP/$relative"
}

crimson_install_template() {
    local source="$1" target="$2" mode="${3:-0644}" temporary
    crimson_backup "$target"
    crimson_run mkdir -p "$(dirname "$target")"
    if [[ "$CRIMSON_DRY_RUN" == 1 ]]; then
        crimson_note "render $source -> $target"
        return 0
    fi
    temporary="$(mktemp)"
    sed "s#__HOME__#$HOME#g" "$source" > "$temporary"
    install -m "$mode" "$temporary" "$target"
    rm -f "$temporary"
}

crimson_copy_tree() {
    local source="$1" target="$2"
    crimson_backup "$target"
    crimson_run mkdir -p "$target"
    crimson_run rsync -a --delete "$source/" "$target/"
}

crimson_banner() {
    printf '\n%sCRIMSON RONIN%s  %sRED–BLACK LIQUID GLASS%s\n' \
        "$CRIMSON_RED" "$CRIMSON_RESET" "$CRIMSON_MUTED" "$CRIMSON_RESET"
    printf '%sA focused Arch + Hyprland workstation.%s\n\n' "$CRIMSON_WHITE" "$CRIMSON_RESET"
}
