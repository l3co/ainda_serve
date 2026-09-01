# ADR-0003 — PostgreSQL para busca e dados geográficos

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

O MVP precisa filtrar materiais por texto, categoria, preço, quantidade e distância. Um motor separado aumentaria operação e sincronização antes de haver volume comprovado.

## Decisão

Usar PostgreSQL como fonte de verdade e primeira solução para busca textual, filtros e cálculo de distância aproximada.

Extensões, índices e representação geográfica exatos serão escolhidos na SPEC de implementação após confirmar o PostgreSQL disponível no Railway.

## Consequências

### Positivas

- Menos serviços e nenhuma sincronização de índice externo.
- Transações de anúncio, saldo e busca permanecem coerentes.
- Solução suficiente para validar uso real.

### Negativas

- Relevância textual e recursos avançados são mais limitados.
- Consultas geográficas exigem índices e medição cuidadosos.

## Alternativas consideradas

- Elasticsearch ou OpenSearch: adiados até volume ou relevância justificarem.
- Algolia: adiada por custo, dependência e sincronização.
- Cálculo exclusivo no navegador: rejeitado por privacidade e paginação inconsistente.

## Gatilhos para revisão

- Latência não aceitável com índices adequados.
- Necessidade comprovada de busca tolerante a erros ou ranking avançado.
- Volume que torne a consulta geográfica inviável no banco principal.

## Referências

- [SPEC-03 — Busca e localização](../specs/produto/spec-03-busca-localizacao.md)
