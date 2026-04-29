#!/bin/sh

# Instala GlowKey em ~/.local/share

set -eu

TARGET="$HOME/.local/share/glowkey"
PATH_LINE='export PATH="$HOME/.local/share:$PATH"'
FISH_LINE='set -gx PATH $HOME/.local/share $PATH'

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

# Detecta o shell e o arquivo de configuração
detect_shell_config() {
    shell_name=$(basename "${SHELL:-/bin/sh}")
    case "$shell_name" in
        bash)  echo "$HOME/.bashrc" ;;
        zsh)   echo "$HOME/.zshrc" ;;
        fish)  echo "$HOME/.config/fish/config.fish" ;;
        *)     echo "$HOME/.profile" ;;
    esac
}

SHELL_CONFIG=$(detect_shell_config)

# Instala autostart para restaurar estado no login
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
mkdir -p "$AUTOSTART_DIR"
# Substitui o placeholder pelo caminho real
sed "s|@GLOWKEY_PATH@|$TARGET|g" glowkey.desktop > "$AUTOSTART_DIR/glowkey.desktop"
chmod +x "$AUTOSTART_DIR/glowkey.desktop"
echo "Auto-inicialização ativada (restaura estado na inicialização)"

# Verifica se o PATH já está no PATH atual
case ":$PATH:" in
    *":$HOME/.local/share:"*)
        echo "~/.local/share já está no PATH atual."
        echo
        ;;
    *)
        echo "Adicionando ~/.local/share ao PATH..."
        echo
        ;;
esac

# Verifica se a instalação funcionou
if command -v glowkey >/dev/null 2>&1; then
    echo "Instalação verificada com sucesso."
else
    echo "Aviso: 'glowkey' ainda não está acessível. Reinicie o terminal ou execute:"
    echo "  source $SHELL_CONFIG"
fi

# Verifica se já está no arquivo de configuração
if [ -f "$SHELL_CONFIG" ]; then
    case "$SHELL_CONFIG" in
        *fish*)
            if grep -q 'set -gx PATH.*\$HOME/.local/share' "$SHELL_CONFIG" 2>/dev/null; then
                echo "PATH já configurado em $SHELL_CONFIG"
            else
                mkdir -p "$(dirname "$SHELL_CONFIG")"
                echo "" >> "$SHELL_CONFIG"
                echo "# GlowKey PATH" >> "$SHELL_CONFIG"
                echo "$FISH_LINE" >> "$SHELL_CONFIG"
                echo "PATH adicionado ao $SHELL_CONFIG"
                echo "Reinicie o terminal ou execute: source $SHELL_CONFIG"
            fi
            ;;
        *)
            if grep -q 'export PATH.*\$HOME/.local/share' "$SHELL_CONFIG" 2>/dev/null; then
                echo "PATH já configurado em $SHELL_CONFIG"
            else
                echo "" >> "$SHELL_CONFIG"
                echo "# GlowKey PATH" >> "$SHELL_CONFIG"
                echo "$PATH_LINE" >> "$SHELL_CONFIG"
                echo "PATH adicionado ao $SHELL_CONFIG"
                echo "Reinicie o terminal ou execute: source $SHELL_CONFIG"
            fi
            ;;
    esac
else
    mkdir -p "$(dirname "$SHELL_CONFIG")"
    echo "$PATH_LINE" >> "$SHELL_CONFIG"
    echo "Arquivo $SHELL_CONFIG criado com o PATH configurado."
    echo "Reinicie o terminal ou execute: source $SHELL_CONFIG"
fi
