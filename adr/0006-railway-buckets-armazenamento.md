# ADR-0006 — Railway Buckets para armazenamento

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

Anúncios, perfis, denúncias e exportações geram arquivos que não devem depender do filesystem efêmero do processo web.

## Decisão

Usar Active Storage com Railway Buckets, mantendo os objetos privados por padrão e servindo-os por URL temporária ou aplicação autorizada.

## Consequências

### Positivas

- Arquivos permanecem no mesmo provedor do deploy.
- Interface compatível com S3 e integração natural com Active Storage.
- Menos contas e credenciais externas que Cloudflare R2.

### Negativas

- Custo pode superar opções com faixa gratuita.
- Saída e acesso precisam ser monitorados.
- Migração futura deve preservar chaves, metadados e variantes.

## Alternativas consideradas

- Cloudflare R2: rejeitada inicialmente apesar da faixa gratuita, em favor da simplicidade.
- Volume persistente: rejeitado para uploads distribuídos e acesso por múltiplos processos.
- Armazenamento local do container: rejeitado por falta de durabilidade.

## Requisitos associados

- Remover metadados de localização de imagens.
- Validar tipo e tamanho no servidor.
- Não expor evidências por URL pública permanente.

## Referências externas

- [Railway Buckets](https://docs.railway.com/storage-buckets)

## Referências internas

- [SPEC-10 — Qualidade, segurança e privacidade](../specs/qualidade/spec-10-qualidade-seguranca-privacidade.md)
