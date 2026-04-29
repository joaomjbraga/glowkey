#!/bin/sh

# Remove o GlowKey instalado em ~/.local/share

set -eu

TARGET="$HOME/.local/share/glowkey"

if [ -f "$TARGET" ]; then
    rm -f "$TARGET"
    echo "GlowKey removido com sucesso."
else
    echo "GlowKey não está instalado em $TARGET"
fi
