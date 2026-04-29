#!/bin/sh

# Instala GlowKey em ~/.local/share

set -eu

TARGET="$HOME/.local/share/glowkey"
# shellcheck disable=SC2016
PATH_LINE='export PATH="$HOME/.local/share:$PATH"'
# shellcheck disable=SC2016
FISH_LINE='set -gx PATH $HOME/.local/share $PATH'

[ -f glowkey.sh ] || {
    echo "Erro: glowkey.sh não encontrado." >&2
    exit 1
}

mkdir -p "$HOME/.local/share"

cp glowkey.sh "$TARGET" || {
    echo "Erro: Falha ao copiar arquivo para $TARGET." >&2
    exit 1
}
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
if [ ! -s "$AUTOSTART_DIR/glowkey.desktop" ]; then
    echo "Erro: Falha ao criar arquivo de autostart." >&2
    exit 1
fi
chmod +x "$AUTOSTART_DIR/glowkey.desktop"
echo "Auto-inicialização ativada via XDG Autostart (restaura estado na inicialização)"

# Instala systemd user service para restaurar estado no login
SYSTEMD_DIR="$HOME/.local/share/systemd/user"
mkdir -p "$SYSTEMD_DIR"
# Substitui o placeholder pelo caminho real
sed "s|@GLOWKEY_PATH@|$TARGET|g" glowkey.service > "$SYSTEMD_DIR/glowkey.service"
if [ ! -s "$SYSTEMD_DIR/glowkey.service" ]; then
    echo "Erro: Falha ao criar serviço systemd." >&2
    exit 1
fi

# Habilita o serviço (se o systemctl estiver disponível)
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable glowkey.service 2>/dev/null && \
        echo "Serviço systemd ativado (restaura estado na inicialização)"
else
    echo "systemctl não encontrado. Serviço copiado mas não ativado."
    echo "Para ativar manualmente: systemctl --user enable glowkey.service"
fi

# Verifica se o PATH já está no PATH atual
case ":$PATH:" in
    *":$HOME/.local/share:"*)
        echo "$HOME/.local/share já está no PATH atual."
        echo
        ;;
    *)
        echo "Adicionando ~/.local/share ao PATH..."
        echo
        ;;
esac

# Verifica se já está no arquivo de configuração
# Aceita tanto $HOME literal quanto o caminho expandido
EXPANDED_PATH=$(eval echo "$HOME/.local/share")

if [ -f "$SHELL_CONFIG" ]; then
    case "$SHELL_CONFIG" in
        *fish*)
            if grep -q "set -gx PATH.*\$HOME/.local/share" "$SHELL_CONFIG" 2>/dev/null || \
               grep -q "set -gx PATH.*$EXPANDED_PATH" "$SHELL_CONFIG" 2>/dev/null; then
                echo "PATH já configurado em $SHELL_CONFIG"
            else
                mkdir -p "$(dirname "$SHELL_CONFIG")"
                {
                    echo ""
                    echo "# GlowKey PATH"
                    echo "$FISH_LINE"
                } >> "$SHELL_CONFIG"
                echo "PATH adicionado ao $SHELL_CONFIG"
                echo "Reinicie o terminal ou execute: source $SHELL_CONFIG"
            fi
            ;;
        *)
            if grep -q 'export PATH.*\$HOME/.local/share' "$SHELL_CONFIG" 2>/dev/null || \
               grep -q "export PATH.*$EXPANDED_PATH" "$SHELL_CONFIG" 2>/dev/null; then
                echo "PATH já configurado em $SHELL_CONFIG"
            else
                mkdir -p "$(dirname "$SHELL_CONFIG")"
                {
                    echo ""
                    echo "# GlowKey PATH"
                    echo "$PATH_LINE"
                } >> "$SHELL_CONFIG"
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

# Verifica se a instalação funcionou
if [ -x "$TARGET" ]; then
    echo "Instalação verificada com sucesso."
else
    echo "Aviso: '$TARGET' não está acessível."
fi

# Verifica se o PATH foi configurado
if command -v glowkey >/dev/null 2>&1; then
    echo "glowkey está acessível no PATH atual."
else
    echo "Aviso: 'glowkey' ainda não está no PATH atual. Reinicie o terminal ou execute:"
    echo "  source $SHELL_CONFIG"
fi
