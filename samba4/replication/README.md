# Replicação Samba4

Scripts relacionados a replicação manual do SYSVOL entre Domain Controllers Samba4.

## Scripts

### samba-ad-sync-sysvol.sh

Executa sincronização do SYSVOL utilizando:
- rsync;
- SSH;
- preservação de permissões e ACLs;
- sincronização para múltiplos DCs.

Também executa:
- `samba-tool ntacl sysvolcheck`

## Requisitos

- Samba4 AD DC
- rsync
- ssh

## Observações

- Recomendado utilizar autenticação SSH por chave.
- Ajuste IPs e caminhos conforme seu ambiente.
- Execute preferencialmente como `root`.
