# ADR-0001 — Monólito Rails com Hotwire e Tailwind

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

O produto precisa de autenticação, marketplace, chat, administração, jobs e páginas públicas. A equipe escolheu Ruby e Rails e quer evolução orientada por especificações, SOLID pragmático e *99 Bottles of OOP*.

## Decisão

Construir um monólito Rails com renderização no servidor, Hotwire para interações e Tailwind CSS para apresentação. A aplicação será responsiva e instalável como PWA.

As versões exatas de Ruby e Rails serão as versões estáveis, não obsoletas e compatíveis entre si no início da implementação. A escolha exata será registrada antes de gerar a aplicação.

## Consequências

### Positivas

- Um único código, banco e modelo de autorização.
- Hotwire reduz JavaScript específico e preserva progressive enhancement.
- Deploy e operação mais simples no Railway.
- Refatorações podem seguir necessidades reais do domínio.

### Negativas

- Processos web e worker precisam de disciplina para não acoplar efeitos externos às transações.
- Páginas com estado cliente muito complexo podem exigir Stimulus cuidadoso.
- Escalabilidade ocorre primeiro por processos e banco compartilhados.

## Alternativas consideradas

- Rails API com React ou Vue: rejeitada por complexidade e duplicação prematuras.
- Microserviços: rejeitados por não haver escala ou fronteiras comprovadas.
- Aplicação móvel nativa: adiada; PWA atende a primeira etapa.

## Restrições

- Nova SPA ou serviço independente exige ADR específico.
- Abstrações devem ser conquistadas por casos reais, não previstas.

## Referências

- [SPEC-09 — Arquitetura técnica](../specs/arquitetura/spec-09-arquitetura-tecnica.md)
