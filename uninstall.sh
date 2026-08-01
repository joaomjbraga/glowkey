#!/bin/sh

set -eu

TARGET="$HOME/.local/bin/glowkey"
PATH_PATTERN='GlowKey PATH'

AUTOSTART_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/autostart/glowkey.desktop"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/glowkey"

echo "Desinstalando GlowKey..."
echo

# Remove autostart
if [ -f "$AUTOSTART_FILE" ]; then
    rm -f "$AUTOSTART_FILE"
    echo "✓ Auto-inicialização removida."
fi

# Remove estado salvo
if [ -d "$STATE_DIR" ]; then
    rm -rf "$STATE_DIR"
    echo "✓ Estado salvo removido."
fi

# Remove executável
if [ -f "$TARGET" ]; then
    rm -f "$TARGET"
    echo "✓ Executável removido."
else
    echo "Executável não encontrado."
fi

echo
echo "Limpando configurações do PATH..."

for config_file in \
    "$HOME/.bashrc" \
    "$HOME/.zshrc" \
    "$HOME/.zprofile" \
    "$HOME/.profile" \
    "$HOME/.config/fish/config.fish"
do
    [ -f "$config_file" ] || continue

    if grep -q "$PATH_PATTERN" "$config_file" 2>/dev/null; then

        cp -p "$config_file" "$config_file.bak"

        awk '
            /^# GlowKey PATH$/ { skip=1; next }
            skip && /(\.local\/bin)/ { skip=0; next }
            !skip { print }
        ' "$config_file.bak" > "$config_file.tmp"

        mv "$config_file.tmp" "$config_file"

        echo "✓ Limpo: $config_file"
        echo "  Backup: $config_file.bak"
    fi
done

echo
echo "GlowKey removido com sucesso."