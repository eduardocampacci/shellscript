#!/bin/bash

COMMUNITY="public"

BASE_DIR="/opt/impressoras"
ARQUIVO="$BASE_DIR/controle_impressoras.csv"
PRODUCAO="$BASE_DIR/producao_mensal.csv"
LOG="$BASE_DIR/coleta.log"
BACKUP_DIR="$BASE_DIR/backup"

DATA=$(date '+%Y-%m-%d %H:%M:%S')
DATA_BACKUP=$(date '+%Y%m%d_%H%M%S')

mkdir -p "$BASE_DIR" "$BACKUP_DIR"

OID_MODELO="1.3.6.1.2.1.43.5.1.1.16.1"
OID_SERIE="1.3.6.1.2.1.43.5.1.1.17.1"

RICOH_OID_PB="1.3.6.1.4.1.367.3.2.1.2.19.5.1.9.22"
RICOH_OID_COLOR="1.3.6.1.4.1.367.3.2.1.2.19.5.1.9.21"
RICOH_OID_TOTAL="1.3.6.1.4.1.367.3.2.1.2.19.5.1.9.1"

RICOH_OID_SCAN_COLOR="1.3.6.1.4.1.367.3.2.1.2.19.5.1.9.77"
RICOH_OID_SCAN_PB="1.3.6.1.4.1.367.3.2.1.2.19.5.1.9.78"

KYOCERA_OID_TOTAL="1.3.6.1.2.1.43.10.2.1.4.1.1"

snmp_coleta() {
    snmpget -v2c -c "$COMMUNITY" -t 2 -r 1 -Ovq "$1" "$2" 2>/dev/null | sed 's/"//g'
}

[ ! -f "$ARQUIVO" ] && echo "data;nome;ip;modelo;serie;pb;color;total;scanner_pb;scanner_color;scanner_total;status" > "$ARQUIVO"
[ ! -f "$PRODUCAO" ] && echo "data;nome;ip;producao_pb;producao_color;producao_total;producao_scanner_pb;producao_scanner_color;producao_scanner_total;status" > "$PRODUCAO"

echo "$DATA - Iniciando coleta" >> "$LOG"

registrar_producao() {
    NOME="$1"
    IP="$2"
    PB_ATUAL="$3"
    COLOR_ATUAL="$4"
    TOTAL_ATUAL="$5"
    SCAN_PB_ATUAL="$6"
    SCAN_COLOR_ATUAL="$7"
    SCAN_TOTAL_ATUAL="$8"
    STATUS="$9"

    ULTIMA_LINHA=$(grep ";$NOME;$IP;" "$ARQUIVO" | tail -n 1)

    if [ -z "$ULTIMA_LINHA" ] || [ "$STATUS" != "OK" ]; then
        echo "$DATA;$NOME;$IP;N/A;N/A;N/A;N/A;N/A;N/A;SEM_BASE_ANTERIOR" >> "$PRODUCAO"
        return
    fi

    PB_ANT=$(echo "$ULTIMA_LINHA" | awk -F';' '{print $6}')
    COLOR_ANT=$(echo "$ULTIMA_LINHA" | awk -F';' '{print $7}')
    TOTAL_ANT=$(echo "$ULTIMA_LINHA" | awk -F';' '{print $8}')
    SCAN_PB_ANT=$(echo "$ULTIMA_LINHA" | awk -F';' '{print $9}')
    SCAN_COLOR_ANT=$(echo "$ULTIMA_LINHA" | awk -F';' '{print $10}')
    SCAN_TOTAL_ANT=$(echo "$ULTIMA_LINHA" | awk -F';' '{print $11}')

    PROD_PB=$((PB_ATUAL - PB_ANT))
    PROD_COLOR=$((COLOR_ATUAL - COLOR_ANT))
    PROD_TOTAL=$((TOTAL_ATUAL - TOTAL_ANT))

    if [ "$SCAN_PB_ATUAL" = "N/A" ]; then
        PROD_SCAN_PB="N/A"
        PROD_SCAN_COLOR="N/A"
        PROD_SCAN_TOTAL="N/A"
    else
        PROD_SCAN_PB=$((SCAN_PB_ATUAL - SCAN_PB_ANT))
        PROD_SCAN_COLOR=$((SCAN_COLOR_ATUAL - SCAN_COLOR_ANT))
        PROD_SCAN_TOTAL=$((SCAN_TOTAL_ATUAL - SCAN_TOTAL_ANT))
    fi

    echo "$DATA;$NOME;$IP;$PROD_PB;$PROD_COLOR;$PROD_TOTAL;$PROD_SCAN_PB;$PROD_SCAN_COLOR;$PROD_SCAN_TOTAL;OK" >> "$PRODUCAO"
}

coletar_ricoh() {
    NOME="$1"
    IP="$2"

    MODELO=$(snmp_coleta "$IP" "$OID_MODELO")
    SERIE=$(snmp_coleta "$IP" "$OID_SERIE")

    PB=$(snmp_coleta "$IP" "$RICOH_OID_PB")
    COLOR=$(snmp_coleta "$IP" "$RICOH_OID_COLOR")
    TOTAL=$(snmp_coleta "$IP" "$RICOH_OID_TOTAL")

    SCAN_COLOR=$(snmp_coleta "$IP" "$RICOH_OID_SCAN_COLOR")
    SCAN_PB=$(snmp_coleta "$IP" "$RICOH_OID_SCAN_PB")

    [ -z "$MODELO" ] && MODELO="N/A"
    [ -z "$SERIE" ] && SERIE="N/A"
    [ -z "$SCAN_COLOR" ] && SCAN_COLOR=0
    [ -z "$SCAN_PB" ] && SCAN_PB=0

    SCAN_TOTAL=$((SCAN_PB + SCAN_COLOR))

    if [ -z "$PB" ] || [ -z "$COLOR" ] || [ -z "$TOTAL" ]; then
        STATUS="OFFLINE_SNMP"
    else
        STATUS="OK"
    fi

    registrar_producao "$NOME" "$IP" "$PB" "$COLOR" "$TOTAL" "$SCAN_PB" "$SCAN_COLOR" "$SCAN_TOTAL" "$STATUS"

    echo "$DATA;$NOME;$IP;$MODELO;$SERIE;$PB;$COLOR;$TOTAL;$SCAN_PB;$SCAN_COLOR;$SCAN_TOTAL;$STATUS" >> "$ARQUIVO"
}

coletar_kyocera_pb() {
    NOME="$1"
    IP="$2"

    MODELO=$(snmp_coleta "$IP" "$OID_MODELO")
    SERIE=$(snmp_coleta "$IP" "$OID_SERIE")
    TOTAL=$(snmp_coleta "$IP" "$KYOCERA_OID_TOTAL")

    [ -z "$MODELO" ] && MODELO="N/A"
    [ -z "$SERIE" ] && SERIE="N/A"

    if [ -z "$TOTAL" ]; then
        PB=""
        COLOR=""
        STATUS="OFFLINE_SNMP"
    else
        PB="$TOTAL"
        COLOR="0"
        STATUS="OK"
    fi

    registrar_producao "$NOME" "$IP" "$PB" "$COLOR" "$TOTAL" "N/A" "N/A" "N/A" "$STATUS"

    echo "$DATA;$NOME;$IP;$MODELO;$SERIE;$PB;$COLOR;$TOTAL;N/A;N/A;N/A;$STATUS" >> "$ARQUIVO"
}

coletar_ricoh "Ricoh Adm/RH" "192.168.1.20"
coletar_ricoh "Ricoh Engenharia" "192.168.1.8"
coletar_ricoh "Ricoh Metrologia" "192.168.1.12"

coletar_kyocera_pb "Kyocera PCP" "192.168.1.10"
coletar_kyocera_pb "Kyocera Truque" "192.168.1.11"

cp "$ARQUIVO" "$BACKUP_DIR/controle_impressoras_$DATA_BACKUP.csv"
cp "$PRODUCAO" "$BACKUP_DIR/producao_mensal_$DATA_BACKUP.csv"

echo "$DATA - Coleta finalizada" >> "$LOG"
echo "Coleta finalizada."
