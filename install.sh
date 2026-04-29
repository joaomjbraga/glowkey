#!/bin/sh

# Instala GlowKey em ~/.local/bin

set -eu

TARGET="$HOME/.local/bin/glowkey"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
FISH_LINE='set -gx PATH $HOME/.local/bin $PATH'
PROFILE_LINE='export PATH="$HOME/.local/bin:$PATH"'

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

# Detecta o shell
detect_shell() {
    basename "${SHELL:-/bin/sh}"
}

SHELL_NAME=$(detect_shell)

# Instala autostart para restaurar estado no login
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
mkdir -p "$AUTOSTART_DIR"
cp glowkey.desktop "$AUTOSTART_DIR/"
echo "Auto-inicialização ativada (restaura estado na inicialização)"

# Função para adicionar PATH ao arquivo se não existir
add_path_to_file() {
    file="$1"
    line="$2"
    pattern="$3"
    
    mkdir -p "$(dirname "$file")"
    
    if [ -f "$file" ]; then
        if grep -q "$pattern" "$file" 2>/dev/null; then
            echo "PATH já configurado em $file"
            return 0
        fi
    fi
    
    echo "" >> "$file"
    echo "# GlowKey PATH" >> "$file"
    echo "$line" >> "$file"
    echo "PATH adicionado ao $file"
}

# Configura PATH para sessão gráfica (GNOME lê ~/.profile)
case "$SHELL_NAME" in
    bash)
        add_path_to_file "$HOME/.profile" "$PROFILE_LINE" 'export PATH.*\$HOME/.local/bin'
        add_path_to_file "$HOME/.bashrc" "$PATH_LINE" 'export PATH.*\$HOME/.local/bin'
        echo "Reinicie a sessão ou execute: source ~/.profile"
        ;;
    zsh)
        add_path_to_file "$HOME/.zprofile" "$PROFILE_LINE" 'export PATH.*\$HOME/.local/bin'
        add_path_to_file "$HOME/.zshrc" "$PATH_LINE" 'export PATH.*\$HOME/.local/bin'
        echo "Reinicie a sessão ou execute: source ~/.zprofile"
        ;;
    fish)
        FISH_PROFILE="$HOME/.config/fish/config.fish"
        add_path_to_file "$FISH_PROFILE" "$FISH_LINE" 'set -gx PATH.*\$HOME/.local/bin'
        echo "Reinicie a sessão ou execute: source $FISH_PROFILE"
        ;;
    *)
        add_path_to_file "$HOME/.profile" "$PROFILE_LINE" 'export PATH.*\$HOME/.local/bin'
        echo "Reinicie a sessão ou execute: source ~/.profile"
        ;;
esac
