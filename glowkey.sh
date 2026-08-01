#!/bin/sh

set -eu

VERSION="1.1.0"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/glowkey"
STATE_FILE="$STATE_DIR/state"

save_state() {
    mkdir -p "$STATE_DIR"
    echo "$1" > "$STATE_FILE"
}

die() {
    echo "Erro: $*" >&2
    exit 1
}

require() {
    [ "${XDG_SESSION_TYPE:-x11}" = "x11" ] ||
        die "GlowKey suporta apenas sessões X11."

    command -v xset >/dev/null 2>&1 ||
        die "xset não encontrado. Instale o pacote que fornece o comando 'xset'."

    [ -n "${DISPLAY:-}" ] ||
        die "DISPLAY não definido."

    xset q >/dev/null 2>&1 ||
        die "Não foi possível conectar ao servidor X11."
}

state() {
    if LC_ALL=C xset q 2>/dev/null | grep -q "Scroll Lock:[[:space:]]*on"; then
        echo "on"
    else
        echo "off"
    fi
}

on() {
    if xset led named "Scroll Lock" 2>/dev/null; then
        echo "Scroll Lock ativado (backlight ligado)."
        save_state "on"
    else
        die "Falha ao ligar o backlight."
    fi
}

off() {
    if xset -led named "Scroll Lock" 2>/dev/null; then
        echo "Scroll Lock desativado (backlight desligado)."
        save_state "off"
    else
        die "Falha ao desligar o backlight."
    fi
}

toggle() {
    case "$(state)" in
        on)  off ;;
        off) on  ;;
        *)   die "Estado atual não detectado." ;;
    esac
}

restore() {
    # Sai silenciosamente se não houver X11 disponível
    command -v xset >/dev/null 2>&1 || exit 0

    i=0
    while [ "$i" -lt 10 ]; do
        if xset q >/dev/null 2>&1; then
            break
        fi
        i=$((i + 1))
        sleep 1
    done

    xset q >/dev/null 2>&1 || exit 0

    if [ -f "$STATE_FILE" ]; then
        case "$(cat "$STATE_FILE")" in
            on)  on  ;;
            off) off ;;
            *)   exit 0 ;;
        esac
    else
        on
    fi
}

version() {
    echo "GlowKey $VERSION"
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
    echo "  restore   Restaura o último estado salvo"
    echo
    echo "Flags:"
    echo "  --help, -h  Mostra esta ajuda"
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