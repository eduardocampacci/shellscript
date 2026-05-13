#!/bin/bash
# Teste automático de restore Samba AD usando backup rename de múltiplos DCs

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -o pipefail

# =========================
# DCs de origem
# Formato: "NOME|IP|CAMINHO_DO_BACKUP_RENAME"
# =========================

DC_LIST=(
"DC1|192.168.122.2|/root/samba/bkp_rename"
"DC2|192.168.122.3|/root/samba/bkp_rename"
"DC3|192.168.122.5|/root/samba/bkp_rename"
)

SOURCE_USER="root"

LOCAL_BASE="/root/restore"
LOCAL_BACKUP_BASE="${LOCAL_BASE}/backups"
RESTORE_DIR="${LOCAL_BASE}/samba-restored"

LOG_FILE="/var/log/restore_samba_test.log"

SAMBA_TOOL="/usr/bin/samba-tool"
SAMBA_BIN="/usr/sbin/samba"
TAR_BIN="/usr/bin/tar"
RSYNC_BIN="/usr/bin/rsync"
PKILL_BIN="/usr/bin/pkill"

NEW_SERVER_NAME="DC-RESTORE"

RETENTION_DAYS=30
MIN_USERS=3
MIN_GROUPS=10
MIN_SYSVOL_FILES=1

ERROR_COUNT=0
TOTAL_TESTS=0
TOTAL_SUCCESS=0
TOTAL_FAILED=0

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

prepare_dirs() {
    mkdir -p "$LOCAL_BACKUP_BASE"
    touch "$LOG_FILE"
    chmod 600 "$LOG_FILE"
}

cleanup_old_local_backups() {
    log "=================================================="
    log "Limpando backups locais antigos da VM restore. Retenção: $RETENTION_DAYS dias"

    find "$LOCAL_BACKUP_BASE" \
        -type f \
        -name "*.tar.bz2" \
        -mtime +"$RETENTION_DAYS" \
        -print \
        -delete >> "$LOG_FILE" 2>&1

    log "Limpeza de backups locais antigos finalizada"
}

stop_existing_samba() {
    log "Parando qualquer processo Samba anterior de teste"
    systemctl stop samba-ad-dc 2>/dev/null
    $PKILL_BIN -f "samba -s ${RESTORE_DIR}/etc/smb.conf" 2>/dev/null
    sleep 3
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
        return 0
    else
        log "ERRO: $NAME código $STATUS"
        return 1
    fi
}

copy_latest_backup() {
    DC_NAME="$1"
    SOURCE_SERVER="$2"
    SOURCE_BACKUP_DIR="$3"
    LOCAL_BACKUP_DIR="${LOCAL_BACKUP_BASE}/${DC_NAME}"

    mkdir -p "$LOCAL_BACKUP_DIR"

    log "=================================================="
    log "Copiando backups rename de $DC_NAME - $SOURCE_SERVER"

    $RSYNC_BIN -az --ignore-existing \
        "${SOURCE_USER}@${SOURCE_SERVER}:${SOURCE_BACKUP_DIR}/" \
        "$LOCAL_BACKUP_DIR/" >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then
        log "ERRO: falha ao copiar backup via rsync de $DC_NAME"
        return 1
    fi

    LATEST_BACKUP=$(ls -t "$LOCAL_BACKUP_DIR"/*.tar.bz2 2>/dev/null | head -n 1)

    if [ -z "$LATEST_BACKUP" ]; then
        log "ERRO: nenhum backup .tar.bz2 encontrado para $DC_NAME em $LOCAL_BACKUP_DIR"
        return 1
    fi

    log "Backup selecionado para $DC_NAME: $LATEST_BACKUP"
    return 0
}

validate_tar() {
    DC_NAME="$1"

    log "=================================================="
    log "Validando integridade do backup de $DC_NAME"

    $TAR_BIN -tjf "$LATEST_BACKUP" > /dev/null 2>> "$LOG_FILE"

    if [ $? -eq 0 ]; then
        log "SUCESSO: arquivo tar.bz2 íntegro para $DC_NAME"
        return 0
    else
        log "ERRO: arquivo tar.bz2 inválido ou corrompido para $DC_NAME"
        return 1
    fi
}

clean_old_restore() {
    log "=================================================="
    log "Limpando restore anterior"
    rm -rf "$RESTORE_DIR"
}

restore_backup() {
    DC_NAME="$1"

    run_cmd "RESTORE DO BACKUP RENAME - $DC_NAME" \
    "$SAMBA_TOOL domain backup restore --backup-file='$LATEST_BACKUP' --targetdir='$RESTORE_DIR' --newservername='$NEW_SERVER_NAME'"
}

start_restored_samba() {
    DC_NAME="$1"

    log "=================================================="
    log "Subindo Samba restaurado para teste de $DC_NAME"

    $SAMBA_BIN -s "${RESTORE_DIR}/etc/smb.conf" -D >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        log "SUCESSO: Samba restaurado iniciado para $DC_NAME"
        sleep 5
        return 0
    else
        log "ERRO: falha ao iniciar Samba restaurado para $DC_NAME"
        return 1
    fi
}

validate_users_count() {
    DC_NAME="$1"

    log "=================================================="
    log "Validando quantidade mínima de usuários - $DC_NAME"

    USERS_COUNT=$($SAMBA_TOOL user list -s "${RESTORE_DIR}/etc/smb.conf" 2>> "$LOG_FILE" | wc -l)

    log "Usuários encontrados em $DC_NAME: $USERS_COUNT"

    if [ "$USERS_COUNT" -ge "$MIN_USERS" ]; then
        log "SUCESSO: quantidade de usuários OK para $DC_NAME"
        return 0
    else
        log "ERRO: quantidade de usuários abaixo do mínimo em $DC_NAME. Mínimo: $MIN_USERS"
        return 1
    fi
}

validate_groups_count() {
    DC_NAME="$1"

    log "=================================================="
    log "Validando quantidade mínima de grupos - $DC_NAME"

    GROUPS_COUNT=$($SAMBA_TOOL group list -s "${RESTORE_DIR}/etc/smb.conf" 2>> "$LOG_FILE" | wc -l)

    log "Grupos encontrados em $DC_NAME: $GROUPS_COUNT"

    if [ "$GROUPS_COUNT" -ge "$MIN_GROUPS" ]; then
        log "SUCESSO: quantidade de grupos OK para $DC_NAME"
        return 0
    else
        log "ERRO: quantidade de grupos abaixo do mínimo em $DC_NAME. Mínimo: $MIN_GROUPS"
        return 1
    fi
}

validate_sysvol_content() {
    DC_NAME="$1"

    log "=================================================="
    log "Validando conteúdo do SYSVOL - $DC_NAME"

    SYSVOL_DIR=""

    if [ -d "${RESTORE_DIR}/state/sysvol" ]; then
        SYSVOL_DIR="${RESTORE_DIR}/state/sysvol"
    elif [ -d "${RESTORE_DIR}/var/locks/sysvol" ]; then
        SYSVOL_DIR="${RESTORE_DIR}/var/locks/sysvol"
    elif [ -d "${RESTORE_DIR}/sysvol" ]; then
        SYSVOL_DIR="${RESTORE_DIR}/sysvol"
    fi

    if [ -z "$SYSVOL_DIR" ]; then
        log "ERRO: diretório SYSVOL não encontrado para $DC_NAME"
        return 1
    fi

    SYSVOL_FILES=$(find "$SYSVOL_DIR" -type f 2>> "$LOG_FILE" | wc -l)

    log "SYSVOL encontrado em: $SYSVOL_DIR"
    log "Arquivos encontrados no SYSVOL de $DC_NAME: $SYSVOL_FILES"

    if [ "$SYSVOL_FILES" -ge "$MIN_SYSVOL_FILES" ]; then
        log "SUCESSO: conteúdo do SYSVOL OK para $DC_NAME"
        return 0
    else
        log "ERRO: SYSVOL encontrado, mas sem arquivos suficientes para $DC_NAME. Mínimo: $MIN_SYSVOL_FILES"
        return 1
    fi
}

validate_restore() {
    DC_NAME="$1"
    VALIDATION_ERROR=0

    run_cmd "DBCHECK NO RESTORE - $DC_NAME" \
    "$SAMBA_TOOL dbcheck -s '${RESTORE_DIR}/etc/smb.conf'"
    [ $? -ne 0 ] && VALIDATION_ERROR=1

    run_cmd "LISTAR USUÁRIOS - $DC_NAME" \
    "$SAMBA_TOOL user list -s '${RESTORE_DIR}/etc/smb.conf'"
    [ $? -ne 0 ] && VALIDATION_ERROR=1

    validate_users_count "$DC_NAME"
    [ $? -ne 0 ] && VALIDATION_ERROR=1

    run_cmd "LISTAR GRUPOS - $DC_NAME" \
    "$SAMBA_TOOL group list -s '${RESTORE_DIR}/etc/smb.conf'"
    [ $? -ne 0 ] && VALIDATION_ERROR=1

    validate_groups_count "$DC_NAME"
    [ $? -ne 0 ] && VALIDATION_ERROR=1

    validate_sysvol_content "$DC_NAME"
    [ $? -ne 0 ] && VALIDATION_ERROR=1

    if [ "$VALIDATION_ERROR" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

stop_restored_samba() {
    log "=================================================="
    log "Parando Samba restaurado"
    $PKILL_BIN -f "samba -s ${RESTORE_DIR}/etc/smb.conf" 2>/dev/null
    sleep 3
}

test_one_dc() {
    ENTRY="$1"

    DC_NAME=$(echo "$ENTRY" | cut -d'|' -f1)
    SOURCE_SERVER=$(echo "$ENTRY" | cut -d'|' -f2)
    SOURCE_BACKUP_DIR=$(echo "$ENTRY" | cut -d'|' -f3)

    TOTAL_TESTS=$((TOTAL_TESTS+1))

    log "=================================================="
    log "INÍCIO DO TESTE DE RESTORE: $DC_NAME"

    stop_existing_samba

    copy_latest_backup "$DC_NAME" "$SOURCE_SERVER" "$SOURCE_BACKUP_DIR"
    if [ $? -ne 0 ]; then
        TOTAL_FAILED=$((TOTAL_FAILED+1))
        add_error
        return
    fi

    validate_tar "$DC_NAME"
    if [ $? -ne 0 ]; then
        TOTAL_FAILED=$((TOTAL_FAILED+1))
        add_error
        return
    fi

    clean_old_restore

    restore_backup "$DC_NAME"
    if [ $? -ne 0 ]; then
        TOTAL_FAILED=$((TOTAL_FAILED+1))
        add_error
        stop_restored_samba
        return
    fi

    start_restored_samba "$DC_NAME"
    if [ $? -ne 0 ]; then
        TOTAL_FAILED=$((TOTAL_FAILED+1))
        add_error
        stop_restored_samba
        return
    fi

    validate_restore "$DC_NAME"
    if [ $? -ne 0 ]; then
        TOTAL_FAILED=$((TOTAL_FAILED+1))
        add_error
        stop_restored_samba
        return
    fi

    stop_restored_samba

    TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
    log "TESTE DE RESTORE OK: $DC_NAME"
}

# =========================
# Execução
# =========================

check_root
prepare_dirs

log "=================================================="
log "INÍCIO TESTE AUTOMÁTICO DE RESTORE DOS 3 DCs"

cleanup_old_local_backups

for ENTRY in "${DC_LIST[@]}"; do
    test_one_dc "$ENTRY"
done

stop_existing_samba

log "=================================================="
log "RESUMO DO TESTE DE RESTORE"
log "Total testado: $TOTAL_TESTS"
log "Sucesso: $TOTAL_SUCCESS"
log "Falha: $TOTAL_FAILED"

if [ "$ERROR_COUNT" -gt 0 ]; then
    log "TESTE FINALIZADO COM ERROS: $ERROR_COUNT erro(s)"
else
    log "TODOS OS TESTES DE RESTORE CONCLUÍDOS COM SUCESSO"
fi

log "FIM TESTE AUTOMÁTICO DE RESTORE"
log "=================================================="

exit 0 
