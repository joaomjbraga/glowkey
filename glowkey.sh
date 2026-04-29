#!/bin/sh

# GlowKey
# Controle do backlight do teclado usando Scroll Lock via X11/xset

set -eu

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/glowkey"
STATE_FILE="$STATE_DIR/state"

save_state() {
    mkdir -p "$STATE_DIR"
    echo "$1" > "$STATE_FILE"
}

require() {
    command -v xset >/dev/null 2>&1 || {
        echo "Erro: xset não encontrado. Instale x11-xserver-utils." >&2
        exit 1
    }

    xset q >/dev/null 2>&1 || {
        echo "Erro: sessão X11 não detectada." >&2
        exit 1
    }
}

state() {
    LC_ALL=C xset q 2>/dev/null | awk '/Scroll Lock:/ {print $NF}'
}

on() {
    xset led 3
    echo "Scroll Lock ativado (backlight ligado)."
    save_state "on"
}

off() {
    xset -led 3
    echo "Scroll Lock desativado (backlight desligado)."
    save_state "off"
}

toggle() {
    current_state=$(state)
    case "$current_state" in
        on) off ;;
        off) on ;;
        *) 
            echo "Aviso: estado atual não detectado, mantendo estado anterior." >&2
            # Não faz nada - mantém estado atual
            ;;
    esac
}

restore() {
    # Verifica se xset está disponível (silêncio no login)
    if ! command -v xset >/dev/null 2>&1; then
        exit 0
    fi
    
    # Verifica se há sessão X11 ativa
    if ! xset q >/dev/null 2>&1; then
        exit 0
    fi
    
    if [ -f "$STATE_FILE" ]; then
        case "$(cat "$STATE_FILE")" in
            on) on ;;
            off) off ;;
            *) exit 0 ;;
        esac
    else
        # Silencioso no login - usuário ainda não definiu estado
        exit 0
    fi
}

usage() {
    echo "Uso: glowkey [comando] [--help|-h]"
    echo
    echo "Comandos:"
    echo "  on        Liga o backlight (Scroll Lock ativado)"
    echo "  off       Desliga o backlight (Scroll Lock desativado)"
    echo "  toggle    Alterna entre ligado e desligado"
    echo "  status    Mostra o estado atual do Scroll Lock"
    echo "  restore   Restaura o último estado salvo (usado na auto-inicialização)"
    echo
    echo "Flags:"
    echo "  --help, -h  Mostra esta mensagem de ajuda"
    exit "${1:-1}"
}

case "${1:-}" in
    --help|-h)
        usage 0
        ;;
esac

require

case "${1:-}" in
    on)
        on
        ;;
    off)
        off
        ;;
    toggle)
        toggle
        ;;
    status)
        echo "Scroll Lock: $(state)"
        ;;
    restore)
        restore
        ;;
    *)
        usage
        ;;
esac
