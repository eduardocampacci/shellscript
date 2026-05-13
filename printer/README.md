# Controle de Impressoras

Scripts para coleta, monitoramento e controle de impressoras via SNMP.

## Scripts

### controle-impressoras.sh

Realiza:

- coleta de contadores via SNMP;
- identificação de modelo e número de série;
- cálculo de produção entre coletas;
- controle de impressões PB e coloridas;
- controle de digitalizações;
- geração de arquivos CSV;
- geração de logs;
- backup automático dos arquivos coletados.

## Requisitos

- bash
- snmpget
- acesso SNMP nas impressoras
- permissões de escrita no diretório configurado

## Estrutura Gerada

O script cria automaticamente:

```text
/opt/impressoras/
├── controle_impressoras.csv
├── producao_mensal.csv
├── coleta.log
└── backup/
```

## Configuração

Antes de executar, ajuste:

- comunidade SNMP;
- IPs das impressoras;
- caminhos dos arquivos;
- OIDs utilizados no ambiente.

## Execução

Execução manual:

```bash
./controle-impressoras.sh
```

Execução via `crontab`:

```cron
0 * * * * /opt/impressoras/scripts/controle-impressoras.sh
```

O exemplo acima executa a coleta a cada hora.

## Observações

- Atualmente possui suporte para equipamentos Ricoh e Kyocera.
- O script utiliza SNMP v2c.
- Impressoras offline são registradas automaticamente no CSV.
