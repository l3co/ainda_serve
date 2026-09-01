# SPEC-06 — Reputação e avaliações

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-04
**ADRs:** —

## Estado

Proposta.

## Objetivo

Definir avaliações bilaterais e reputação pública sem incentivar retaliação ou punir indevidamente todas as unidades de uma organização.

## Escopo

### Incluído

- Avaliações de 1 a 5 estrelas e comentário.
- Revelação bilateral, edição limitada e prazo de 14 dias.
- Reputação por papel, organização e unidade.
- Métricas internas por membro.

### Excluído

- Resposta pública ao comentário.
- Compra de reputação ou destaque baseado em pagamento.
- Exposição pública dos detalhes de contestações.

## Contrato da avaliação

| Campo | Regra |
|---|---|
| Papel do autor | Anunciante ou interessado naquela negociação |
| Papel avaliado | O papel oposto na mesma negociação |
| Critérios | Comunicação, pontualidade, fidelidade da descrição, cumprimento do acordo e geral |
| Nota | Inteiro de 1 a 5 por critério |
| Comentário | Texto obrigatório dentro de limites a definir |
| Visibilidade | Oculta até condição bilateral ou prazo de 14 dias |
| Edição | Permitida apenas enquanto oculta |
| Moderação | Pode ocultar sem apagar histórico |

## Elegibilidade e revelação

```text
negociação elegível → janela de 14 dias
├── ambas avaliam → revelar ambas imediatamente
├── apenas uma avalia → revelar ao final da janela
└── ninguém avalia → encerrar janela sem avaliação
```

Venda contestada só entra na janela após decisão final elegível. A regra de início da janela de doação permanece condicionada à questão aberta da SPEC-04.

## Cálculo e apresentação

- Média usa somente avaliações públicas e não ocultadas por moderação.
- Toda média exibe quantidade de avaliações e nunca mostra `0 estrelas` como se fosse reputação ruim quando não há amostra.
- Média geral da organização agrega unidades, preservando detalhamento por unidade.
- Visões de anunciante e interessado permanecem separadas e também compõem uma visão geral.
- Remoção ou restauração administrativa recalcula projeções sem apagar a avaliação histórica.
- Método de arredondamento e quantidade mínima para destaque serão definidos na implementação da SPEC, antes do código.

## Requisitos funcionais

### Elegibilidade

- **REP-001:** Avaliação só é liberada após confirmação exigida das partes.
- **REP-002:** Doação exige confirmação do anunciante e do destinatário para liberar avaliação.
- **REP-003:** Venda contestada só libera avaliação depois do encerramento administrativo.
- **REP-004:** Negociação cancelada sem conclusão não gera avaliação pública, mas alimenta métricas internas.

### Conteúdo

- **REP-005:** Cada avaliação contém notas de 1 a 5 para comunicação, pontualidade, fidelidade da descrição, cumprimento do acordo e nota geral.
- **REP-006:** Comentário textual acompanha a avaliação.
- **REP-007:** A parte avaliada não pode publicar resposta pública ao comentário.
- **REP-008:** Avaliações podem ser denunciadas.

### Revelação e edição

- **REP-009:** A avaliação permanece oculta até a outra parte avaliar ou o prazo terminar.
- **REP-010:** O prazo de avaliação é de 14 dias após a elegibilidade.
- **REP-011:** Avaliação pode ser editada enquanto estiver oculta.
- **REP-012:** Após revelação ou fim do prazo, a avaliação fica bloqueada.
- **REP-013:** Administração pode ocultar avaliação por violação, preservando histórico.

### Reputação de pessoas

- **REP-014:** Perfil mostra média geral e quantidade de avaliações.
- **REP-015:** Notas devem ser separadas pelos papéis de anunciante e interessado, além da média geral.
- **REP-016:** Histórico público mostra indicadores agregados, não motivos ou evidências privadas.

### Reputação de organizações

- **REP-017:** Perfil mostra média geral da organização e número de avaliações.
- **REP-018:** Detalhes mostram reputação por unidade/endereço.
- **REP-019:** Avaliação afeta a unidade responsável e compõe a média geral da organização.
- **REP-020:** Toda média exibe a quantidade de avaliações correspondente.
- **REP-021:** Métricas de membros ficam disponíveis apenas para administradores autorizados da organização e da plataforma.

### Indicadores de conclusão

- **REP-022:** Perfil pode exibir negociações concluídas e taxa agregada de conclusão.
- **REP-023:** Cancelamentos, ausências e contestações detalhadas permanecem privados.
- **REP-024:** Indicadores públicos não devem insinuar fraude ou culpa sem decisão administrativa.

## Critérios de aceitação

- [ ] Uma parte não vê a avaliação recebida antes de avaliar ou do fim do prazo.
- [ ] Avaliação revelada não pode ser editada pelo autor.
- [ ] Uma mesma parte não avalia duas vezes o mesmo papel na negociação.
- [ ] Organização exibe média geral e detalhamento por unidade.
- [ ] Usuário público não acessa métricas internas de membro.
- [ ] Quantidade de avaliações sempre acompanha médias.
- [ ] Perfil sem avaliações não apresenta média enganosa.
- [ ] Avaliação denunciada pode ser ocultada sem apagar o histórico.
- [ ] Restauração administrativa recompõe a média de forma determinística.

## Cenários de falha e borda

- Uma parte tenta editar depois da revelação: rejeitar sem alterar a versão pública.
- Job de revelação e segunda avaliação chegam juntos: revelar uma única vez.
- Avaliação é denunciada durante a janela oculta: permanece privada até análise e condição de revelação.
- Unidade é desativada: sua reputação histórica continua visível no detalhamento apropriado.
- Conta é excluída: a política de anonimização deve preservar integridade da reputação sem expor identidade proibida.

## Dependências

- [SPEC-04 — Solicitações e negociações](spec-04-solicitacoes-negociacoes.md)
- [SPEC-07 — Moderação, contestações e recursos](../confiabilidade/spec-07-moderacao-contestacoes.md)
- [SPEC-12 — Modelo de domínio e contratos](../arquitetura/spec-12-modelo-dominio-contratos-dados.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](../confiabilidade/spec-15-observabilidade-auditoria-retencao.md)
