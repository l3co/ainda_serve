# SPEC-02 — Anúncios e catálogo de materiais

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-01
**ADRs:** 0003, 0006

## Estado

Proposta.

## Objetivo

Definir catálogo, cadastro, estoque, modalidades, conservação, fotos, validade e publicação de materiais.

## Escopo

### Incluído

- Venda e doação em anúncios separados.
- Lote ou unidade, estoque divisível e unidades padronizadas.
- Categorias e atributos administráveis.
- Fotos, condição, preço, validade e localização de retirada.
- Política de materiais permitidos e proibidos.

### Excluído

- Pagamento dentro da plataforma.
- Importação de catálogo em massa no MVP.
- Avaliação técnica da segurança estrutural pelo Ainda Serve.

## Categorias iniciais

- Alvenaria e concreto.
- Pisos e revestimentos.
- Portas, janelas e esquadrias.
- Madeiras.
- Telhas e coberturas.
- Hidráulica.
- Elétrica.
- Louças e metais sanitários.
- Tintas e acabamentos permitidos.
- Ferramentas e equipamentos.
- Jardinagem e área externa.
- Outros.

## Contrato de publicação

| Grupo | Campo | Regra para publicar |
|---|---|---|
| Identificação | Título e descrição | Obrigatórios, claros e dentro dos limites aprovados |
| Classificação | Categoria e atributos | Categoria ativa; atributos obrigatórios preenchidos |
| Oferta | Modalidade | Exatamente uma entre venda e doação |
| Quantidade | Total, unidade e divisibilidade | Total positivo; unidade ativa; regra parcial explícita |
| Venda | Preço do lote | Obrigatório, positivo e em `BRL` |
| Venda parcial | Preço por unidade | Opcional somente quando a unidade puder ser vendida separadamente |
| Condição | Conservação, defeitos e validade | Condição selecionada e riscos conhecidos declarados |
| Imagem | Fotos | Entre uma e cinco, válidas e ordenadas |
| Localização | Endereço de retirada | Endereço válido; projeção pública aproximada |
| Consentimento | Termo de publicação | Versão vigente aceita antes da publicação |

## Regras de edição

| Alteração | Permitida com solicitação/reserva? | Efeito obrigatório |
|---|---:|---|
| Título e descrição | Sim | Notificar interessados quando relevante |
| Preço | Sim | Registrar alteração e notificar favoritos/interessados |
| Aumentar saldo | Sim | Preservar reservas existentes |
| Reduzir saldo disponível | Sim, até o disponível | Nunca tocar quantidade reservada |
| Modalidade | Não após publicação | Duplicar/criar novo anúncio |
| Unidade de medida | Não após movimentação | Criar novo anúncio ou fluxo de correção aprovado |
| Endereço | Sim | Revogar acesso anterior e notificar selecionados |

## Matriz de estados

| Estado | Encontrável | Aceita solicitação | Transições comuns |
|---|---:|---:|---|
| Rascunho | Não | Não | publicado, cancelado |
| Publicado | Sim | Sim | parcialmente disponível, reservado, pausado, desativado |
| Parcialmente disponível | Sim | Sim | reservado, concluído, pausado |
| Reservado | Não para novo saldo sem disponibilidade | Conforme saldo | parcial, concluído, cancelado |
| Pausado | Não | Não | publicado, cancelado |
| Desativado por inatividade | Não | Não | publicado após confirmação, cancelado |
| Concluído | Não | Não | terminal |
| Cancelado | Não | Não | terminal; duplicação cria outro anúncio |

## Requisitos funcionais

### Catálogo

- **ANU-001:** A administração pode criar, editar, ordenar e desativar categorias, atributos e unidades.
- **ANU-002:** Cada categoria pode definir campos próprios, como validade, volume, metragem, dimensões ou número de peças.
- **ANU-003:** Novos atributos não devem invalidar anúncios existentes sem migração definida.
- **ANU-004:** Unidades devem vir de uma lista administrável e padronizada.

### Cadastro do anúncio

- **ANU-005:** Todo anúncio exige título, descrição, categoria, quantidade, unidade, conservação, modalidade, localização e pelo menos uma foto.
- **ANU-006:** Um anúncio é exclusivamente de venda ou de doação.
- **ANU-007:** Para oferecer o mesmo material nas duas modalidades, o anunciante deve criar dois anúncios.
- **ANU-008:** Anúncios de venda exigem preço em `BRL`.
- **ANU-009:** Venda pode definir preço do lote e preço por unidade quando houver venda parcial.
- **ANU-010:** Anunciante pode indicar se o material é divisível.
- **ANU-011:** Anunciante pode salvar rascunho, duplicar e pausar anúncio.
- **ANU-012:** Cada anúncio aceita entre uma e cinco fotos.
- **ANU-013:** Cada foto aceita JPEG, PNG ou WebP com até 10 MB.
- **ANU-014:** Metadados de localização devem ser removidos das imagens armazenadas.

### Conservação

- **ANU-015:** Estados disponíveis são: novo e lacrado; novo com embalagem aberta; sobra não utilizada; usado em ótimo estado; usado com marcas; necessita reparo.
- **ANU-016:** Defeitos, validade, danos e riscos conhecidos devem ser declarados.
- **ANU-017:** Produtos com validade devem impedir publicação quando vencidos.

### Estoque

- **ANU-018:** O anúncio mantém quantidades disponível, reservada e concluída.
- **ANU-019:** A quantidade nunca pode ficar negativa.
- **ANU-020:** Seleção de interessado move quantidade disponível para reservada.
- **ANU-021:** Cancelamento ou rejeição devolve reserva ao saldo disponível.
- **ANU-022:** Conclusão dá baixa definitiva na quantidade reservada.
- **ANU-023:** Saldo parcial mantém o anúncio publicado como parcialmente disponível.
- **ANU-024:** Deve existir ação rápida para atualizar saldo e permitir que interessados ajustem suas solicitações.

### Edição e expiração

- **ANU-025:** Título, descrição, preço, quantidade, condição e endereço podem ser editados.
- **ANU-026:** Alterações relevantes notificam solicitantes e usuários que favoritaram o anúncio.
- **ANU-027:** Anúncio sem atualização por 30 dias deve ser desativado e seu dono notificado.
- **ANU-028:** Anúncio com solicitação, reserva, contestação ou negociação pendente não pode ser desativado automaticamente até a resolução.
- **ANU-029:** O anunciante pode confirmar disponibilidade e reativar anúncio desativado.

### Materiais proibidos

- **ANU-030:** São proibidos amianto e materiais que possam contê-lo.
- **ANU-031:** São proibidos materiais contaminados ou provenientes de ambientes radiológicos, industriais ou de saúde.
- **ANU-032:** São proibidos solventes, óleos, combustíveis, gases pressurizados e produtos inflamáveis.
- **ANU-033:** São proibidos produtos químicos abertos, vencidos, sem rótulo, vazando ou com embalagem danificada.
- **ANU-034:** São proibidos itens roubados, falsificados, recolhidos ou sem origem lícita.
- **ANU-035:** São proibidos itens com risco evidente de corte, choque, queda ou colapso.
- **ANU-036:** Tintas, argamassas e colas somente podem ser anunciadas lacradas, identificadas e dentro da validade.
- **ANU-037:** Materiais elétricos devem preservar marca e informações de certificação quando aplicáveis.
- **ANU-038:** Componentes estruturais usados exigem origem, estado e danos declarados, sem promessa de segurança pela plataforma.

## Estados do anúncio

Estados iniciais: rascunho, publicado, parcialmente disponível, reservado, pausado, concluído, cancelado e desativado.

As transições detalhadas devem ser validadas na SPEC de negociação e implementadas de modo explícito, sem dependência obrigatória de uma biblioteca de state machine.

## Critérios de aceitação

- [ ] Anúncio não é publicado sem todos os campos e uma foto válida.
- [ ] Venda exige preço; doação não aceita preço.
- [ ] Mudança de modalidade após publicação é rejeitada.
- [ ] Solicitações e reservas nunca ultrapassam o saldo.
- [ ] Redução manual nunca consome quantidade reservada.
- [ ] Edição relevante gera notificações previstas.
- [ ] Material proibido é rejeitado ou ocultado para análise.
- [ ] Anúncio inativo sem pendência é desativado após 30 dias.
- [ ] Anúncio com saldo parcial permanece encontrável.
- [ ] Fotos armazenadas não preservam coordenadas EXIF.
- [ ] Publicação registra a versão do termo aceita.

## Cenários de falha e borda

- A categoria ser desativada durante um rascunho exige nova escolha antes de publicar.
- Upload parcialmente válido não publica o anúncio com menos de uma foto aceita.
- Produto vence enquanto o anúncio está ativo e deve deixar de ser encontrável conforme job definido.
- Edição concorrente à reserva não pode gerar saldo negativo.
- Duplicar anúncio copia conteúdo permitido, mas não solicitações, reservas, avaliações ou histórico operacional.

## Dependências

- [SPEC-03 — Busca e localização](spec-03-busca-localizacao.md)
- [SPEC-04 — Solicitações e negociações](spec-04-solicitacoes-negociacoes.md)
- [SPEC-07 — Moderação, contestações e recursos](../confiabilidade/spec-07-moderacao-contestacoes.md)
- [ADR-0006 — Railway Buckets](../../adr/0006-railway-buckets-armazenamento.md)
- [SPEC-12 — Modelo de domínio e contratos](../arquitetura/spec-12-modelo-dominio-contratos-dados.md)
