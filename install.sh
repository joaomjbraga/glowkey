#!/bin/sh

set -eu

TARGET_DIR="$HOME/.local/bin"
TARGET="$TARGET_DIR/glowkey"

# shellcheck disable=SC2016
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
# shellcheck disable=SC2016
FISH_LINE='set -gx PATH $HOME/.local/bin $PATH'

[ -f glowkey.sh ] || {
    echo "Erro: glowkey.sh não encontrado." >&2
    exit 1
}

mkdir -p "$TARGET_DIR"

install -m755 glowkey.sh "$TARGET"

echo "GlowKey instalado em:"
echo "  $TARGET"
echo

echo "Comandos disponíveis:"
echo "  glowkey on"
echo "  glowkey off"
echo "  glowkey toggle"
echo "  glowkey status"
echo

detect_shell_config() {
    case "$(basename "${SHELL:-sh}")" in
        bash) echo "$HOME/.bashrc" ;;
        zsh) echo "$HOME/.zshrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *) echo "$HOME/.profile" ;;
    esac
}

SHELL_CONFIG=$(detect_shell_config)

AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
mkdir -p "$AUTOSTART_DIR"

if [ ! -f glowkey.desktop ]; then
    echo "Erro: glowkey.desktop não encontrado." >&2
    exit 1
fi

sed "s|@GLOWKEY_PATH@|$TARGET|g" glowkey.desktop \
    > "$AUTOSTART_DIR/glowkey.desktop"

chmod +x "$AUTOSTART_DIR/glowkey.desktop"

echo "Auto-inicialização configurada."
echo

case ":$PATH:" in
    *":$TARGET_DIR:"*)
        echo "$TARGET_DIR já está no PATH."
        ;;
    *)
        echo "Configurando PATH..."

        case "$SHELL_CONFIG" in
            *fish*)
                if ! grep -q "$TARGET_DIR" "$SHELL_CONFIG" 2>/dev/null; then
                    mkdir -p "$(dirname "$SHELL_CONFIG")"

                    {
                        echo
                        echo "# GlowKey PATH"
                        echo "$FISH_LINE"
                    } >> "$SHELL_CONFIG"

                    echo "PATH adicionado ao $SHELL_CONFIG"
                fi
                ;;
            *)
                if ! grep -q "$TARGET_DIR" "$SHELL_CONFIG" 2>/dev/null; then
                    mkdir -p "$(dirname "$SHELL_CONFIG")"

                    {
                        echo
                        echo "# GlowKey PATH"
                        echo "$PATH_LINE"
                    } >> "$SHELL_CONFIG"

                    echo "PATH adicionado ao $SHELL_CONFIG"
                fi
                ;;
        esac
        ;;
esac

echo

if command -v glowkey >/dev/null 2>&1; then
    echo "GlowKey disponível no PATH."
else
    echo "Reabra o terminal ou execute:"
    echo
    echo "  source $SHELL_CONFIG"
    echo
fi

echo "Ativando iluminação..."

if "$TARGET" on; then
    echo "Backlight ativado."
else
    echo "Sessão gráfica ainda não disponível."
    echo "O estado será restaurado automaticamente no próximo login."

    STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/glowkey"
    mkdir -p "$STATE_DIR"
    echo "on" > "$STATE_DIR/state"
fi

echo
echo "Instalação concluída."