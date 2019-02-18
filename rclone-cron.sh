#!/bin/bash

if pidof -o %PPID -x “rclone-cron.sh”; then
exit 1
fi
rclone sync -P --bwlimit=0.375M /home/eduardo/Documentos/rclone/ dropbox_hw:hewitt_equipamentos/arquivos_osasco/
exit
