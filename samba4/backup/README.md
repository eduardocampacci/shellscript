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

Crie o arquivo: /root/.samba_creds

```ini
username=Administrator
password=SENHA
```

Ajuste permissões:

```bash
chmod 600 /root/.samba_creds
```


## Observações

- Scripts desenvolvidos para Linux.
- Recomendado executar como `root`.
- Ajuste IPs, caminhos e credenciais antes do uso.
