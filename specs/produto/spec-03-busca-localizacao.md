# SPEC-03 — Busca e localização

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-02, SPEC-10, SPEC-12 e SPEC-14
**ADRs:** 0003, 0004

## Estado

Proposta.

## Objetivo

Permitir descoberta nacional de materiais por texto, filtros e distância, preservando o endereço exato.

## Escopo

### Incluído

- Busca pública, lista e mapa.
- Localização atual ou informada manualmente.
- Distância aproximada, raio configurável e ampliação automática.
- Filtros, ordenação, favoritos e pesquisas salvas.
- Geocodificação e abertura externa de rota.

### Excluído

- Navegação curva a curva dentro da plataforma.
- Exibição pública do endereço, bairro ou coordenada real.
- Elasticsearch ou serviço dedicado de busca no MVP.

## Contrato da consulta

| Entrada | Obrigatória | Regra |
|---|---:|---|
| Palavra-chave | Não | Texto normalizado e limitado |
| Origem | Para distância | Localização atual consentida ou endereço/CEP/cidade informado |
| Raio | Não | Uma opção suportada; padrão a confirmar na interface |
| Categoria | Não | Categoria ativa |
| Modalidade | Não | Venda, doação ou ambas |
| Faixa de preço | Não | Aplicável a vendas; limites coerentes |
| Conservação | Não | Uma ou mais opções do catálogo |
| Quantidade | Não | Positiva na unidade do anúncio, sem conversão indevida |
| Ordenação | Não | Opção da lista aprovada |

## Contrato do resultado público

O resultado pode conter título, modalidade, preço aplicável, saldo, unidade, condição, fotos aprovadas, nome público do anunciante, reputação agregada, cidade, estado, distância aproximada e posição deslocada. Nunca contém endereço, bairro, coordenada real, telefone, e-mail ou documento.

## Processamento geográfico

```text
origem consentida/informada → geocodificação → consulta por distância real no servidor
→ ordenação/filtro → transformação para distância aproximada e ponto público deslocado
→ resposta pública
```

O cálculo interno pode usar coordenadas reais. A projeção enviada ao cliente público não pode reutilizar essas coordenadas.

## Comportamento de degradação

| Falha | Resultado esperado |
|---|---|
| Geolocalização negada | Oferecer entrada manual sem insistir na permissão |
| Geoapify indisponível | Preservar busca textual e por localidade já conhecida; explicar limitação |
| Mapa-base indisponível | Manter lista e filtros funcionais |
| Nenhum resultado no raio | Oferecer ampliação claramente consentida/informada |
| Localidade ambígua | Pedir seleção entre opções sem escolher silenciosamente |

## Requisitos funcionais

### Acesso público

- **BUS-001:** Visitantes podem pesquisar, filtrar e abrir anúncios públicos sem conta.
- **BUS-002:** Solicitar, conversar e receber alertas exige conta confirmada; favoritar exige conta, mas não confirmação de e-mail.
- **BUS-003:** Páginas públicas podem ser indexadas por mecanismos de busca sem expor dados pessoais ou endereço exato.

### Origem da busca

- **BUS-004:** O usuário pode usar localização atual do dispositivo ou informar endereço, CEP ou cidade.
- **BUS-005:** A permissão de localização deve ser solicitada de forma contextual.
- **BUS-006:** Se a permissão for negada, a plataforma não deve solicitar novamente automaticamente e deve oferecer busca manual.
- **BUS-007:** A origem informada deve poder ser reutilizada conforme as preferências e regras de privacidade.

### Privacidade geográfica

- **BUS-008:** Resultados públicos exibem distância aproximada, nunca endereço ou bairro.
- **BUS-009:** O mapa pode mostrar um círculo aproximado, baseado em ponto deslocado ou centro regional.
- **BUS-010:** O centro visual não pode coincidir com a coordenada exata do material.
- **BUS-011:** O endereço exato só fica disponível ao destinatário selecionado.
- **BUS-012:** Cancelamento da seleção remove imediatamente o acesso ao endereço exato.

### Filtros e ordenação

- **BUS-013:** Filtros iniciais incluem palavra-chave, categoria, modalidade, distância, faixa de preço, conservação, quantidade e disponibilidade.
- **BUS-014:** O usuário pode escolher raios de 5, 10, 25, 50 ou 100 km, com possibilidade de evolução do catálogo.
- **BUS-015:** Sem resultados, a plataforma pode ampliar o raio após avisar claramente o usuário.
- **BUS-016:** Ordenações incluem menor distância, mais recentes, menor preço, maior quantidade e melhor reputação.
- **BUS-017:** Anúncios patrocinados futuros devem ser identificados e não podem ocultar resultados orgânicos relevantes.

### Exibição

- **BUS-018:** Resultados devem alternar entre lista e mapa.
- **BUS-019:** A página inicial oferece busca por material e localização, categorias e anúncios próximos.
- **BUS-020:** A experiência deve funcionar em celular, computador e PWA.
- **BUS-021:** Mapas devem incluir atribuições obrigatórias dos fornecedores de dados.

### Favoritos e pesquisas salvas

- **BUS-022:** Usuário autenticado pode favoritar e desfavoritar anúncios.
- **BUS-023:** Favoritos podem notificar mudanças de preço, quantidade e disponibilidade de forma agrupada.
- **BUS-024:** Usuário confirmado pode salvar uma combinação de busca, filtros, localização e raio.
- **BUS-025:** Pesquisa salva pode gerar aviso imediato ou resumo diário.
- **BUS-026:** Usuário pode pausar ou excluir a pesquisa salva.

### Endereços e retirada

- **BUS-027:** Pessoas e organizações podem cadastrar vários endereços de retirada.
- **BUS-028:** Cada unidade define horários e instruções de retirada.
- **BUS-029:** Após seleção, o destinatário pode abrir a rota em um link externo do Google Maps.

## Decisões técnicas relacionadas

- MapLibre GL JS renderiza o mapa.
- OpenFreeMap fornece o mapa-base no MVP.
- Geoapify realiza autocomplete e geocodificação.
- PostgreSQL executa busca textual, filtros e cálculo inicial de distância.
- Resultados geocodificados devem manter as atribuições exigidas.

## Critérios de aceitação

- [ ] Visitante encontra anúncios sem autenticar.
- [ ] Negar geolocalização mantém a busca manual funcional e não causa novo pedido automático.
- [ ] Nenhuma resposta pública contém coordenada, bairro ou endereço exatos.
- [ ] O ponto público difere da coordenada real e não usa deslocamento previsível por anúncio.
- [ ] Busca por raio retorna materiais compatíveis e informa ampliação automática.
- [ ] Alternância lista/mapa preserva filtros e ordenação.
- [ ] Falha do mapa mantém a lista utilizável.
- [ ] Favoritos e pesquisas salvas respeitam preferências de notificação.
- [ ] Endereço exato aparece somente para destinatário selecionado e é revogado no cancelamento.
- [ ] Atribuições obrigatórias dos fornecedores aparecem nas superfícies aplicáveis.

## Riscos

- Qualidade variável de endereços brasileiros no OpenStreetMap.
- Ausência de SLA no OpenFreeMap público.
- Custo ou limite diário do Geoapify conforme crescimento.
- Reidentificação de endereço se o deslocamento geográfico for previsível.

## Dependências

- [ADR-0003 — PostgreSQL para busca e geografia](../../adr/0003-postgresql-busca-dados-geograficos.md)
- [ADR-0004 — MapLibre, OpenFreeMap e Geoapify](../../adr/0004-mapas-maplibre-openfreemap-geoapify.md)
- [SPEC-10 — Qualidade, segurança e privacidade](../qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-12 — Modelo de domínio e contratos](../arquitetura/spec-12-modelo-dominio-contratos-dados.md)
- [SPEC-14 — Jornadas, interface e PWA](spec-14-jornadas-interface-pwa.md)
