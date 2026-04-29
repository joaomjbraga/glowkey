#!/bin/sh

# Remove o GlowKey instalado em ~/.local/share

set -eu

TARGET="$HOME/.local/share/glowkey"
PATH_PATTERN='GlowKey PATH'

# Remove arquivo de autostart
AUTOSTART_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/autostart/glowkey.desktop"
if [ -f "$AUTOSTART_FILE" ]; then
    rm -f "$AUTOSTART_FILE"
    echo "Auto-inicialização removida."
fi

# Remove serviço systemd
SYSTEMD_FILE="$HOME/.local/share/systemd/user/glowkey.service"
if [ -f "$SYSTEMD_FILE" ]; then
    # Desabilita o serviço (se o systemctl estiver disponível)
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user disable glowkey.service 2>/dev/null || true
        systemctl --user daemon-reload 2>/dev/null || true
    fi
    rm -f "$SYSTEMD_FILE"
    echo "Serviço systemd removido."
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

# Remove linhas do PATH dos arquivos de configuração
echo
echo "Limpando configurações do PATH..."

for config_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.zprofile" "$HOME/.config/fish/config.fish"; do
    if [ -f "$config_file" ] && grep -q "$PATH_PATTERN" "$config_file" 2>/dev/null; then
        # Cria backup
        cp "$config_file" "$config_file.bak"
        
        # Remove linhas com o marcador "GlowKey PATH" e a linha seguinte (que contém o PATH)
        # Usa abordagem mais segura com awk
        awk '
            /\# GlowKey PATH/ { in_glowkey=1; next }
            in_glowkey && /PATH.*\.local\/share/ { in_glowkey=0; next }
            !in_glowkey { print }
        ' "$config_file.bak" > "$config_file.tmp"
        
        if [ -s "$config_file.tmp" ]; then
            mv "$config_file.tmp" "$config_file"
            echo "  Removido do $config_file (backup: $config_file.bak)"
        else
            rm -f "$config_file.tmp"
            echo "  Erro ao limpar $config_file, mantendo backup"
        fi
    fi
done

echo "Limpeza concluída."
