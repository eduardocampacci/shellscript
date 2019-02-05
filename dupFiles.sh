#!/bin/sh
 
# Eduardo Campacci (chacal) - 2016
 
# Script para localizar arquivos duplicados.
# Com interacao para atribuir valores nas variaveis DIRETORIO e LOGS.
 
 
# Inserindo valores das variaveis com interacao do usuario.
echo -n "Entre com o caminho e nome da pasta: " ; read DIRETORIO
echo -n "Entre com o nome do log: " ; read LOGS
 
echo "Processando"
 
# Localizacao 
find $DIRETORIO -type f -exec md5sum '{}' ';' | sort | uniq --all-repeated=separate -w 20 > $LOGS.xls 
 
echo "Finalizado"
