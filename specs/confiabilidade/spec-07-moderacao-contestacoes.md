# SPEC-07 — Moderação, contestações e recursos

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-04, SPEC-05 e SPEC-06
**ADRs:** 0006, 0007

## Estado

Proposta.

## Objetivo

Definir bloqueio, denúncia, ocultação preventiva, mediação, sanções, recursos e preservação de evidências.

## Escopo

### Incluído

- Denúncia de anúncios, perfis, chats e avaliações.
- Bloqueio de contato.
- Evidências, fila administrativa e auditoria.
- Contestação de negociações e até três recursos.

### Excluído

- Arbitragem financeira, reembolso ou execução de pagamento.
- Monitoramento preventivo de todas as conversas.
- Decisão jurídica sobre propriedade ou responsabilidade civil.

## Taxonomia e prioridade

| Categoria | Prioridade inicial | Ação preventiva possível |
|---|---|---|
| Material perigoso ou proibido | Crítica | Ocultar anúncio imediatamente |
| Ameaça ou risco à integridade | Crítica | Restringir contato e preservar evidência |
| Fraude aparente | Alta | Ocultar conteúdo ou limitar ação conforme escopo |
| Pagamento/entrega contestados | Alta | Suspender conclusão e manter reserva |
| Assédio ou comportamento inadequado | Alta | Bloqueio imediato pelo usuário; análise do caso |
| Descrição, quantidade ou condição divergente | Normal/alta conforme risco | Suspender conclusão |
| Avaliação inadequada | Normal | Ocultar avaliação preventivamente quando aplicável |

## Ciclo de vida do caso

| Estado | Responsável pela próxima ação | Saídas permitidas |
|---|---|---|
| Aberto | Operação | triagem, prioridade, ocultação preventiva |
| Em análise | Agente atribuído | solicitar versão, decidir, escalar |
| Aguardando parte | Parte notificada | responder ou deixar prazo expirar |
| Decidido | Sistema/partes | cumprir medida, encerrar ou receber recurso |
| Em recurso | Outro agente autorizado quando possível | manter, alterar ou revogar decisão |
| Encerrado | Nenhum | somente consulta autorizada e retenção |

## Contrato da decisão

Toda decisão deve registrar:

- caso e objetos afetados;
- fatos considerados e limites da evidência;
- regra ou termo aplicado;
- resultado e medida proporcional;
- duração, quando temporária;
- agente decisor e data;
- possibilidade e prazo de recurso;
- efeitos sobre conteúdo, conta, negociação e reserva.

Decisão não pode obrigar pagamento, reembolso, transporte ou entrega externa.

## Requisitos funcionais

### Bloqueio

- **MOD-001:** Usuário pode bloquear imediatamente outro perfil para impedir mensagens e novas solicitações.
- **MOD-002:** Bloqueio pessoal não suspende a conta bloqueada para terceiros.
- **MOD-003:** Suspensão exige denúncia com motivo, circunstância e evidência, seguida de análise administrativa.

### Denúncias

- **MOD-004:** Podem ser denunciados anúncio, perfil, mensagem e avaliação.
- **MOD-005:** Formulário exige categoria e descrição e aceita evidências.
- **MOD-006:** Evidências aceitam JPEG, PNG ou PDF com até 20 MB por arquivo.
- **MOD-007:** Conteúdo denunciado deve ser ocultado preventivamente quando aplicável, mantendo registro para análise.
- **MOD-008:** Materiais perigosos, ameaça, fraude e risco à saúde recebem prioridade.
- **MOD-009:** Denúncias maliciosas ou repetidamente infundadas podem gerar medida administrativa.

### Acesso administrativo

- **MOD-010:** Administração só pode acessar a conversa relacionada a uma denúncia ou contestação.
- **MOD-011:** O acesso deve registrar administrador, motivo, data e escopo consultado.
- **MOD-012:** Conversas não denunciadas não ficam disponíveis para consulta livre.

### Contestação

- **MOD-013:** Motivos incluem pagamento não realizado ou divergente, material não entregue, material diferente, quantidade divergente, condição insegura, não comparecimento, comportamento inadequado e outro.
- **MOD-014:** A abertura exige descrição e pode incluir evidências.
- **MOD-015:** A outra parte tem sete dias para apresentar sua versão.
- **MOD-016:** Contestação suspende conclusão e mantém estoque reservado.
- **MOD-017:** A administração pode encerrar como concluída, cancelada, acordo, sem evidência suficiente ou violação confirmada.
- **MOD-018:** A mediação não obriga pagamento ou reembolso externo.

### Sanções

- **MOD-019:** Medidas possíveis incluem advertência, limitação de recursos, suspensão e banimento.
- **MOD-020:** Medida deve ser proporcional, motivada e auditável.
- **MOD-021:** Conta banida não pode usar o mesmo CPF, CNPJ ou e-mail para novo cadastro sem análise.
- **MOD-022:** Documentos anteriores e novos devem permanecer associados ao bloqueio quando houver tentativa de evasão comprovada.

### Recursos

- **MOD-023:** Parte afetada pode recorrer até três vezes.
- **MOD-024:** Cada recurso exige justificativa e pode adicionar evidências.
- **MOD-025:** Histórico completo de decisões e recursos deve ser preservado.
- **MOD-026:** Após o terceiro recurso, a decisão administrativa é final dentro da plataforma.

### Privacidade e histórico

- **MOD-027:** Evidências, motivos e histórico detalhado são privados.
- **MOD-028:** Somente efeitos agregados podem influenciar indicadores públicos.
- **MOD-029:** Conteúdo removido deve permanecer restaurável quando não houver obrigação de exclusão definitiva.

## Critérios de aceitação

- [ ] Bloqueio interrompe contato sem suspender automaticamente a outra conta.
- [ ] Denúncia cria registro auditável e oculta o conteúdo conforme a regra.
- [ ] Caso crítico recebe prioridade e ação preventiva apropriada.
- [ ] Administrador acessa somente conversa vinculada ao caso.
- [ ] Contestação impede conclusão automática e preserva reserva.
- [ ] Outra parte recebe prazo de sete dias.
- [ ] Até três recursos preservam o encadeamento de decisões.
- [ ] Decisão registra fundamento, efeitos e possibilidade de recurso.
- [ ] Conta banida não contorna bloqueio trocando documento livremente.
- [ ] Restaurar conteúdo não apaga a decisão anterior.

## Cenários de falha e borda

- Duas denúncias sobre o mesmo conteúdo podem ser relacionadas sem apagar autores ou evidências.
- Denúncia maliciosa não restaura automaticamente conteúdo que ainda viola outra regra.
- Prazo de resposta termina sem manifestação: o caso pode ser decidido com os elementos disponíveis e deve informar isso.
- Recurso é analisado sem permitir que o agente apague a decisão original.
- Evidência inválida ou insegura é recusada e o restante do caso permanece utilizável.

## Riscos

- Denúncia maliciosa causar ocultação indevida.
- Evidências conterem malware ou dados sensíveis de terceiros.
- Administração interpretar mediação como garantia financeira.
- Retenção excessiva de conversas e documentos.

## Dependências

- [SPEC-08 — Administração e atendimento](../capacidades/spec-08-administracao-atendimento.md)
- [SPEC-10 — Qualidade, segurança e privacidade](../qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-13 — Papéis e autorização](../arquitetura/spec-13-papeis-autorizacao.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](spec-15-observabilidade-auditoria-retencao.md)
