#!/bin/sh

# Instala GlowKey em ~/.local/bin

set -eu

TARGET="$HOME/.local/bin/glowkey"

[ -f glowkey.sh ] || {
    echo "Erro: glowkey.sh não encontrado." >&2
    exit 1
}

mkdir -p "$HOME/.local/bin"

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
  *":$HOME/.local/bin:"*)
    echo "~/.local/bin já está no PATH."
    ;;
  *)
    echo "Adicione ao seu shell:"
    echo
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    ;;
esac
