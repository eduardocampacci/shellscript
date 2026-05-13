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

## Observações

- Scripts desenvolvidos para Linux.
- Recomendado executar como `root`.
- Ajuste IPs, caminhos e credenciais antes do uso.
