# shellscript
Repositório de shellscripts

================================================================================================


## Firewall, Loadbalance e Failover de links
Obs.: Os 3 scripts devem ser executados na sequencia.: 
1. firewall.sh 
2. balanceamento.sh 
3. failover.sh

Obs.: Ajuste os scripts de acordo com sua infra.

Deixe os scripts p/ inicializar junto com o sistema operacional no **/etc/rc.local**

```sh
# Iniciando firewall
/etc/init.d/firewall.sh

# Balanceamento de links
/etc/init.d/balanceamento.sh

# Failover de links
nohup > /dev/null /etc/init.d/failover.sh &
```
================================================================================================

## Monitor de energia
Obs.: Realizar o teste de ping, em 3 dispositivos de rede que estejam fora do nobreak. E desliga os servidores, caso não haja resposta. Pois indica parada de energia.

1. monitorEnergia.sh

Deixe o script p/ inicializar junto com o sistema operacional no **/etc/rc.local**

```sh
# Monitor de energia
/etc/init.d/monitorEnergia.sh > /var/log/monitorEnergia.log
```
================================================================================================
