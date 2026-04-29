#!/bin/sh

# GlowKey
# Controle do backlight do teclado usando Scroll Lock via X11/xset

set -eu

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
    xset q | awk '/Scroll Lock:/ {print $NF}'
}

on() {
    xset led 3
    echo "Scroll Lock ativado (backlight ligado)."
}

off() {
    xset -led 3
    echo "Scroll Lock desativado (backlight desligado)."
}

toggle() {
    if [ "$(state)" = "on" ]; then
        off
    else
        on
    fi
}

usage() {
    echo "Uso: glowkey [on|off|toggle|status]"
    exit 1
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
    *)
        usage
        ;;
esac
