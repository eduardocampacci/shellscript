#!/bin/sh

# Eduardo Campacci (chacal) - 2016

# Script para mover arquivos antigos.
# Com interacao para atribuir valores nas variaveis PASTA, DIAS e BACKUP.


# Inserindo valores das variaveis com interacao do usuario. 
echo -n "Entre com o caminho da pasta: " ; read PASTA
echo -n "Entre com o numero de dias de modificacao: " ; read DIAS
echo -n "Entre com o caminho do backup: " ; read BACKUP
echo "Processando"

# Comando find com du -hs --time 
find $PASTA -mtime +$DIAS -exec mv {} $BACKUP \; 

echo "Finalizado"
