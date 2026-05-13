# Backup e Restore Samba4

Scripts relacionados a backup, restore e validação de ambientes Samba Active Directory.

## Scripts

### samba-ad-backup.sh

Executa:
- backup online;
- backup offline;
- backup rename;
- validação de integridade;
- limpeza de backups antigos;
- sincronização remota via rsync.

### samba-ad-restore-test.sh

Executa:
- restore automático do backup;
- inicialização do ambiente restaurado;
- validação do banco Samba;
- validação de usuários;
- validação de grupos;
- validação do SYSVOL.

## Requisitos

- Samba4 AD DC
- rsync
- ssh
- tar
- samba-tool
- Autenticação SSH por chave entre os servidores

## Configuração

### SSH

É necessário configurar autenticação SSH por chave entre os servidores envolvidos no backup e sincronização.

Exemplo:

```bash
ssh-keygen
ssh-copy-id root@IP_DO_SERVIDOR
```

### Credenciais Samba

Crie o arquivo:

```bash
/root/.samba_creds
```

Conteúdo:

```ini
username=Administrator
password=SENHA
```

Ajuste permissões:

```bash
chmod 600 /root/.samba_creds
```

## Execução do Backup

Execução manual:

```bash
./samba-ad-backup.sh
```

Também pode ser executado automaticamente via `crontab`.

Exemplo:

```cron
0 2 * * * /root/samba/scripts/samba-ad-backup.sh
```

O exemplo acima executa o backup diariamente às 02:00.

## Teste de Restore

O script `samba-ad-restore-test.sh` realiza testes automáticos de restore dos backups Samba AD.

### Funcionamento

O script:

- copia o backup mais recente dos DCs configurados;
- valida a integridade do arquivo `.tar.bz2`;
- executa o restore com `samba-tool domain backup restore`;
- sobe uma instância Samba restaurada em modo de teste;
- executa `dbcheck`;
- lista usuários e grupos;
- valida quantidade mínima de usuários e grupos;
- valida conteúdo do SYSVOL;
- registra o resultado em log.

### Configuração

Antes de executar, revise as variáveis principais no script:

```bash
DC_LIST=(
"DC1|192.168.122.2|/root/samba/bkp_rename"
"DC2|192.168.122.3|/root/samba/bkp_rename"
"DC3|192.168.122.5|/root/samba/bkp_rename"
)

LOCAL_BASE="/root/restore"
NEW_SERVER_NAME="DC-RESTORE"
MIN_USERS=3
MIN_GROUPS=10
MIN_SYSVOL_FILES=1
```

### Requisitos

- backups do tipo `rename`;
- acesso SSH aos DCs de origem;
- autenticação SSH por chave;
- `rsync`;
- `tar`;
- `samba-tool`;
- ambiente de teste separado do domínio de produção.

### Execução

```bash
./samba-ad-restore-test.sh
```

### Observações

- Execute em uma VM ou servidor de teste.
- Não execute diretamente em um DC de produção.
- Ajuste IPs, caminhos e limites mínimos conforme seu ambiente.
- O restore utiliza `--newservername` para restaurar com outro nome de servidor.
- Scripts desenvolvidos para Linux.
- Recomendado executar como `root`.
- Ajuste IPs, caminhos, usuários e credenciais conforme seu ambiente. 
