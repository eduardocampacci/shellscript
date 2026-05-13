#!/bin/bash
# Backup Samba AD DC + rsync + validação de integridade + log único

# =========================
# PATH para CRON
# =========================
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -o pipefail

# =========================
# Configurações
# =========================

DC_SERVER="DC1"

BASE_DIR="/root/samba"
ONLINE_DIR="${BASE_DIR}/bkp_online"
OFFLINE_DIR="${BASE_DIR}/bkp_offline"
RENAME_DIR="${BASE_DIR}/bkp_rename"

LOG_FILE="/var/log/bkp_samba_dc.log"
CREDS_FILE="${BASE_DIR}/.samba_creds"

OLD_NETBIOS="BOREAL"
NEW_REALM="boreal.local"

RETENTION_DAYS=30

SAMBA_TOOL="/usr/bin/samba-tool"
TAR_BIN="/usr/bin/tar"

# =========================
# REMOTO via rsync
# =========================

ENABLE_REMOTE_COPY="yes"
REMOTE_USER="root"
REMOTE_SERVERS="192.168.122.3 192.168.122.5"
REMOTE_BASE_DIR="/root/samba/backups"

RSYNC_BIN="/usr/bin/rsync"
SSH_BIN="/usr/bin/ssh"

# =========================
# Controle
# =========================

ERROR_COUNT=0

# =========================
# Funções
# =========================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

add_error() {
    ERROR_COUNT=$((ERROR_COUNT+1))
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Execute como root."
        exit 1
    fi
}

create_dirs() {
    mkdir -p "$ONLINE_DIR" "$OFFLINE_DIR" "$RENAME_DIR"
    touch "$LOG_FILE"
    chmod 600 "$LOG_FILE"
}

check_files() {
    if [ ! -x "$SAMBA_TOOL" ]; then
        log "ERRO: samba-tool não encontrado em $SAMBA_TOOL"
        add_error
    fi

    if [ ! -x "$TAR_BIN" ]; then
        log "ERRO: tar não encontrado em $TAR_BIN"
        add_error
    fi

    if [ "$ENABLE_REMOTE_COPY" = "yes" ] && [ ! -x "$RSYNC_BIN" ]; then
        log "ERRO: rsync não encontrado em $RSYNC_BIN"
        add_error
    fi

    if [ "$ENABLE_REMOTE_COPY" = "yes" ] && [ ! -x "$SSH_BIN" ]; then
        log "ERRO: ssh não encontrado em $SSH_BIN"
        add_error
    fi

    if [ ! -f "$CREDS_FILE" ]; then
        log "ERRO: arquivo de credenciais não encontrado em $CREDS_FILE"
        add_error
    else
        chmod 600 "$CREDS_FILE"
        chown root:root "$CREDS_FILE"
    fi
}

run_cmd() {
    NAME="$1"
    CMD="$2"

    log "=================================================="
    log "Iniciando: $NAME"

    eval "$CMD" >> "$LOG_FILE" 2>&1
    STATUS=$?

    if [ "$STATUS" -eq 0 ]; then
        log "SUCESSO: $NAME"
    else
        log "ERRO: $NAME (código $STATUS)"
        add_error
    fi
}

validate_latest_backup() {
    BACKUP_TYPE="$1"
    BACKUP_DIR="$2"

    log "=================================================="
    log "Validando integridade do último backup: $BACKUP_TYPE"

    LATEST_FILE=$(ls -t "$BACKUP_DIR"/*.tar.bz2 2>/dev/null | head -n 1)

    if [ -z "$LATEST_FILE" ]; then
        log "ERRO: Nenhum arquivo .tar.bz2 encontrado em $BACKUP_DIR"
        add_error
        return
    fi

    log "Arquivo: $LATEST_FILE"

    $TAR_BIN -tjf "$LATEST_FILE" > /dev/null 2>> "$LOG_FILE"
    STATUS=$?

    if [ "$STATUS" -eq 0 ]; then
        log "SUCESSO: Integridade OK - $BACKUP_TYPE"
    else
        log "ERRO: Arquivo corrompido ou ilegível - $BACKUP_TYPE"
        add_error
    fi
}

validate_backups() {
    validate_latest_backup "ONLINE" "$ONLINE_DIR"
    validate_latest_backup "OFFLINE" "$OFFLINE_DIR"
    validate_latest_backup "RENAME" "$RENAME_DIR"
}

cleanup_old_backups() {
    log "=================================================="
    log "Limpeza de backups antigos ($RETENTION_DAYS dias)"

    find "$ONLINE_DIR" "$OFFLINE_DIR" "$RENAME_DIR" \
        -type f -name "*.tar.bz2" -mtime +"$RETENTION_DAYS" \
        -print -delete >> "$LOG_FILE" 2>&1
}

copy_backups_remote() {
    if [ "$ENABLE_REMOTE_COPY" != "yes" ]; then
        return
    fi

    log "=================================================="
    log "Iniciando envio remoto via rsync"

    for SERVER in $REMOTE_SERVERS; do
        REMOTE_DIR="${REMOTE_BASE_DIR}/${DC_SERVER}"

        log "Servidor: $SERVER"
        log "Destino: ${REMOTE_DIR}"

        $SSH_BIN "${REMOTE_USER}@${SERVER}" \
            "mkdir -p '${REMOTE_DIR}/bkp_online' '${REMOTE_DIR}/bkp_offline' '${REMOTE_DIR}/bkp_rename'" \
            >> "$LOG_FILE" 2>&1

        if [ $? -ne 0 ]; then
            log "ERRO ao preparar destino em $SERVER"
            add_error
            continue
        fi

        $RSYNC_BIN -az --ignore-existing "$ONLINE_DIR/" \
            "${REMOTE_USER}@${SERVER}:${REMOTE_DIR}/bkp_online/" >> "$LOG_FILE" 2>&1
        [ $? -ne 0 ] && log "ERRO rsync ONLINE para $SERVER" && add_error

        $RSYNC_BIN -az --ignore-existing "$OFFLINE_DIR/" \
            "${REMOTE_USER}@${SERVER}:${REMOTE_DIR}/bkp_offline/" >> "$LOG_FILE" 2>&1
        [ $? -ne 0 ] && log "ERRO rsync OFFLINE para $SERVER" && add_error

        $RSYNC_BIN -az --ignore-existing "$RENAME_DIR/" \
            "${REMOTE_USER}@${SERVER}:${REMOTE_DIR}/bkp_rename/" >> "$LOG_FILE" 2>&1
        [ $? -ne 0 ] && log "ERRO rsync RENAME para $SERVER" && add_error

        log "Envio finalizado para $SERVER"
    done
}

# =========================
# Execução
# =========================

check_root
create_dirs

log "=================================================="
log "INÍCIO BACKUP $DC_SERVER"

check_files

if [ "$ERROR_COUNT" -eq 0 ]; then
    run_cmd "DBCHECK" \
    "$SAMBA_TOOL dbcheck"

    run_cmd "BACKUP ONLINE" \
    "$SAMBA_TOOL domain backup online --targetdir=$ONLINE_DIR --server=$DC_SERVER -A $CREDS_FILE"

    run_cmd "BACKUP OFFLINE" \
    "$SAMBA_TOOL domain backup offline --targetdir=$OFFLINE_DIR"

    run_cmd "BACKUP RENAME" \
    "$SAMBA_TOOL domain backup rename $OLD_NETBIOS $NEW_REALM --server=$DC_SERVER --targetdir=$RENAME_DIR -A $CREDS_FILE"

    validate_backups

    if [ "$ERROR_COUNT" -eq 0 ]; then
        copy_backups_remote
    else
        log "Envio remoto não executado porque houve erro na validação dos backups."
    fi

    cleanup_old_backups
fi

if [ "$ERROR_COUNT" -gt 0 ]; then
    log "FINALIZADO COM ERROS: $ERROR_COUNT erro(s)."
else
    log "Backup concluído sem erros."
fi

log "FIM BACKUP $DC_SERVER"
log "=================================================="

exit 0
