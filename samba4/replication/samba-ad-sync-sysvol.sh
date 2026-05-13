#!/bin/bash

# Configurações
ORIGEM="/var/lib/samba/sysvol/"
# Adicione quantos DCs desejar nesta lista, separados por espaço
DCS_DESTINO=("192.168.122.3" "192.168.122.5")
LOG_FILE="/var/log/sysvol_sync.log"
SSH_KEY="/root/.ssh/id_rsa"

DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "--- Início da sincronização: $DATE ---" >> $LOG_FILE

# Loop para percorrer cada Domain Controller da lista
for DC_IP in "${DCS_DESTINO[@]}"
do
    echo "[$DATE] Sincronizando com DC: $DC_IP..." >> $LOG_FILE
    
    # Executa o Rsync para o DC atual
    rsync -avzXA -e "ssh -i $SSH_KEY" --delete --relative $ORIGEM root@${DC_IP}:/ >> $LOG_FILE 2>&1
    
    if [ $? -eq 0 ]; then
        echo "[$DATE] Rsync para $DC_IP: SUCESSO" >> $LOG_FILE
    else
        echo "[$DATE] Rsync para $DC_IP: ERRO" >> $LOG_FILE
    fi
done

# 2. Executa o sysvolcheck no DC local (Mestre) para garantir integridade da origem
samba-tool ntacl sysvolcheck >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "[$DATE] Sysvolcheck Local: SUCESSO" >> $LOG_FILE
else
    echo "[$DATE] Sysvolcheck Local: ERRO" >> $LOG_FILE
fi

echo "--- Fim da sincronização ---" >> $LOG_FILE
echo "" >> $LOG_FILE 
