#!/usr/bin/env bash

set -Eeuo pipefail

crimson_install_packages() {
    crimson_log "Installing official Arch packages"
    crimson_run sudo pacman -Syu --needed --noconfirm "${CRIMSON_OFFICIAL_PACKAGES[@]}"
}

crimson_ensure_yay() {
    local stage
    command -v yay >/dev/null && return 0
    if [[ "$CRIMSON_DRY_RUN" == 1 ]]; then
        crimson_note "would build yay-bin from the AUR"
        return 0
    fi
    stage="$(mktemp -d)"
    crimson_log "Building yay-bin from its AUR package recipe"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$stage/yay-bin"
    (
        cd "$stage/yay-bin"
        makepkg -si --needed --noconfirm
    )
    rm -rf "$stage"
}

crimson_install_aur_packages() {
    crimson_ensure_yay
    crimson_log "Installing Caelestia Shell from the AUR"
    crimson_run yay -S --needed --noconfirm "${CRIMSON_AUR_PACKAGES[@]}"
}

crimson_enable_services() {
    crimson_log "Enabling desktop services"
    crimson_run sudo systemctl enable NetworkManager.service
    crimson_run sudo systemctl enable bluetooth.service
    crimson_run sudo systemctl enable sddm.service
}

crimson_install_sddm() {
    local source="$CRIMSON_ROOT/themes/sddm/crimson-ronin"
    local destination="/usr/share/sddm/themes/crimson-ronin"
    local virtual_keyboard_config="/etc/sddm.conf.d/virtualkbd.conf"

    crimson_log "Installing the Crimson Ronin login screen"
    [[ -f "$source/Main.qml" ]] || crimson_die "SDDM theme assets are missing."
    if [[ "$CRIMSON_DRY_RUN" == 1 ]]; then
        crimson_note "install $source -> $destination"
        crimson_note "set Current=crimson-ronin in /etc/sddm.conf"
        crimson_note "disable the SDDM virtual-keyboard override when present"
        return 0
    fi

    if [[ -f "$virtual_keyboard_config" ]]; then
        sudo mv --backup=numbered "$virtual_keyboard_config" \
            "$virtual_keyboard_config.disabled-by-crimson-ronin"
    fi

    sudo install -d -m 0755 "$destination"
    sudo rsync -a --delete "$source/" "$destination/"
    sudo chown -R root:root "$destination"

    if [[ -f /etc/sddm.conf ]]; then
        [[ -e /etc/sddm.conf.before-crimson-ronin ]] \
            || sudo cp -a /etc/sddm.conf /etc/sddm.conf.before-crimson-ronin
        if grep -q '^Current=' /etc/sddm.conf; then
            sudo sed -i 's/^Current=.*/Current=crimson-ronin/' /etc/sddm.conf
        else
            printf '%s\n' '[Theme]' 'Current=crimson-ronin' | sudo tee -a /etc/sddm.conf >/dev/null
        fi
    else
        printf '%s\n' '[Theme]' 'Current=crimson-ronin' | sudo tee /etc/sddm.conf >/dev/null
    fi
}
