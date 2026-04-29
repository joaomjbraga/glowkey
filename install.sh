#!/bin/sh

# Instala GlowKey em ~/.local/bin

set -eu

TARGET="$HOME/.local/share/glowkey"

[ -f glowkey.sh ] || {
    echo "Erro: glowkey.sh não encontrado." >&2
    exit 1
}

mkdir -p "$HOME/.local/share"

cp glowkey.sh "$TARGET"
chmod +x "$TARGET"

echo "GlowKey instalado com sucesso em $TARGET"
echo

echo "Comandos disponíveis:"
echo "  glowkey on"
echo "  glowkey off"
echo "  glowkey toggle"
echo "  glowkey status"
echo

case ":$PATH:" in
  *":$HOME/.local/share:"*)
    echo "~/.local/share já está no PATH."
    ;;
  *)
    echo "Adicione ao seu shell:"
    echo
    echo 'export PATH="$HOME/.local/share:$PATH"'
    ;;
esac
