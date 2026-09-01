# ADR-0009 — Resend para e-mail transacional

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

O produto precisa enviar confirmação, recuperação, segurança, negociações e resumos. Um servidor próprio de e-mail adicionaria reputação, entrega e operação desnecessárias.

## Decisão

Usar Resend como primeiro provedor de e-mail transacional. O envio ocorrerá por jobs e respeitará preferências, exceto notificações obrigatórias de segurança.

## Consequências

### Positivas

- Integração focada e adequada ao início do produto.
- Faixa gratuita pode atender o primeiro volume.
- Separação entre geração de e-mail e entrega externa.

### Negativas

- Limites gratuitos podem ser atingidos por pesquisas salvas e eventos.
- Dependência de domínio autenticado e reputação do provedor.
- Falhas precisam de retry e monitoramento sem duplicação indevida.

## Alternativas consideradas

- Postmark e SendGrid: não escolhidos inicialmente.
- SMTP próprio: rejeitado pela carga operacional.
- E-mail para cada mensagem de chat: rejeitado por sobrecarga da caixa de entrada.

## Gatilhos para revisão

- Limites ou custo incompatíveis com o volume.
- Entregabilidade insuficiente.
- Necessidade de região, contrato ou recurso não suportado.

## Referências externas

- [Plano gratuito do Resend](https://resend.com/blog/new-free-tier)

## Referências internas

- [SPEC-05 — Chat e notificações](../specs/capacidades/spec-05-chat-notificacoes.md)
