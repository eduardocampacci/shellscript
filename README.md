# shellscript
Repositório de shellscripts

==============================================================================================


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
==============================================================================================

## Monitor de energia
Obs.: Realizar o teste de ping, em 3 dispositivos de rede que estejam fora do nobreak. E desliga os servidores, caso não haja resposta. Pois indica parada de energia.

1. monitorEnergia.sh

Deixe o script p/ inicializar junto com o sistema operacional no **/etc/rc.local**

```sh
# Monitor de energia
/etc/init.d/monitorEnergia.sh > /var/log/monitorEnergia.log
```
==============================================================================================

## Manipulação de arquivos antigos e duplicados.
Obs.: Os 3 scripts, possuem interacao para atribuir valores nas variaveis

1. dupFiles.sh
- Script para localizar arquivos duplicados. 
- Com interação para atribuir valores nas variaveis DIRETORIO e LOGS.
- Exporta um log em .xls, para que seja possivel analise. 

2. moveOldFiles.sh 
- Script para mover arquivos antigos.
- Com interacao para atribuir valores nas variaveis PASTA, DIAS e BACKUP.
- Este script move todos os arquivos antigos p/ a pasta de backup.

3. oldFiles.sh
- Script para localizar arquivos antigos.
- Com interacao para atribuir valores nas variaveis PASTA, DIAS e LOG.
- Exporta um log em .csv, para que seja possivel analise. 
