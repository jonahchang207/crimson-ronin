#!/usr/bin/env bash

set -Eeuo pipefail

crimson_deploy_theme() {
    local pair source target
    local templates=(
        "config/hypr/hyprland.lua:.config/hypr/hyprland.lua"
        "config/hypr/hyprlock.conf:.config/hypr/hyprlock.conf"
        "config/hypr/hypridle.conf:.config/hypr/hypridle.conf"
        "config/hypr/current.lua:.config/hypr/scheme/current.lua"
        "config/ghostty/config:.config/ghostty/config"
        "config/fastfetch/config.jsonc:.config/fastfetch/config.jsonc"
        "config/caelestia/shell.json:.config/caelestia/shell.json"
        "config/caelestia/cli.json:.config/caelestia/cli.json"
        "config/gtk-3.0/gtk.css:.config/gtk-3.0/gtk.css"
        "config/gtk-3.0/settings.ini:.config/gtk-3.0/settings.ini"
        "config/gtk-3.0/thunar.css:.config/gtk-3.0/thunar.css"
        "config/gtk-4.0/gtk.css:.config/gtk-4.0/gtk.css"
        "config/gtk-4.0/settings.ini:.config/gtk-4.0/settings.ini"
        "config/gtk-4.0/thunar.css:.config/gtk-4.0/thunar.css"
        "config/Kvantum/kvantum.kvconfig:.config/Kvantum/kvantum.kvconfig"
        "config/qt6ct/qt6ct.conf:.config/qt6ct/qt6ct.conf"
        "config/mimeapps.list:.config/mimeapps.list"
        "config/xdg-terminals.list:.config/xdg-terminals.list"
        "state/caelestia/scheme.json:.local/state/caelestia/scheme.json"
    )

    crimson_log "Backing up and deploying user configuration"
    for pair in "${templates[@]}"; do
        source="${pair%%:*}"
        target="${pair#*:}"
        crimson_install_template "$CRIMSON_ROOT/$source" "$HOME/$target"
    done

    crimson_copy_tree "$CRIMSON_ROOT/config/Kvantum/CrimsonRonin" \
        "$HOME/.config/Kvantum/CrimsonRonin"
    crimson_copy_tree "$CRIMSON_ROOT/themes/gtk/CrimsonRonin" \
        "$HOME/.local/share/themes/CrimsonRonin"
    crimson_copy_tree "$CRIMSON_ROOT/assets" \
        "$HOME/.local/share/crimson-ronin/assets"

    crimson_install_environment
    crimson_apply_desktop_defaults
}

crimson_install_environment() {
    local env_file="$HOME/.config/environment.d/90-crimson-ronin.conf"
    crimson_backup "$env_file"
    crimson_run mkdir -p "$(dirname "$env_file")"
    if [[ "$CRIMSON_DRY_RUN" != 1 ]]; then
        printf '%s\n' \
            'TERMINAL=ghostty' \
            'BROWSER=helium' \
            'GTK_THEME=CrimsonRonin' \
            'QT_QPA_PLATFORMTHEME=qt6ct' \
            'QT_STYLE_OVERRIDE=kvantum' > "$env_file"
    fi
}

crimson_apply_desktop_defaults() {
    [[ "$CRIMSON_DRY_RUN" == 1 ]] && return 0
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme CrimsonRonin 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10' 2>/dev/null || true
    if command -v xfconf-query >/dev/null; then
        xfconf-query -c xsettings -p /Net/ThemeName -s CrimsonRonin 2>/dev/null || true
        xfconf-query -c xsettings -p /Net/IconThemeName -s Papirus-Dark 2>/dev/null || true
    fi
    systemctl --user set-environment TERMINAL=ghostty BROWSER=helium 2>/dev/null || true
    dbus-update-activation-environment --systemd TERMINAL=ghostty BROWSER=helium 2>/dev/null || true
}

crimson_activate_live() {
    [[ "$CRIMSON_DRY_RUN" == 1 ]] && return 0
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hyprctl reload >/dev/null || true
        caelestia wallpaper -f "$HOME/.local/share/crimson-ronin/assets/crimson-ronin-4k.png" \
            >/dev/null 2>&1 || true
        caelestia shell -d >/dev/null 2>&1 || true
    fi
}
