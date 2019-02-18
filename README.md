# shellscript
Repositório de shellscripts

==============================================================================================


## Firewall, Loadbalance e Failover de links
Obs.: Os 3 scripts devem ser executados na sequencia.: 
1. firewall.sh 
2. balanceamento.sh 
3. failover.sh

Obs.: Ajuste as variaveis dos scripts, de acordo com sua infra. 

Obs.: Não esqueça de criar as tabelas de roteamento, em /etc/iproute2/rt_tables. Inclua as tabelas, exemplo.:
```sh
# Tabelas de balanceamento de links
200 link1 #GVT
201 link2 #VIVO
```

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

## Monitor de energia - para desligamento remoto dos servidores.
Obs.: Realizar o teste de ping, em 3 dispositivos de rede que estejam fora do nobreak. E desliga os servidores, caso não haja resposta. Pois indica parada de energia.

1. monitorEnergia.sh

Obs.: Ajuste as variaveis e hosts no comando ssh do script, de acordo com sua infra.


Adicione o script no crontab, para que seja agendado um periodo de execução e verificação.
No exemplo abaixo, esta agendado p/ ser executado a cada 10 minutos.

```sh
# Monitor de energia
*/10 * * * *    /etc/init.d/monitorEnergia.sh > /var/log/monitorEnergia.log
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

==============================================================================================

==============================================================================================

## RClone - Sincronização com serviços de armazenamento na nuvem.
Obs.: Rclone é um programa de linha de comando, para sincronizar arquivos e diretórios.

- Alguns serviços suportados.: 
Alibaba Cloud (Aliyun) Object Storage System (OSS)  
Amazon Drive   (See note)
Amazon S3  
Backblaze B2  
Box  
Ceph  
DigitalOcean Spaces  
Dreamhost  
Dropbox  
FTP  
Google Cloud Storage  
Google Drive  
HTTP  
Hubic  
Jottacloud  
IBM COS S3  
Memset Memstore  
Mega  
Microsoft Azure Blob Storage  
Microsoft OneDrive  
Minio  
Nextcloud  
OVH  
OpenDrive  
Openstack Swift  
Oracle Cloud Storage  
ownCloud  
pCloud  
put.io  
QingStor  
Rackspace Cloud Files  
Scaleway  
SFTP  
Wasabi  
WebDAV  
Yandex Disk  
The local filesystem  
