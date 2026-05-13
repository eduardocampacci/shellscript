# Samba4 Scripts

Scripts utilizados para administração e automação de ambientes Samba Active Directory.

## Estrutura

| Pasta | Descrição |
|---|---|
| `backup/` | Backup, restore e validação do AD |
| `replication/` | Replicação manual do SYSVOL |

## Scripts

### Backup

| Script | Descrição |
|---|---|
| `samba-ad-backup.sh` | Executa backups online, offline e rename do Samba AD |
| `samba-ad-restore-test.sh` | Realiza testes automáticos de restore e validação do backup |

### Replication

| Script | Descrição |
|---|---|
| `samba-ad-sync-sysvol.sh` | Sincroniza o SYSVOL entre Domain Controllers usando rsync |

## Observações

- Scripts desenvolvidos para ambientes Linux com Samba4 AD DC.
- Alguns scripts precisam ser executados como `root`.
- Revise IPs, caminhos e credenciais antes de usar em produção.
