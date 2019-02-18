#!/bin/bash

if pidof -o %PPID -x “rclone-cron.sh”; then
exit 1

fi
# -P é para exibir o progresso da sincronização.
# --bwlimit=0.375M - Segue.: 10M link total, usar 3M do link total p/ o rclone. Então 3/8 = 0.375M
rclone sync -P --bwlimit=0.375M /home/eduardo/Documentos/rclone/ dropbox_hw:arquivos/rclone
exit
