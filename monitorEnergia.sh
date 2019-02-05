#!/bin/bash

# REALIZAR PING EM 3 DISPOSITIVOS DE REDE FORA DO NOBREAK. 
# DESLIGAR OS SERVIDORES CASO NÃO HAJA RESPOSTA DO PING. POIS INDICA PARADA DE ENERGIA.

# Por Eduardo Campacci (21/01/2019)
# campacc@gmail.com


# Variaveis
HYPERVI2=192.168.21.30
HYPERVI3=192.168.21.28
CAMERA_ADM=192.168.21.85


# Comando ping disparado 5x para os servidores.
# Atribuindo as variaveis o resultado do ultimo comando.
# 0 - Sucesso / 1 - Sem Sucesso
ping -c 5 $HYPERVI2 > /dev/null
PING_HYPERVI2="$?"

ping -c 5 $HYPERVI3 > /dev/null 
PING_HYPERVI3="$?"

ping -c 5 $CAMERA_ADM > /dev/null
PING_CAMERA="$?"


# Impressão de variaveis
echo "Hypervisor_2 = "$PING_HYPERVI2
echo "Hypervisor_3 = "$PING_HYPERVI3
echo "Camera_adm = "$PING_CAMERA 
echo \

# Resultado da soma das saidas dos pings
RESULTADO=$(($PING_HYPERVI2+$PING_HYPERVI3+$PING_CAMERA))

# Impressão
echo "Qtd Serviços fora = "$RESULTADO
echo \


# Laço de condição, onde $? é referente a saida do ultimo comando executado.
if [ "$RESULTADO" -le 2 ];then
	date	
	echo "Serviços respondendo"

else
	date
	echo "Serviços sem respostas, FALTA DE ENERGIA"
	echo \ 
	
	echo "Desligando maquinas virtuais"
	echo \

	echo "hwdc01 - DC01"
	#ssh root@192.168.X.X shutdown 
	sleep 10;

	echo "hwdc02 - DC02"
        #ssh root@192.168.X.X shutdown 
	sleep 10;
	
	echo "hwbacula - sistema de backup"
        #ssh root@192.168.X.X shutdown 
	sleep 10;
	
	echo "hwapp01 - aplicações"
        #ssh root@192.168.X.X shutdown 
	sleep 10;
	
	echo "hwdb01 - bancos de dados"
        #ssh root@192.168.X.X shutdown 
	sleep 10;

	echo "hwdhcp01 - DHCP"
        #ssh root@192.168.X.X shutdown 
	sleep 10;
	
	echo \

	echo "Desligando Hypervisor 01"
        echo "hwpve01"
        #ssh root@192.168.X.X shutdown 
	sleep 10;
	
	echo \

	echo "Desligando Storage e NFS - HWSTG"
        echo "hwstg"
        #ssh root@192.168.X.X shutdown 
	sleep 10;

	echo \

	echo "Desligando servidores fisicos"
        echo \

	echo "Contingencia"
        #ssh root@192.168.X.X shutdown 
	sleep 10;

        echo "hwslave"
        #ssh root@192.168.X.X shutdown 
	sleep 10;

	echo "hwmaster"
	#ssh root@192.168.X.X shutdown 
	sleep 10;

	echo "firewall"
	#ssh root@192.168.X.X shutdown +3
	
fi

echo "---------------------------------------------------------------------" \
