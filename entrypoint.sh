#!/bin/sh
set -e

# Setze ggf. das Log-Level (wird hier nicht als Flag an PocketBase übergeben,
# aber du kannst es später in deinem Script für weitere Zwecke nutzen)
if [ "$DEV_MODE" = "true" ]; then
    export PB_LOG_LEVEL=debug
else
    export PB_LOG_LEVEL=info
fi

# Falls FTP_USER und FTP_PASS gesetzt sind, erstelle den FTP-Benutzer
if [ -n "$FTP_USER" ] && [ -n "$FTP_PASS" ]; then
    # Sicherstellen, dass das übergeordnete Verzeichnis des FTP-Home existiert
    mkdir -p "$(dirname "$FTP_HOME")"
    # Benutzer erstellen, falls noch nicht vorhanden
    if ! id "$FTP_USER" >/dev/null 2>&1; then
        adduser -D -h "$FTP_HOME" "$FTP_USER"
    fi
    # Passwort für den FTP-Benutzer setzen
    echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

# Starte Supervisor, der PocketBase und den FTP-Server überwacht
exec /usr/bin/supervisord -c /etc/supervisor.conf