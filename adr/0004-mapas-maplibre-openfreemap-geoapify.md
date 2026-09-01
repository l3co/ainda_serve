# ADR-0004 — MapLibre, OpenFreeMap e Geoapify

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

O produto precisa de mapa, autocomplete, geocodificação, distância e abertura de rota, mas a API completa do Google Maps pode gerar custos por carregamento e operação.

## Decisão

- Renderizar mapas com MapLibre GL JS.
- Usar OpenFreeMap como mapa-base público no MVP.
- Usar Geoapify para autocomplete e geocodificação.
- Calcular distância aproximada no PostgreSQL.
- Abrir rota por link externo do Google Maps, sem integrar sua API paga.
- Preservar atribuições exigidas por OpenStreetMap, OpenFreeMap e Geoapify.

Não será criada interface abstrata para múltiplos fornecedores antes de existir uma segunda implementação. A integração Geoapify ficará em cliente focado, com timeout e tratamento de falhas.

## Consequências

### Positivas

- Custo inicial reduzido.
- Resultados geocodificados podem ser armazenados conforme os termos informados pelo Geoapify.
- MapLibre permite trocar o provedor de mapa sem substituir toda a experiência.
- Nenhum faturamento do Google Maps é necessário no MVP.

### Negativas

- OpenFreeMap público não oferece SLA ou suporte personalizado.
- Qualidade de endereços varia conforme dados abertos.
- Geoapify possui limite gratuito e uso comercial limitado.
- A solução depende de atribuição visível.

## Alternativas consideradas

- Google Maps Platform: rejeitada no MVP por custo e restrições.
- LocationIQ: oferece faixa gratuita, mas possui restrições de cache no plano gratuito.
- Mapbox: geocodificação permanente paga e maior dependência do fornecedor.
- Hospedar mapas próprios: rejeitado pela carga operacional.

## Gatilhos para revisão

- Indisponibilidade ou mudança de termos do OpenFreeMap.
- Limites do Geoapify atingidos com frequência.
- Qualidade insuficiente de endereços brasileiros.
- Necessidade de SLA contratado.

## Referências externas

- [OpenFreeMap](https://openfreemap.org/)
- [Geoapify — preços](https://www.geoapify.com/pricing/)
- [Geoapify — geocodificação e armazenamento](https://www.geoapify.com/geocoding-api/)

## Referências internas

- [SPEC-03 — Busca e localização](../specs/produto/spec-03-busca-localizacao.md)
