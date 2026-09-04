#!/usr/bin/env bash

set -Eeuo pipefail

HELIUM_VERSION="${HELIUM_VERSION:-0.16.4.1}"
HELIUM_FINGERPRINT="BE677C1989D35EAB2C5F26C9351601AD01D6378E"
HELIUM_RELEASE="https://github.com/imputnet/helium-linux/releases/download/$HELIUM_VERSION"

crimson_install_helium() {
    local stage archive signature key extracted actual_fingerprint install_dir
    if [[ "$(uname -m)" != "x86_64" ]]; then
        crimson_die "Helium $HELIUM_VERSION is pinned for x86_64; found $(uname -m)."
    fi
    if [[ "$CRIMSON_DRY_RUN" == 1 ]]; then
        crimson_note "would download and verify Helium $HELIUM_VERSION"
        return 0
    fi
    stage="$(mktemp -d)"
    archive="$stage/helium.tar.xz"
    signature="$archive.asc"
    key="$stage/pubkey.asc"
    crimson_log "Downloading signed Helium $HELIUM_VERSION"
    curl -fL --retry 3 -o "$archive" \
        "$HELIUM_RELEASE/helium-$HELIUM_VERSION-x86_64_linux.tar.xz"
    curl -fL --retry 3 -o "$signature" \
        "$HELIUM_RELEASE/helium-$HELIUM_VERSION-x86_64_linux.tar.xz.asc"
    curl -fsSL -o "$key" \
        https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc

    mkdir -m 0700 "$stage/gnupg"
    gpg --homedir "$stage/gnupg" --batch --quiet --import "$key"
    actual_fingerprint="$(gpg --homedir "$stage/gnupg" --batch --with-colons --fingerprint \
        | awk -F: '$1 == "fpr" { print $10; exit }')"
    [[ "$actual_fingerprint" == "$HELIUM_FINGERPRINT" ]] \
        || crimson_die "Helium signing fingerprint did not match."
    gpg --homedir "$stage/gnupg" --batch --verify "$signature" "$archive"

    mkdir "$stage/extract"
    tar -xJf "$archive" -C "$stage/extract"
    extracted="$stage/extract/helium-$HELIUM_VERSION-x86_64_linux"
    [[ -x "$extracted/helium" ]] || crimson_die "Helium archive layout was not recognized."

    install_dir="$HOME/.local/opt/helium-$HELIUM_VERSION"
    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
    if [[ ! -x "$install_dir/helium" ]]; then
        rm -rf "$install_dir.new"
        cp -a "$extracted" "$install_dir.new"
        mv "$install_dir.new" "$install_dir"
    fi
    ln -sfn "$install_dir" "$HOME/.local/opt/helium"
    crimson_note "Verified $HELIUM_FINGERPRINT"
    rm -rf "$stage"
}

crimson_configure_helium() {
    local launcher="$HOME/.local/bin/helium"
    local desktop="$HOME/.local/share/applications/helium.desktop"

    crimson_install_template "$CRIMSON_ROOT/bin/helium" "$launcher" 0755
    crimson_install_template "$CRIMSON_ROOT/config/helium.desktop" "$desktop" 0644
    crimson_copy_tree "$CRIMSON_ROOT/themes/helium" \
        "$HOME/.local/share/crimson-ronin/helium-theme"
    crimson_run cp -f "$CRIMSON_ROOT/assets/crimson-ronin-4k.png" \
        "$HOME/.local/share/crimson-ronin/helium-theme/background.png"
    crimson_run mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
    crimson_run ln -sfn "$HOME/.local/opt/helium/product_logo_256.png" \
        "$HOME/.local/share/icons/hicolor/256x256/apps/helium.png"

    if [[ "$CRIMSON_DRY_RUN" != 1 ]]; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        xdg-mime default helium.desktop x-scheme-handler/http
        xdg-mime default helium.desktop x-scheme-handler/https
        xdg-mime default helium.desktop text/html
        xdg-settings set default-web-browser helium.desktop 2>/dev/null || true
    fi
}
