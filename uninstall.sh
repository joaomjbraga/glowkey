#!/bin/sh

# Remove o GlowKey instalado em ~/.local/share

set -eu

TARGET="$HOME/.local/share/glowkey"

# Remove arquivo de autostart
AUTOSTART_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/autostart/glowkey.desktop"
if [ -f "$AUTOSTART_FILE" ]; then
    rm -f "$AUTOSTART_FILE"
    echo "Auto-inicialização removida."
fi

# Remove diretório de estado
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/glowkey"
if [ -d "$STATE_DIR" ]; then
    rm -rf "$STATE_DIR"
    echo "Estado salvo removido."
fi

# Remove executável
if [ -f "$TARGET" ]; then
    rm -f "$TARGET"
    echo "GlowKey removido com sucesso."
else
    echo "GlowKey não está instalado em $TARGET"
fi
