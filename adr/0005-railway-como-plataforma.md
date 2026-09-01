# ADR-0005 — Railway como plataforma de deploy

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

O projeto precisa implantar Rails, PostgreSQL, worker e arquivos com baixa carga operacional inicial.

## Decisão

Usar Railway para produção, com serviços separados para web e worker, PostgreSQL gerenciado no projeto e variáveis protegidas para configuração.

Jobs agendados e ambiente de homologação serão detalhados quando custos e necessidades estiverem confirmados.

## Consequências

### Positivas

- Provisionamento e integração simples entre serviços.
- Rede privada, variáveis e deploys no mesmo projeto.
- Suporte documentado a Rails e processos worker.

### Negativas

- Dependência operacional e de preços do Railway.
- Alguns recursos podem exigir serviços sempre ativos.
- Estratégia de backup e restauração precisa ser explicitamente configurada e testada.

## Alternativas consideradas

- Render, Fly.io e Heroku: não escolhidos por preferência explícita pelo Railway.
- Infraestrutura própria: rejeitada pela operação desnecessária no MVP.

## Referências externas

- [Deploy de Rails no Railway](https://docs.railway.com/guides/rails)

## Referências internas

- [SPEC-11 — Deploy e operação](../specs/infraestrutura/spec-11-deploy-operacao.md)
