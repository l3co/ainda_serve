# ADR-0007 — Solid Queue para processamento assíncrono

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

E-mails, push, expirações, resumos e exportações não devem bloquear requests. Adicionar Redis e Sidekiq aumentaria componentes antes de haver volume comprovado.

## Decisão

Começar com Solid Queue, executado por processo worker separado no Railway. Jobs devem ser idempotentes, retry-safe e observáveis.

A compatibilidade e configuração exatas serão confirmadas após escolher as versões de Ruby e Rails.

## Consequências

### Positivas

- Menos infraestrutura e nenhuma dependência inicial de Redis.
- Integração com Active Job.
- Mesmo banco e ferramentas operacionais do projeto.

### Negativas

- Carga de fila compartilha recursos PostgreSQL.
- Throughput pode ser inferior a soluções dedicadas em grande escala.
- Worker separado continua necessário.

## Alternativas consideradas

- Sidekiq com Redis: adiado até volume, prioridade ou latência justificarem.
- Jobs no processo web: rejeitados por confiabilidade e escalabilidade.
- Cron para todos os trabalhos: rejeitado por não atender eventos imediatos.

## Gatilhos para revisão

- Fila impactar o banco principal.
- Necessidade comprovada de throughput ou prioridade além da solução.
- Latência de jobs incompatível com notificações esperadas.

## Referências

- [SPEC-05 — Chat e notificações](../specs/capacidades/spec-05-chat-notificacoes.md)
- [SPEC-11 — Deploy e operação](../specs/infraestrutura/spec-11-deploy-operacao.md)
