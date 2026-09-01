# SPEC-05 — Chat e notificações

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-04
**ADRs:** 0007, 0009

## Estado

Proposta.

## Objetivo

Definir conversa textual, eventos automáticos e canais de notificação sem sobrecarregar e-mail ou expor contato.

## Escopo

### Incluído

- Uma conversa por solicitação.
- Texto e eventos de sistema.
- Central em tempo real, e-mail configurável e Web Push opcional.
- Preferências pessoais e organizacionais.

### Excluído

- Imagens, documentos, áudio, vídeo e chamadas no chat.
- Leitura indiscriminada de conversas pela administração.
- Integração oficial com WhatsApp no MVP.

## Contrato da conversa

| Elemento | Regra |
|---|---|
| Escopo | Exatamente uma solicitação |
| Participantes | Conta interessada e conta anunciante; membros organizacionais conforme atribuição |
| Conteúdo do usuário | Texto simples dentro de limites a aprovar |
| Eventos do sistema | Imutáveis e derivados de transições persistidas |
| Ocultação | Apenas visual, durante janela aprovada; conteúdo preservado |
| Anexos | Proibidos no MVP |
| Contato externo | Compartilhado voluntariamente no texto após seleção |

## Matriz de eventos e canais

| Evento | Plataforma | E-mail | Web Push | Configurável |
|---|---:|---:|---:|---:|
| Confirmação e recuperação de segurança | Sim | Sim | Opcional complementar | Não |
| Nova solicitação | Sim | Conforme preferência | Conforme consentimento | Sim, exceto sinal crítico |
| Nova mensagem | Sim, imediata | Não por padrão | Conforme consentimento | Sim |
| Seleção ou cancelamento | Sim | Conforme preferência | Conforme consentimento | Sim |
| Confirmação e conclusão | Sim | Conforme preferência | Conforme consentimento | Sim |
| Contestação ou medida administrativa | Sim | Sim | Conforme consentimento | Parcialmente; segurança permanece |
| Mudança em favorito | Sim, agrupada | Agrupada conforme preferência | Conforme consentimento | Sim |
| Pesquisa salva | Sim | Imediata ou resumo diário | Conforme consentimento | Sim |

## Ordem e idempotência

- Evento funcional é persistido antes de gerar notificações.
- Reprocessar um job não cria a mesma notificação lógica duas vezes para o mesmo destinatário e canal.
- Uma notificação pode chegar depois da atualização da tela; o link sempre consulta o estado atual.
- E-mail ou push atrasado deve deixar claro o instante do evento e não prometer estado ainda vigente.
- Alteração de preferência vale para entregas futuras e não remove notificações de segurança já geradas.

## Estados da mensagem

| Estado | Visível normalmente | Auditável | Editável |
|---|---:|---:|---:|
| Enviada | Sim | Sim | Não |
| Ocultada pelo remetente | Não para participantes comuns | Sim | Não |
| Ocultada por moderação | Não | Sim | Não |
| Preservada em caso | Conforme decisão do caso | Sim | Não |

## Requisitos funcionais

### Chat

- **COM-001:** Cada solicitação cria uma conversa exclusiva entre interessado e anunciante.
- **COM-002:** Somente participantes autorizados e membros organizacionais permitidos acessam a conversa.
- **COM-003:** O chat aceita apenas texto.
- **COM-004:** Imagens e documentos não podem ser anexados ao chat.
- **COM-005:** Telefone e e-mail permanecem ocultos até a seleção do interessado.
- **COM-006:** Após seleção, cada parte decide se compartilha contato no texto; a plataforma não o publica automaticamente.
- **COM-007:** As partes podem continuar no WhatsApp por decisão própria e por sua conta e risco.
- **COM-008:** Conteúdo deve ser tratado como entrada não confiável e renderizado sem executar HTML ou scripts.

### Eventos automáticos

- **COM-009:** A conversa registra solicitação criada, interessado selecionado, quantidade reservada, anúncio alterado, entrega confirmada, contestação aberta e negociação concluída.
- **COM-010:** Eventos do sistema não podem ser editados ou ocultados por usuários.
- **COM-011:** Eventos devem indicar data, hora e ator quando aplicável.

### Ocultação de mensagens

- **COM-012:** Remetente pode ocultar visualmente mensagem própria durante uma janela curta.
- **COM-013:** Mensagem ocultada permanece preservada para denúncias e auditoria.
- **COM-014:** A interface informa que a mensagem poderá ser preservada por razões de segurança.

### Central de notificações

- **COM-015:** A plataforma possui central com contador de não lidas e atualização em tempo real com Hotwire.
- **COM-016:** Usuário pode marcar todas como lidas, ocultar notificações visuais e configurar categorias.
- **COM-017:** Nova mensagem de chat notifica imediatamente apenas dentro da plataforma e por Web Push quando autorizado.
- **COM-018:** Nova mensagem não envia e-mail por padrão.

### E-mail e Web Push

- **COM-019:** E-mails podem informar solicitações, seleção, cancelamento, confirmação, contestação, favoritos e pesquisas salvas conforme preferência.
- **COM-020:** Mudanças de favoritos devem ser agrupadas para reduzir volume.
- **COM-021:** Pesquisa salva permite aviso imediato ou resumo diário.
- **COM-022:** Web Push é opcional e requer consentimento do dispositivo.
- **COM-023:** Negar Web Push não impede nenhum fluxo da plataforma.

### Segurança

- **COM-024:** Confirmação de e-mail, recuperação de senha, troca de e-mail, alteração de documento, acesso suspeito, dois fatores e medidas administrativas são notificações obrigatórias.
- **COM-025:** Notificações obrigatórias não podem ser desativadas.
- **COM-026:** Conteúdo de e-mail não deve expor dados sensíveis além do necessário.

### Organizações

- **COM-027:** Cada organização configura destinatários por categoria.
- **COM-028:** O membro atribuído recebe avisos do anúncio por padrão.
- **COM-029:** Administradores podem acompanhar ou receber cópias conforme configuração.
- **COM-030:** Preferências da organização não podem desativar alertas obrigatórios de segurança.

## Critérios de aceitação

- [ ] Conversas de solicitações distintas não se misturam.
- [ ] Usuário sem vínculo não acessa conversa conhecida por identificador.
- [ ] Mensagem aparece em tempo real sem e-mail automático por padrão.
- [ ] Mensagem ocultada deixa de aparecer normalmente, mas permanece auditável.
- [ ] Preferências controlam canais não obrigatórios.
- [ ] Eventos de sistema refletem somente transições persistidas.
- [ ] Web Push só é enviado após consentimento.
- [ ] Reprocessar um job não duplica notificação lógica.
- [ ] Falha de e-mail ou push não desfaz a ação de negócio.
- [ ] Membro organizacional removido perde acesso à conversa.

## Questões em aberto

- Definir a duração exata da janela de ocultação de mensagens.
- Definir limites de tamanho, frequência e retenção do texto do chat.
- Definir se haverá indicador de leitura e, se houver, sua regra de privacidade.

## Dependências

- [ADR-0007 — Solid Queue](../../adr/0007-solid-queue-processamento-assincrono.md)
- [ADR-0009 — Resend](../../adr/0009-resend-email-transacional.md)
- [SPEC-10 — Qualidade, segurança e privacidade](../qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-13 — Papéis e autorização](../arquitetura/spec-13-papeis-autorizacao.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](../confiabilidade/spec-15-observabilidade-auditoria-retencao.md)
