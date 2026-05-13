#!/bin/sh

# Eduardo Campacci (chacal) - 2016

# Script para localizar arquivos antigos.
# Com interacao para atribuir valores nas variaveis PASTA, DIAS e LOG.


# Inserindo valores das variaveis com interacao do usuario. 
echo -n "Entre com o caminho e nome da pasta: " ; read PASTA
echo -n "Entre com o numero de dias: " ; read DIAS
echo -n "Entre com o nome do log: " ; read LOG

echo "Processando"

# Comando find com du -hs --time 
find $PASTA -mtime +$DIAS -exec du -hs --time {} \; > $LOG.csv

echo "Finalizado"
