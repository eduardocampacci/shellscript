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

## RClone - Sincronização com serviços de armazenamento na nuvem.
Obs.: Rclone é um programa de linha de comando, para sincronizar arquivos e diretórios.

- Acesse o site https://rclone.org/ 
- Veja os serviços suportados e manuais de configuração. 



1. Baixe e instale o rclone.: https://rclone.org/downloads/

2. Teste o programa.
```sh
rclone --help
```

3. Configure o rclone.
```sh
rclone config
```
Obs.: Siga o manual do site, p/ configurar corretamente o rclone de acordo com o serviço desejado. 

4. Opções de configuração.
```sh
➜  rclone rclone config
No remotes found - make a new one
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n
name> dropbox_hw
Type of storage to configure.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / A stackable unification remote, which can appear to merge the contents of several remotes
   \ "union"
 2 / Alias for a existing remote
   \ "alias"
 3 / Amazon Drive
   \ "amazon cloud drive"
 4 / Amazon S3 Compliant Storage Providers (AWS, Ceph, Dreamhost, IBM COS, Minio)
   \ "s3"
 5 / Backblaze B2
   \ "b2"
 6 / Box
   \ "box"
 7 / Cache a remote
   \ "cache"
 8 / Dropbox
   \ "dropbox"
 9 / Encrypt/Decrypt a remote
   \ "crypt"
10 / FTP Connection
   \ "ftp"
11 / Google Cloud Storage (this is not Google Drive)
   \ "google cloud storage"
12 / Google Drive
   \ "drive"
13 / Hubic
   \ "hubic"
14 / JottaCloud
   \ "jottacloud"
15 / Local Disk
   \ "local"
16 / Mega
   \ "mega"
17 / Microsoft Azure Blob Storage
   \ "azureblob"
18 / Microsoft OneDrive
   \ "onedrive"
19 / OpenDrive
   \ "opendrive"
20 / Openstack Swift (Rackspace Cloud Files, Memset Memstore, OVH)
   \ "swift"
21 / Pcloud
   \ "pcloud"
22 / QingCloud Object Storage
   \ "qingstor"
23 / SSH/SFTP Connection
   \ "sftp"
24 / Webdav
   \ "webdav"
25 / Yandex Disk
   \ "yandex"
26 / http Connection
   \ "http"
Storage> 8
** See help for dropbox backend at: https://rclone.org/dropbox/ **

Dropbox App Client Id
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_id> 
Dropbox App Client Secret
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_secret> 
Edit advanced config? (y/n)
y) Yes
n) No
y/n> n
Remote config
Use auto config?
 * Say Y if not sure
 * Say N if you are working on a remote or headless machine
y) Yes
n) No
y/n> n
For this to work, you will need rclone available on a machine that has a web browser available.
Execute the following on your machine:
        rclone authorize "dropbox"
Then paste the result below:
result> COLADO AQUI O TOKEN PERMITINDO O ACESSO DO RCLONE NO DROPBOX
2019/02/18 11:12:53 ERROR : Failed to save new token in config file: section 'dropbox_hw' not found
--------------------
[dropbox_hw]
type = dropbox
token = AQUI O TOKEN PERMITINDO O ACESSO DO RCLONE NO DROPBOX
--------------------
y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y
Current remotes:

Name                 Type
====                 ====
dropbox_hw           dropbox

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q

```


5. Crie o agendamento no crontab, no exemplo foi agendado p/ executar a cada 30min.  
```sh
# rclone
*/30 * * * *    /etc/init.d/rclone-cron.sh > /var/log/rclone-cron.log
```

OBS.: No script rclone-cron.sh, ajuste a largura de banda, arquivos que devem ser excluidos, caminho de origem e caminho de destino.
```sh
# --bwlimit=0.375M - Segue.: 10M link total, usar 3M do link total p/ o rclone. Então 3/8 = 0.375M
# --exclude "*.{pst,tar}" - Exclui da sincronização arquivos da extensão .pst e .tar.
# --tpslimit=9 - Limitar o numero de requisição.
rclone sync -P --bwlimit=0.375M --tpslimit=9 --exclude "*.{pst,tar}" /home/eduardo/Documentos/rclone/ dropbox_hw:arquivos/rclone
```
==============================================================================================
