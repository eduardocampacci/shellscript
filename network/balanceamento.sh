####### INICIO VARIAVEIS

### Rede Link1
#GVT
INTERFACE_LINK1=enp0s3
TABELA_LINK1=link1
IP_LINK1=192.168.1.17
REDE_LINK1=192.168.1.0/24
GATEWAY_LINK1=192.168.1.254

### Rede Link2
# VIVO
INTERFACE_LINK2=enp0s8
TABELA_LINK2=link2
IP_LINK2=10.0.3.15
REDE_LINK2=10.0.3.0/24
GATEWAY_LINK2=10.0.3.2

####### FIM VARIAVEIS

# EXLUIR ROTAS PADROES ATUAIS
ip route del default &> /dev/null
ip route del default &> /dev/null
ip route del default &> /dev/null

# ATUALLIZAR AS ROTAS DE ACORDO COM AS TABELAS CRIADAS PARA BALANCEAMENTO
ip route flush table $TABELA_LINK1
ip route flush table $TABELA_LINK2

# ROTEAMENTO GVT
ip route add $REDE_LINK1 dev $INTERFACE_LINK1 src $IP_LINK1 table $TABELA_LINK1
ip route add default via $GATEWAY_LINK1 table $TABELA_LINK1

# ROTEAMENTO VIVO
ip route add $REDE_LINK2 dev $INTERFACE_LINK2 src $IP_LINK2 table $TABELA_LINK2
ip route add default via $GATEWAY_LINK2 table $TABELA_LINK2

ip rule add from $IP_LINK1 table $TABELA_LINK1
ip rule add from $IP_LINK2 table $TABELA_LINK2

ip rule add fwmark 0x10 lookup $TABELA_LINK1 prio 3
ip rule add fwmark 0x20 lookup $TABELA_LINK2 prio 3

# ADICIONANDO ROTA PADRAO
ip route add default scope global nexthop via $GATEWAY_LINK1 dev $INTERFACE_LINK1 weight 2 nexthop via $GATEWAY_LINK2 dev $INTERFACE_LINK2 weight 1

ip route flush cache

