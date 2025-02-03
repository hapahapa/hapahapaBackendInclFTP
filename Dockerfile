# Stage 1: Download PocketBase
FROM alpine:3 AS downloader

ARG VERSION=0.25.0

# Herunterladen, entpacken und ausführbar machen
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_linux_amd64.zip \
    && unzip pocketbase_${VERSION}_linux_amd64.zip \
    && chmod +x pocketbase

# Stage 2: Finales Image mit PocketBase und FTP-Server
FROM alpine:3

# Standard-Umgebungsvariablen (können zur Laufzeit überschrieben werden)
ENV PB_PORT=8090 \
    PB_DATA_DIR="/data/pb_data" \
    PB_PUBLIC_DIR="/data/pb_public" \
    PB_HOOKS_DIR="/data/pb_hooks" \
    PB_MIGRATIONS_DIR="/data/pb_migrations" \
    DEV_MODE="false" \
    FTP_USER="ftpuser" \
    FTP_PASS="ftppass" \
    FTP_HOME="/"

# Notwendige Pakete installieren
RUN apk update && apk add --no-cache \
    ca-certificates \
    wget \
    unzip \
    bash \
    curl \
    supervisor \
    pure-ftpd \
    shadow \
    && rm -rf /var/cache/apk/*

# Erforderliche Verzeichnisse erstellen
RUN mkdir -p "$PB_DATA_DIR" "$PB_PUBLIC_DIR" "$PB_HOOKS_DIR" "$PB_MIGRATIONS_DIR" "/ftp" /etc/supervisor.d

# PocketBase-Binary aus dem Downloader-Stadium kopieren
COPY --from=downloader /pocketbase /usr/local/bin/pocketbase

# Kopiere den entrypoint und die Supervisor-Konfiguration
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY supervisor.conf /etc/supervisor.conf

# Ports freigeben:
# - PocketBase (z. B. 8090)
# - FTP: Port 21 sowie der Passive-Portbereich (hier 30000-30009)
EXPOSE ${PB_PORT} 21 30000-30009

# Verwende den custom entrypoint
ENTRYPOINT ["/entrypoint.sh"]