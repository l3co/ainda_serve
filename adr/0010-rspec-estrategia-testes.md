# ADR-0010 — RSpec como estratégia de testes

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

O desenvolvimento exige testes unitários e integrados, incluindo regras de estado, autorização, Hotwire e integrações externas.

## Decisão

Usar RSpec como framework principal, com testes:

- unitários para objetos Ruby puros;
- de model para Active Record e transições;
- de request para contratos HTTP, autenticação e autorização;
- de system para fluxos que dependem de Hotwire, Stimulus ou PWA;
- de integração com serviços externos sempre simulados.

FactoryBot e ferramentas auxiliares só serão adicionadas após verificar compatibilidade e necessidade na SPEC de fundação.

## Consequências

### Positivas

- Linguagem expressiva para cenários de domínio.
- Separação clara dos níveis de teste.
- Bom suporte a requests e system specs Rails.

### Negativas

- Dependências adicionais em relação ao Minitest padrão.
- Suite pode ficar lenta se system specs forem usados em excesso.
- Equipe deve evitar testes acoplados a detalhes internos.

## Alternativas consideradas

- Minitest: válido e nativo, mas não escolhido para este projeto.
- Apenas testes end-to-end: rejeitados por lentidão e diagnóstico ruim.
- Meta rígida de cobertura: rejeitada como substituto de cenários relevantes.

## Referências

- [SPEC-10 — Qualidade, segurança e privacidade](../specs/qualidade/spec-10-qualidade-seguranca-privacidade.md)
