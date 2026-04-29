#!/bin/sh

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
    if xset led 3 2>/dev/null; then
        echo "Scroll Lock ativado (backlight ligado)."
        save_state "on"
    else
        echo "Erro: Falha ao ligar backlight." >&2
        return 1
    fi
}

off() {
    if xset -led 3 2>/dev/null; then
        echo "Scroll Lock desativado (backlight desligado)."
        save_state "off"
    else
        echo "Erro: Falha ao desligar backlight." >&2
        return 1
    fi
}

toggle() {
    current_state=$(state)
    case "$current_state" in
        on) off ;;
        off) on ;;
        *)
            echo "Aviso: estado atual não detectado, mantendo estado anterior." >&2
            ;;
    esac
}

restore() {
    if ! command -v xset >/dev/null 2>&1; then
        exit 0
    fi
    
    # Tenta até 10 vezes (com 1s de intervalo) aguardar X11 estar pronto
    for i in $(seq 1 10); do
        if xset q >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    
    # Se depois das tentativas X11 não estiver pronto, sai silenciosamente
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
        exit 0
    fi
}

version() {
    echo "GlowKey 1.0.0"
    exit 0
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
    echo "  --version   Mostra a versão"
    exit "${1:-1}"
}

case "${1:-}" in
    --help|-h)
        usage 0
        ;;
    --version)
        version
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
