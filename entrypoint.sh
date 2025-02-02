#!/bin/sh
set -e

# Setze das Log-Level für PocketBase anhand von DEV_MODE
if [ "$DEV_MODE" = "true" ]; then
    export PB_LOG_LEVEL=debug
else
    export PB_LOG_LEVEL=info
fi

# Falls FTP_USER und FTP_PASS gesetzt sind, erstelle den FTP-Benutzer
if [ -n "$FTP_USER" ] && [ -n "$FTP_PASS" ]; then
    # Stelle sicher, dass das übergeordnete Verzeichnis des FTP-Home existiert
    mkdir -p "$(dirname "$FTP_HOME")"
    # Erstelle den Benutzer, falls er noch nicht existiert
    if ! id "$FTP_USER" >/dev/null 2>&1; then
        adduser -D -h "$FTP_HOME" "$FTP_USER"
    fi
    # Setze das Passwort für den FTP-Benutzer
    echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

# Starte Supervisor, der PocketBase und den FTP-Server überwacht
exec /usr/bin/supervisord -c /etc/supervisor.conf