#!/bin/sh
# Copyright (C) 2017

# Por Eduardo Campacci - 23/10/2017


### RESETANDO E APLICANDO POLITICAS PADRAO
iptables -F
iptables -F -t nat
iptables -F -t filter
iptables -F -t mangle
iptables -P INPUT DROP 
iptables -P FORWARD DROP

### ADICIONANDO MODULOS NO KERNEL
modprobe ip_conntrack
modprobe ip_conntrack_ftp

### SETANDO ROTEAMENTO
echo "1" > /proc/sys/net/ipv4/ip_forward

### LOGS
#iptables -t filter -A INPUT -j LOG --log-prefix "LOG INPUT - "
#iptables -t filter -A FORWARD -j LOG --log-prefix "LOG FORWARD - "

### COMPARTILHAMENTO DE INTERNET
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

### DIRECIONAMENTO PARA SQUID 80 PARA 3128
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j REDIRECT --to-port 3128


### PACOTES MAL FORMADOS
# isso aceita as conexoes de input com o status "established" 
# ou seja, quando ja foram enviados pacotes nas duas direcoes
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT


### REGRA OPENVPN SITE-TO-CLIENT COM REDES IGUAIS
iptables -t nat -A PREROUTING -d 192.168.5.0/24 -j NETMAP --to 192.168.1.0/24

### IPs LIBERADOS SQUID PROXY
iptables -t nat -I PREROUTING -s 192.168.1.5 -j ACCEPT      # Servidor de Impressao
iptables -t nat -I PREROUTING -s 192.168.1.16 -j ACCEPT     # Eduardo celular 
iptables -t nat -I PREROUTING -s 192.168.1.15 -j ACCEPT     # Eduardo wifi
iptables -t nat -I PREROUTING -s 192.168.1.14 -j ACCEPT     # Eduardo cabeado
iptables -t nat -I PREROUTING -s 192.168.1.18 -j ACCEPT     # Lucas cabeado 
#iptables -t nat -I PREROUTING -s 192.168.1.37 -j ACCEPT    # VM Windows
iptables -t nat -I PREROUTING -s 192.168.1.90 -j ACCEPT     # Julia Vernaglia IPAD
iptables -t nat -I PREROUTING -s 192.168.1.92 -j ACCEPT     # Julia Vernaglia Iphone 8




### LIBERACAO DE PORTAS

# Squid
iptables -t filter -I INPUT -p tcp --dport 3128 -j ACCEPT
iptables -t filter -I INPUT -p tcp --sport 3128 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 3128 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 3128 -j ACCEPT
# Ping
iptables -t filter -I INPUT -p icmp -j ACCEPT
iptables -t filter -I FORWARD -p icmp -j ACCEPT
# SSH
iptables -t filter -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -t filter -I INPUT -p tcp --sport 22 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 22 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 22 -j ACCEPT
iptables -t filter -I INPUT -p tcp --dport 839 -j ACCEPT
iptables -t filter -I INPUT -p tcp --sport 839 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 839 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 839 -j ACCEPT
# DNS 
iptables -t filter -I INPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -I INPUT -p udp --dport 53 -j ACCEPT
iptables -t filter -I INPUT -p tcp --sport 53 -j ACCEPT
iptables -t filter -I INPUT -p udp --sport 53 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 53 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 53 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 53 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 53 -j ACCEPT
# http 
iptables -t filter -I FORWARD -p tcp --dport 80 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 80 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 80 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 80 -j ACCEPT
iptables -t filter -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -I INPUT -p tcp --sport 80 -j ACCEPT
iptables -t filter -I INPUT -p udp --dport 80 -j ACCEPT
iptables -t filter -I INPUT -p udp --sport 80 -j ACCEPT
# https 
iptables -t filter -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -I INPUT -p tcp --sport 443 -j ACCEPT
iptables -t filter -I INPUT -p udp --dport 443 -j ACCEPT
iptables -t filter -I INPUT -p udp --sport 443 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 443 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 443 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 443 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 443 -j ACCEPT
# smtp - pop - imap
iptables -t filter -I FORWARD -p tcp -m multiport --dports 25,110,143,587,993,995 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --sports 25,110,143,587,993,995 -j ACCEPT
# ipp - impressao via Internet - Internet Printing Protocol
iptables -I FORWARD -p tcp --dport 631 -j ACCEPT
iptables -I FORWARD -p tcp --sport 631 -j ACCEPT
iptables -I FORWARD -p udp --dport 631 -j ACCEPT
iptables -I FORWARD -p udp --sport 631 -j ACCEPT
# ftp
iptables -I INPUT -p tcp --dport 21 -j ACCEPT
iptables -I INPUT -p tcp --sport 21 -j ACCEPT
iptables -I FORWARD -p tcp --dport 21 -j ACCEPT
iptables -I FORWARD -p tcp --sport 21 -j ACCEPT
# ntp
iptables -I INPUT -p udp --dport 123 -j ACCEPT
iptables -I INPUT -p udp --sport 123 -j ACCEPT
iptables -I FORWARD -p udp --dport 123 -j ACCEPT
iptables -I FORWARD -p udp --sport 123 -j ACCEPT
# EPMAP Microsoft RPC Serviço de localização
iptables -t filter -I FORWARD -p udp --dport 135 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 135 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 135 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 135 -j ACCEPT
# netbios
iptables -t filter -I INPUT -p tcp -m multiport --dports 137,138,139 -j ACCEPT
iptables -t filter -I INPUT -p udp -m multiport --dports 137,138,139 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --dports 137,138,139 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --sports 137,138,139 -j ACCEPT
iptables -t filter -I FORWARD -p udp -m multiport --dports 137,138,139 -j ACCEPT
iptables -t filter -I FORWARD -p udp -m multiport --sports 137,138,139 -j ACCEPT
# nfs
#iptables -t filter -I INPUT -p udp --dport 3049 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 3049 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 3049 -j ACCEPT
# ssdp Microsoft SSDP Habilita a descoberta de dispositivos UPnP
#iptables -t filter -I INPUT -p udp --dport 1900 -j ACCEPT
#iptables -t filter -I FORWARD -p udp --dport 1900 -j ACCEPT
# bgp - Border Gateway Protocol - Protocolo de limite do gateway
#iptables -t filter -I INPUT -p tcp --dport 179 -j ACCEPT
#iptables -t filter -I FORWARD -p tcp --dport 179 -j ACCEPT
# snmp
#iptables -I INPUT -p tcp --dport 161 -j ACCEPT
#iptables -I INPUT -p udp --dport 161 -j ACCEPT
iptables -I FORWARD -p tcp --dport 161 -j ACCEPT
iptables -I FORWARD -p tcp --sport 161 -j ACCEPT
iptables -I FORWARD -p udp --dport 161 -j ACCEPT
iptables -I FORWARD -p udp --sport 161 -j ACCEPT
# smb
iptables -I FORWARD -p udp --dport 445 -j ACCEPT
iptables -I FORWARD -p udp --sport 445 -j ACCEPT
iptables -I FORWARD -p tcp --dport 445 -j ACCEPT
iptables -I FORWARD -p tcp --sport 445 -j ACCEPT

# syslog
iptables -I INPUT -p udp --dport 514 -j ACCEPT
iptables -I INPUT -p udp --sport 514 -j ACCEPT
iptables -I FORWARD -p udp --dport 514 -j ACCEPT
iptables -I FORWARD -p udp --sport 514 -j ACCEPT

# openvpn 
iptables -t filter -I INPUT -p udp -m multiport --dports 1194,1195,443 -j ACCEPT
iptables -t filter -I INPUT -p udp -m multiport --sports 1194,1195,443 -j ACCEPT
iptables -t filter -I FORWARD -p udp -m multiport --dports 1194,1195,443 -j ACCEPT
iptables -t filter -I FORWARD -p udp -m multiport --sports 1194,1195,443 -j ACCEPT
# solidworks 
iptables -t filter -I FORWARD -p tcp --dport 25734 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 25734 -j ACCEPT
# mysql glpi 
iptables -t filter -I FORWARD -p tcp --dport 3306 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 3306 -j ACCEPT
# zabbix 
iptables -t filter -I INPUT -p tcp -m multiport --dports 10050,10051 -j ACCEPT
iptables -t filter -I INPUT -p tcp -m multiport --sports 10050,10051 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --dports 10050,10051 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --sports 10050,10051 -j ACCEPT
# ntop 
iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
# bacula
#iptables -t filter -I INPUT -p tcp -m multiport --dports 9101,9102,9103 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --dports 9101,9102,9103 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --sports 9101,9102,9103 -j ACCEPT
# Cobian
iptables -t filter -I FORWARD -p tcp --dport 16020 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 16020 -j ACCEPT
# ocsinventory
#iptables -t filter -I FORWARD -p tcp --dport 16020 -j ACCEPT
# rdp
iptables -t filter -I FORWARD -p tcp --dport 3389 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 3389 -j ACCEPT
# pabx
iptables -t filter -I FORWARD -p tcp --dport 5060 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 5060 -j ACCEPT
# comport bilhetagem ligacoes
iptables -t filter -I FORWARD -p tcp --dport 2300 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 2300 -j ACCEPT
# proxmox externo vpn
iptables -t filter -I FORWARD -p tcp --dport 8006 -j ACCEPT
# netviewer kyocera
iptables -t filter -I FORWARD -p tcp --sport 9100 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 9100 -j ACCEPT
iptables -t filter -I INPUT -p tcp --sport 9100 -j ACCEPT
iptables -t filter -I INPUT -p tcp --dport 9100 -j ACCEPT
# Tight VNC
iptables -t filter -I FORWARD -p tcp --sport 5800 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 5800 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 5900 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 5900 -j ACCEPT

# receita net 
iptables -t filter -I FORWARD -p tcp --dport 3456 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 3456 -j ACCEPT
# conectividade social 
iptables -t filter -I FORWARD -p tcp --dport 2631 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 2631 -j ACCEPT
# Plataforma CRDC
iptables -t filter -I FORWARD -p tcp --dport 8443 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 8443 -j ACCEPT
# cat dataprev
iptables -t filter -I FORWARD -p tcp --dport 5022 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 5022 -j ACCEPT
# cameras de seguranca
iptables -t filter -I FORWARD -p tcp -m multiport --dports 8001,8002,8003,9000,9001,9002,9003,9006,9007,9008,9009 -j ACCEPT
# protheus 
iptables -t filter -I FORWARD -p tcp -m multiport --dports 10088,10020,10021,10023,10025,6125,7444,10086,10031,10030 -j ACCEPT
# protheus site suporte
iptables -t filter -I FORWARD -p tcp -m multiport --dports 449,448 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --sports 449,448 -j ACCEPT
# site samarithano
iptables -t filter -I FORWARD -p tcp --dport 8080 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 8080 -j ACCEPT
# comprova financeiro
iptables -t filter -I FORWARD -p tcp --dport 8443 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 8443 -j ACCEPT
# della volpe consulta contabil
iptables -t filter -I FORWARD -p tcp --dport 6917 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 6917 -j ACCEPT
# Notas Rotem 
iptables -t filter -I FORWARD -p tcp -m multiport --dports 7001,8081 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --sports 7001,8081 -j ACCEPT
# PRIP app nextel
iptables -t filter -I FORWARD -p udp -m multiport --dports 16700,16800 -j ACCEPT
iptables -t filter -I FORWARD -p udp -m multiport --sports 16700,16800 -j ACCEPT
# SMTP Tec-Ratol 
iptables -t filter -I FORWARD -p udp --sport 465 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 465 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 465 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --dport 465 -j ACCEPT
# Ligacoes Whatsapp
iptables -t filter -I FORWARD -p udp --dport 3478 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 3478 -j ACCEPT
# Ligacoes FaceTime Apple
iptables -t filter -I FORWARD -p tcp --dport 5223 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 5223 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 16384:16387 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 16384:16387 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 16393:16402 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 16393:16402 -j ACCEPT
# TeamViewer Quick Support
iptables -t filter -I FORWARD -p tcp --dport 5938 -j ACCEPT
iptables -t filter -I FORWARD -p tcp --sport 5938 -j ACCEPT
iptables -t filter -I FORWARD -p udp --dport 5938 -j ACCEPT
iptables -t filter -I FORWARD -p udp --sport 5938 -j ACCEPT
# Cameras LiveYes - Residencial Julia 
iptables -t filter -I FORWARD -p tcp -m multiport --sports 3056,5224,3688,50573,50579,50581,50582,50601,50602,50603,50604,50640,50641,50651,50652 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --sports 50705,50708,50709,50716,50750,50751,50752 -j ACCEPT
iptables -t filter -I FORWARD -p tcp -m multiport --dports 3056,3688,5224,5226,8857,8876,50625,50628,50719 -j ACCEPT



### REDIRECIONAMENTOS
 
# apache 192.168.0.10
#iptables -t nat -I PREROUTING -d 192.168.1.104 -p tcp --dport 80 -j DNAT --to 192.168.0.10:80
#iptables -t nat -I PREROUTING -d 192.168.1.104 -p tcp --dport 8080 -j DNAT --to 192.168.0.10:80
#iptables -t nat -I PREROUTING -d 192.168.1.104 -p tcp --dport 81 -j DNAT --to 192.168.0.10:80
# cameras de seguranca
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9000 -j DNAT --to 192.168.1.50:9000
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9001 -j DNAT --to 192.168.1.50:9001
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9002 -j DNAT --to 192.168.1.50:9002
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9003 -j DNAT --to 192.168.1.50:9003
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9006 -j DNAT --to 192.168.1.85:9006
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9007 -j DNAT --to 192.168.1.85:9007
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9008 -j DNAT --to 192.168.1.85:9008
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 9009 -j DNAT --to 192.168.1.85:9009
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 8001 -j DNAT --to 192.168.1.86:8001
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 8002 -j DNAT --to 192.168.1.86:8002
iptables -t nat -I PREROUTING -p tcp -d 189.109.62.50 --dport 8003 -j DNAT --to 192.168.1.86:8003
 
 
### BLOQUEIOS POR STRING
iptables -I FORWARD -s 192.168.1.0/24 -m string --algo kmp --string "thepiratebay.sx" -j DROP
iptables -I FORWARD -s 192.168.1.0/24 -m string --algo kmp --string "gwea.com" -j DROP
#iptables -I FORWARD -s 192.168.1.0/24 -m string --algo kmp --string "youtube.com" -j DROP
#iptables -I FORWARD -s 192.168.1.0/24 -m string --algo kmp --string "facebook.com" -j DROP
#iptables -I FORWARD -s 192.168.1.0/24 -m string --algo kmp --string "globoesporte.globo.com" -j DROP

### BLOQUEIOS DE USUARIOS
#iptables -I FORWARD -s 192.168.1.5 -j DROP
