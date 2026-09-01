# SPEC-08 — Administração e atendimento

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-01 e SPEC-07
**ADRs:** 0007, 0008

## Estado

Proposta.

## Objetivo

Definir papéis administrativos, filas operacionais, atendimento interno, indicadores e trilha de auditoria.

## Escopo

### Incluído

- Administrador geral, moderador e atendimento.
- Gestão de catálogo, anúncios, contas, denúncias, avaliações e negociações.
- Formulário interno de suporte.
- Indicadores e restauração de conteúdo.

### Excluído

- Painel financeiro de pagamentos no MVP.
- Alteração irrestrita de dados pessoais por administradores.
- Ferramenta externa de atendimento.

## Papéis

- `platform_administrator`: acesso administrativo completo e gestão de papéis.
- `moderator`: anúncios, denúncias, avaliações e medidas temporárias sobre contas.
- `support_agent`: chamados, negociações, contestações e recursos, sem banimento definitivo.

## Matriz das filas

| Fila | Origem | Prioridade | Papel inicial | Prazo |
|---|---|---|---|---|
| Denúncias | Formulário contextual | Pela taxonomia da SPEC-07 | Moderador | A definir por prioridade |
| Contestações | Negociação | Alta quando suspende conclusão | Atendimento/moderador | Resposta da parte em 7 dias |
| Recursos | Decisão administrativa | Conforme medida vigente | Agente autorizado distinto quando possível | A definir |
| Documentos | Solicitação de alteração | Segurança | Administrador autorizado | A definir |
| Chamados | Formulário interno | Categoria e impacto | Atendimento | A definir |

## Ciclo do chamado

```text
aberto → em análise → aguardando usuário → em análise → resolvido → encerrado
```

Reabertura após `resolvido` pode ocorrer dentro de janela a definir. `encerrado` preserva histórico e exige novo chamado para tema novo.

## Contrato de atribuição

- Um item possui no máximo um responsável atual, sem impedir colaboração auditada.
- Transferência registra responsável anterior, novo responsável, ator e motivo.
- Fila pode conter item sem responsável, mas não pode ocultá-lo dos papéis encarregados.
- Acesso ao item não concede acesso irrestrito a todos os recursos relacionados.
- Prazos pausados por espera do usuário devem ser distinguíveis de atraso operacional.

## Requisitos funcionais

### Autorização e auditoria

- **ADM-001:** Toda ação administrativa exige papel autorizado no servidor.
- **ADM-002:** Toda ação registra agente, data, motivo, objeto e valores anteriores quando aplicável.
- **ADM-003:** Administradores não alteram diretamente dados pessoais; solicitam correção ao usuário.
- **ADM-004:** Exceções de correção documental seguem fluxo específico e auditado da SPEC-01.
- **ADM-005:** Exclusões devem ser reversíveis sempre que possível.
- **ADM-006:** Anúncios, avaliações e contas podem ser restaurados por papel autorizado.

### Filas

- **ADM-007:** Área administrativa possui filas de denúncias, contestações, recursos, documentos e chamados.
- **ADM-008:** Risco à saúde, ameaça, fraude e material proibido recebem prioridade.
- **ADM-009:** Itens exibem situação, responsável atual, prazo e histórico.
- **ADM-010:** Atribuição e transferência entre agentes devem ser auditadas.

### Catálogo e conteúdo

- **ADM-011:** Papel autorizado gerencia categorias, atributos e unidades.
- **ADM-012:** Papel autorizado oculta, restaura ou remove anúncio conforme decisão registrada.
- **ADM-013:** Papel autorizado oculta ou restaura avaliação.
- **ADM-014:** Medidas sobre contas respeitam limites de cada papel.

### Atendimento

- **ADM-015:** Usuário abre chamado por formulário interno.
- **ADM-016:** Chamado contém categoria, descrição, anexos, situação e conversa.
- **ADM-017:** Situações iniciais são aberto, em análise, aguardando usuário, resolvido e encerrado.
- **ADM-018:** Usuário e atendimento recebem notificações sobre novas interações.
- **ADM-019:** Chamado pode ser vinculado a anúncio, negociação, denúncia ou conta.
- **ADM-020:** Atendimento não pode visualizar recursos não vinculados sem permissão adicional.

### Indicadores

- **ADM-021:** Painel mostra usuários, organizações, anúncios ativos, doações, vendas, conclusões e cancelamentos.
- **ADM-022:** Painel mostra denúncias e contestações pendentes e tempo médio de resolução.
- **ADM-023:** Painel agrega quantidades nas unidades originais, sem conversão ambiental não validada.
- **ADM-024:** Indicadores podem ser filtrados por período, categoria, local e modalidade quando houver dados suficientes.
- **ADM-025:** Coleta de indicadores não estabelece metas obrigatórias para o lançamento.

### Administrador inicial

- **ADM-026:** O primeiro administrador deve ser criado por seed idempotente.
- **ADM-027:** O e-mail vem de variável de ambiente e não existe senha padrão no código.
- **ADM-028:** O administrador define senha por link seguro enviado ao e-mail.
- **ADM-029:** Nova execução do seed não substitui conta nem credenciais existentes.

## Critérios de aceitação

- [ ] Cada papel acessa somente ações permitidas.
- [ ] Toda mutação administrativa deixa trilha verificável.
- [ ] Atendimento não consegue banir definitivamente uma conta.
- [ ] Usuário acompanha chamado dentro da plataforma.
- [ ] Transferência de fila preserva autoria e histórico.
- [ ] Conteúdo removido pode ser restaurado quando permitido.
- [ ] Prazos distinguem espera do usuário e espera da operação.
- [ ] Seed não contém credencial e pode ser executado repetidamente sem duplicar administrador.
- [ ] Administrador inicial precisa confirmar e definir sua própria senha.

## Cenários operacionais

- Agente perde o papel durante análise: acesso futuro é revogado e o item retorna ou é transferido à fila.
- Chamado referencia negociação que o atendente não pode abrir: apresentar somente resumo permitido ou exigir escalonamento.
- Dois agentes tentam assumir o mesmo item: apenas uma atribuição atual prevalece, mantendo evento da tentativa rejeitada quando relevante.
- Conteúdo é restaurado após recurso: projeções públicas e indicadores são recompostos sem apagar histórico.

## Dependências

- [SPEC-07 — Moderação, contestações e recursos](../confiabilidade/spec-07-moderacao-contestacoes.md)
- [SPEC-11 — Deploy e operação](../infraestrutura/spec-11-deploy-operacao.md)
- [SPEC-13 — Papéis e autorização](../arquitetura/spec-13-papeis-autorizacao.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](../confiabilidade/spec-15-observabilidade-auditoria-retencao.md)
