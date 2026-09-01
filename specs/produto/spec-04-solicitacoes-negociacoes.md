# SPEC-04 — Solicitações e negociações

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-02 e SPEC-03
**ADRs:** 0001, 0003

## Estado

Proposta.

## Objetivo

Definir solicitação, seleção, reserva, entrega, venda, cancelamento e conclusão sem processar pagamento ou logística.

## Escopo

### Incluído

- Solicitações parciais ou totais.
- Lista de espera e escolha do anunciante.
- Reserva de estoque.
- Fluxos distintos de doação e venda.
- Cancelamento, inatividade e contestação.

### Excluído

- Pagamento, reembolso, comissão ou custódia de valores.
- Contratação ou rastreamento de transporte.
- Garantia de qualidade, entrega ou recebimento.

## Responsabilidade da plataforma

As telas de solicitação, seleção e confirmação devem informar claramente que o Ainda Serve facilita descoberta, comunicação e registro. Pagamento, inspeção, retirada e entrega são combinados diretamente pelas partes.

## Atores e pré-condições

| Ação | Ator | Pré-condição |
|---|---|---|
| Solicitar | Conta confirmada diferente do anunciante | Anúncio encontrável, sem bloqueio e com saldo |
| Desistir antes da seleção | Interessado | Solicitação pendente ou em espera |
| Selecionar | Anunciante ou membro autorizado | Solicitação ativa e saldo suficiente |
| Cancelar seleção | Parte autorizada | Negociação não concluída; motivo informado |
| Confirmar doação | Anunciante | Reserva ativa e entrega combinada |
| Confirmar venda | Qualquer parte | Reserva ativa e sem decisão impeditiva |
| Contestar | Qualquer parte | Negociação ativa dentro do fluxo permitido |

## Fluxo de estoque

```text
solicitação: available não muda
seleção:     available → reserved
cancelamento: reserved → available
conclusão:   reserved → completed
```

Cada seta representa uma alteração atômica e idempotente. Notificação ou e-mail falhando não desfaz a alteração persistida.

## Transições da solicitação

| De | Ação | Para | Efeito |
|---|---|---|---|
| Pendente | anunciante seleciona | Selecionada | cria reserva e negociação |
| Pendente | interessado desiste | Retirada | sai da lista |
| Pendente | saldo comprometido | Em espera | mantém elegibilidade futura |
| Em espera | saldo retorna | Pendente | volta à seleção possível |
| Pendente/espera | anunciante rejeita ou anúncio encerra | Rejeitada/encerrada | notifica interessado |
| Selecionada | seleção cancelada | Encerrada | devolve reserva; nova solicitação exigirá fluxo aprovado |

## Transições da negociação

| De | Evento | Para | Estoque |
|---|---|---|---|
| Reservada | combinação registrada | Aguardando entrega | permanece reservado |
| Aguardando entrega | primeira confirmação | Aguardando confirmação | permanece reservado |
| Ativa | contestação | Contestada | permanece reservado |
| Ativa | cancelamento válido | Cancelada | volta ao disponível |
| Doação ativa | anunciante confirma entrega | Concluída para estoque | vai para concluído |
| Venda aguardando confirmação | segunda confirmação | Concluída | vai para concluído |
| Venda aguardando confirmação | 3 dias sem contestação | Concluída automaticamente | vai para concluído |
| Contestada | decisão administrativa | Concluída ou cancelada | conclui ou devolve conforme decisão |

## Concorrência e idempotência

- A leitura do saldo fora da transação é apenas informativa; a seleção revalida o saldo.
- Confirmação repetida pela mesma parte não altera estoque novamente.
- Job de conclusão automática perde para contestação persistida antes do commit.
- Cancelamento simultâneo à seleção aceita uma única ordem válida e devolve erro compreensível à outra ação.
- Toda transição registra ator, instante e estado anterior.

## Requisitos funcionais

### Solicitação

- **NEG-001:** Somente conta confirmada pode solicitar material.
- **NEG-002:** A solicitação exige quantidade e mensagem ao anunciante.
- **NEG-003:** A solicitação pode incluir proposta de retirada ou entrega.
- **NEG-004:** Em doações, a finalidade do material é opcional.
- **NEG-005:** A quantidade solicitada nunca pode exceder o saldo disponível.
- **NEG-006:** Deve existir ação **Selecionar tudo** para solicitar o saldo disponível.
- **NEG-007:** O anunciante não pode impor uma contraproposta de quantidade dentro da solicitação.
- **NEG-008:** Para mudar a quantidade possível, o anunciante atualiza rapidamente o anúncio e o interessado ajusta a solicitação.
- **NEG-009:** Interessado pode desistir antes da seleção, com motivo opcional.

### Lista de interessados

- **NEG-010:** O anunciante visualiza perfil, distância, histórico e reputação de cada interessado.
- **NEG-011:** A lista pode ser ordenada por chegada, mas o anunciante escolhe livremente.
- **NEG-012:** Não selecionados permanecem em lista de espera enquanto houver possibilidade de saldo.
- **NEG-013:** Cancelamento de uma seleção devolve quantidade e permite escolher outro interessado.
- **NEG-014:** Interessados não escolhidos devem ser notificados quando não houver mais disponibilidade.

### Seleção e reserva

- **NEG-015:** Anunciante pode selecionar vários interessados se houver saldo para todos.
- **NEG-016:** Seleção move quantidade de disponível para reservada de forma atômica.
- **NEG-017:** Uma mesma quantidade não pode ser reservada duas vezes.
- **NEG-018:** O endereço exato fica disponível somente ao destinatário selecionado.
- **NEG-019:** Cancelamento revoga o endereço e devolve a reserva.

### Retirada e entrega

- **NEG-020:** Partes combinam transporte, data e forma de entrega.
- **NEG-021:** Anunciante pode publicar instruções e horários de retirada.
- **NEG-022:** Destinatário selecionado pode abrir a rota externamente no Google Maps.

### Doação

- **NEG-023:** Confirmação de entrega pelo anunciante conclui a movimentação do estoque de uma doação.
- **NEG-024:** O destinatário ainda precisa confirmar recebimento para liberar avaliações bilaterais.
- **NEG-025:** Falta de confirmação do destinatário não deve devolver automaticamente um material já confirmado como entregue pelo anunciante.

### Venda

- **NEG-026:** Pagamento é combinado e realizado fora da plataforma.
- **NEG-027:** Venda exige confirmação do anunciante e do comprador.
- **NEG-028:** Após a primeira confirmação, começa prazo de três dias para a outra parte confirmar ou contestar.
- **NEG-029:** Sem contestação durante o prazo, a venda pode ser concluída automaticamente.
- **NEG-030:** Contestação de pagamento, quantidade, entrega ou recebimento suspende a conclusão.
- **NEG-031:** A administração pode mediar e registrar, mas não movimenta dinheiro nem determina reembolso externo.

### Cancelamento e inatividade

- **NEG-032:** Interessado selecionado pode desistir, informando motivo.
- **NEG-033:** Anunciante pode cancelar seleção, informando motivo.
- **NEG-034:** Motivos ficam visíveis às partes e à administração.
- **NEG-035:** Cancelamentos alimentam indicador interno de risco e taxa pública agregada de conclusão.
- **NEG-036:** Negociação sem atividade por 30 dias pode ser desativada após notificação.
- **NEG-037:** Atividade inclui mensagem, alteração, confirmação, contestação ou ação administrativa.
- **NEG-038:** Contestação aberta mantém a quantidade reservada até decisão.

## Estados conceituais

Solicitação: pendente, selecionada, em espera, retirada, rejeitada e encerrada.

Negociação: reservada, aguardando entrega, aguardando confirmação, contestada, concluída, cancelada e desativada.

Os estados devem possuir transições explícitas e rejeitar transições ilegais.

## Critérios de aceitação

- [ ] Não é possível solicitar acima do saldo.
- [ ] Seleções concorrentes não geram reserva duplicada.
- [ ] Cancelamento devolve saldo e revoga o endereço na mesma operação lógica.
- [ ] Doação confirmada pelo anunciante reduz estoque definitivamente uma única vez.
- [ ] Venda só conclui bilateralmente ou após três dias sem contestação desde a primeira confirmação.
- [ ] Contestação persistida antes do job suspende conclusão e preserva reserva.
- [ ] Toda tela de venda informa que o pagamento ocorre fora da plataforma.
- [ ] Inatividade é calculada pela última atividade registrada.
- [ ] Falha de notificação não reverte reserva ou conclusão.
- [ ] Toda transição ilegal é rejeitada e observável.

## Cenários de falha e borda

- Saldo diminui entre abertura e envio da solicitação: informar novo máximo sem criar solicitação inválida.
- Dois anunciantes organizacionais tentam selecionar interessados concorrentes: apenas reservas dentro do saldo vencem.
- Primeira confirmação e contestação chegam quase juntas: a ordem persistida decide e nunca conclui com contestação aberta.
- Negociação inativa com contestação não é desativada automaticamente.
- Anunciante cancela após compartilhar endereço: acesso é revogado e o evento fica auditável.

## Questão em aberto

- **Não bloqueante para documentação, bloqueante para implementação da avaliação de doações:** definir se a confirmação do destinatário de uma doação expira automaticamente ou permanece pendente sem prazo.

## Dependências

- [SPEC-02 — Anúncios e catálogo](spec-02-anuncios-catalogo-materiais.md)
- [SPEC-05 — Chat e notificações](../capacidades/spec-05-chat-notificacoes.md)
- [SPEC-07 — Moderação, contestações e recursos](../confiabilidade/spec-07-moderacao-contestacoes.md)
- [SPEC-12 — Modelo de domínio e contratos](../arquitetura/spec-12-modelo-dominio-contratos-dados.md)
- [SPEC-13 — Papéis e autorização](../arquitetura/spec-13-papeis-autorizacao.md)
