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
    case "$(state)" in
        on) off ;;
        *) on ;;
    esac
}

restore() {
    if [ -f "$STATE_FILE" ]; then
        case "$(cat "$STATE_FILE")" in
            on) on ;;
            off) off ;;
            *) echo "Erro: estado inválido no arquivo de estado." >&2; exit 1 ;;
        esac
    else
        echo "Erro: nenhum estado salvo encontrado. Use 'glowkey on' ou 'glowkey off' primeiro." >&2
        exit 1
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
    --help|-h)
        usage 0
        ;;
    *)
        usage
        ;;
esac
