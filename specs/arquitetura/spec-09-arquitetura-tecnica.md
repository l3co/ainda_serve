# SPEC-09 — Arquitetura técnica

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** PRD e SPEC-01 a SPEC-08
**ADRs:** 0001 a 0010

## Estado

Proposta.

## Objetivo

Definir limites técnicos do monólito Rails, princípios de modelagem, front-end Hotwire, persistência e integrações externas.

## Direção arquitetural

O Ainda Serve será um monólito modular pragmático, implantado como uma aplicação Rails única com processos web e worker. Não haverá microserviços, CQRS, event sourcing ou camadas genéricas sem uma necessidade demonstrada.

## Visão de execução

```text
Browser/PWA
    │ HTML + Turbo + Stimulus
    ▼
Rails web ─────────────── PostgreSQL
    │                         ▲
    ├── after-commit/job ─────┤ Solid Queue
    │                         │
    ▼                         ▼
Resend   Geoapify   Railway Buckets   Web Push

MapLibre/OpenFreeMap são consumidos na experiência de mapa conforme contrato aprovado.
```

O processo web aceita ações e persiste o estado. O worker executa efeitos assíncronos retry-safe. Ambos usam a mesma base de código e contratos de domínio.

## Princípios de design

- Aplicar SOLID de forma pragmática, sem criar interfaces para uma única implementação por antecipação.
- Seguir *99 Bottles of OOP*: shameless green, concreto antes do abstrato, flocking rules, Rule of Three e composição antes de herança.
- Manter comportamento no modelo que possui o estado alterado.
- Criar objeto Ruby quando a lógica for cálculo puro ou não pertencer a um único registro.
- Evitar `app/services` como depósito de classes que apenas delegam.
- Modelar poucos estados com enumerações e métodos de transição explícitos antes de considerar biblioteca de state machine.
- Usar eventos após commit somente quando uma mudança real precisar disparar efeitos independentes.

## Componentes conceituais

### Identidade

- `User`, `Account`, `Membership` e `OrganizationUnit` conforme SPEC-01.

### Mercado

- Catálogo, anúncio, fotografia, estoque, solicitação, reserva e negociação.

### Comunicação

- Conversa, mensagem, evento de sistema, notificação e preferência.

### Confiança

- Avaliação, reputação, denúncia, contestação, recurso, bloqueio e auditoria.

### Operação

- Atendimento, papéis administrativos, indicadores e exportações.

Esses agrupamentos orientam responsabilidades; não exigem namespaces ou módulos enquanto não houver várias classes realmente relacionadas que justifiquem cada limite.

## Fluxo interno de uma mutação

```text
request → autenticação → autorização → validação → comportamento do domínio
→ transação PostgreSQL → resposta persistida → efeito assíncrono após commit
```

- Controllers traduzem HTTP e não concentram regras de negócio.
- Models mantêm comportamento relacionado ao próprio estado e invariantes.
- Objetos Ruby puros representam cálculos ou coordenação que não pertença naturalmente a um registro.
- Jobs recebem identificadores, recarregam estado vigente e toleram retry.
- Clientes externos traduzem contrato do fornecedor para resultados próprios e erros observáveis.

## Estrutura inicial proposta

Esta estrutura é orientação para a fase de fundação e deverá ser confirmada antes da geração da aplicação:

```text
app/
├── controllers/       # HTTP, autenticação e autorização de entrada
├── models/            # estado e comportamento do domínio
├── jobs/              # efeitos assíncronos idempotentes
├── mailers/           # e-mails transacionais
├── policies/          # somente se a implementação aprovada usar objetos focados
├── queries/           # consultas complexas após necessidade demonstrada
├── clients/           # integrações externas pequenas e focadas
├── javascript/        # Stimulus e integração de mapa/PWA
└── views/             # HTML, Turbo Frames e Turbo Streams
```

Pastas `policies`, `queries` e `clients` só serão criadas quando a primeira classe aprovada justificar sua existência. Não haverá `app/services` genérico por padrão.

## Requisitos técnicos

- **ARQ-001:** Usar versões estáveis de Ruby e Rails com suporte adequado no início da implementação, evitando versões obsoletas.
- **ARQ-002:** Registrar versões escolhidas em ADR antes de gerar a aplicação.
- **ARQ-003:** Usar Rails com renderização no servidor, Turbo e Stimulus.
- **ARQ-004:** Usar Tailwind CSS para apresentação.
- **ARQ-005:** Não adicionar React, Vue ou SPA paralela sem novo ADR.
- **ARQ-006:** Usar PostgreSQL como fonte de verdade.
- **ARQ-007:** Começar busca textual e geográfica no PostgreSQL.
- **ARQ-008:** Usar Active Storage com Railway Buckets.
- **ARQ-009:** Usar Solid Queue para trabalhos assíncronos iniciais.
- **ARQ-010:** Usar Resend para e-mails transacionais.
- **ARQ-011:** Usar MapLibre GL JS, OpenFreeMap e Geoapify conforme ADR-0004.
- **ARQ-012:** Usar RSpec nos níveis definidos pela SPEC-10.
- **ARQ-013:** Construir PWA responsiva com progressive enhancement.

## Integrações externas

Cada integração deve possuir um cliente pequeno e focado, responsável por autenticação, timeouts, respostas e erros do fornecedor. Não será criada uma hierarquia genérica de provedores até existir uma segunda implementação real.

Integrações iniciais:

- Resend.
- Geoapify.
- Railway Buckets por protocolo compatível com S3.
- Web Push.
- Link externo do Google Maps, sem API paga.

## Contrato de falhas externas

| Integração | Timeout/falha | Efeito no domínio | Recuperação |
|---|---|---|---|
| Resend | E-mail não enviado | Transação principal permanece | Job retry-safe e alerta |
| Geoapify | Geocodificação indisponível | Não confirmar endereço novo | Erro orientado e nova tentativa |
| Railway Buckets | Upload indisponível | Não publicar arquivo incompleto | Rejeitar/retomar antes da publicação |
| Web Push | Entrega falha | Notificação interna permanece | Invalidar subscription quando apropriado |
| OpenFreeMap | Mapa não carrega | Busca em lista permanece | Interface de degradação |

## Consistência e concorrência

- Reservas e saldos devem ser alterados em transações atômicas.
- Requisições repetidas de callbacks, jobs ou confirmações devem ser idempotentes.
- Efeitos externos só devem ocorrer após persistência confirmada.
- Jobs precisam ser seguros para retry.

## Estados e histórico

- Transições de anúncio, solicitação, negociação, denúncia e chamado devem ser explícitas.
- Transição ilegal deve falhar de forma observável.
- Histórico administrativo e financeiro externo nunca deve ser inferido apenas do estado atual.

## Critérios de aceitação arquitetural

- [ ] Nenhuma dependência é adicionada sem ADR, necessidade e compatibilidade verificadas.
- [ ] Regra de negócio que altera um único registro fica próxima desse estado.
- [ ] Controllers não concentram transições ou cálculos de domínio.
- [ ] Integrações externas podem falhar sem corromper a transação principal.
- [ ] Reserva concorrente não produz saldo negativo.
- [ ] Jobs repetidos não duplicam efeitos funcionais.
- [ ] Hotwire entrega interação sem criar uma segunda aplicação front-end.
- [ ] Processos web e worker usam o mesmo código e contratos.
- [ ] Estrutura de pastas cresce por necessidade demonstrada, não por preenchimento antecipado.

## Dependências

- [ADRs](../../adr/)
- [SPEC-10 — Qualidade, segurança e privacidade](../qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-11 — Deploy e operação](../infraestrutura/spec-11-deploy-operacao.md)
- [SPEC-12 — Modelo de domínio e contratos](spec-12-modelo-dominio-contratos-dados.md)
- [SPEC-13 — Papéis e autorização](spec-13-papeis-autorizacao.md)
