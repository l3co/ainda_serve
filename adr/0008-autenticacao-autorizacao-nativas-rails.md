# ADR-0008 — Autenticação e autorização nativas do Rails

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

O produto precisa de e-mail, senha, confirmação, recuperação, dois fatores e vários papéis. A orientação do projeto é começar pequeno e não adicionar bibliotecas pesadas antes de provar necessidade.

## Decisão

Começar com mecanismos nativos e padrões da versão escolhida do Rails, incluindo armazenamento seguro de senha e verificações explícitas de propriedade e papel.

Não adicionar Devise, Pundit ou CanCanCan na fundação. Dois fatores e confirmação de e-mail devem ser especificados e avaliados separadamente; uma dependência só será adicionada se o Rails e o código focado não atenderem com segurança.

## Consequências

### Positivas

- Menor superfície de dependências e comportamento explícito.
- Autorização permanece próxima dos casos reais.
- Evita adaptar o domínio à API de uma biblioteca antecipadamente.

### Negativas

- A equipe é responsável por fluxos e testes de segurança.
- Complexidade de papéis pode futuramente justificar políticas dedicadas.
- Dois fatores pode exigir biblioteca especializada após avaliação.

## Alternativas consideradas

- Devise: adiado até insuficiência comprovada.
- Pundit ou CanCanCan: adiados até repetição ou complexidade justificarem.
- Serviço externo completo de identidade: rejeitado no MVP por custo e escopo.

## Gatilhos para revisão

- Repetição de regras de autorização em três ou mais contextos.
- Falhas de segurança ou manutenção no fluxo nativo.
- Necessidade de protocolos externos não atendidos.

## Referências

- [SPEC-01 — Contas, perfis e organizações](../specs/produto/spec-01-contas-perfis-organizacoes.md)
- [SPEC-10 — Qualidade, segurança e privacidade](../specs/qualidade/spec-10-qualidade-seguranca-privacidade.md)
