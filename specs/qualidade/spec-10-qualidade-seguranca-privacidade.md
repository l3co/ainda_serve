# SPEC-10 — Qualidade, segurança e privacidade

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** todas as SPECs funcionais
**ADRs:** 0006, 0008, 0010

## Estado

Proposta.

## Objetivo

Definir critérios transversais de testes, acessibilidade, proteção de dados, uploads, autorização e resiliência.

## Escopo

### Incluído

- Estratégia de testes.
- Autenticação, autorização e proteção de dados.
- Segurança de uploads e conteúdo do usuário.
- Acessibilidade, PWA e observabilidade mínima.

### Excluído

- Parecer jurídico definitivo.
- Certificação formal de segurança ou acessibilidade no MVP.
- Meta artificial de cobertura de testes.

## Ativos e ameaças prioritárias

| Ativo | Ameaça principal | Controle obrigatório |
|---|---|---|
| Conta e sessão | Tomada de conta, força bruta, sessão antiga | Senha segura, rate limit, rotação e dois fatores conforme papel |
| CPF/CNPJ/nascimento | Exposição ou enumeração | Restrição, mascaramento e mensagens não reveladoras |
| Endereço exato | Acesso antes da seleção ou após cancelamento | Autorização por estado e revogação imediata |
| Estoque | Corrida de reservas ou replay | Transação, constraint e idempotência |
| Chat/evidências | Acesso indevido ou conteúdo ativo | Escopo por participante/caso e validação de upload |
| Administração | Abuso de privilégio | Menor privilégio, dois fatores e auditoria |
| Integrações | Segredo vazado ou resposta malformada | Clientes focados, timeout, validação e redaction |

## Matriz de verificação por risco

| Comportamento | Unit/model | Request | System | Integração |
|---|---:|---:|---:|---:|
| Maioridade e documento | Sim | Sim | Fluxo principal | Não |
| Autorização e propriedade | Policy/model quando aplicável | Sim, positivo e negativo | Jornada crítica | Não |
| Estoque e transições | Sim | Sim | Jornada principal | Concorrência com PostgreSQL |
| Localização pública | Transformação | Sim | Lista/mapa | Contrato do geocoder simulado |
| Upload privado | Validação | Sim | Publicação/denúncia | Storage simulado |
| Notificação | Regra de preferência | Sim | Central | Provider simulado |
| PWA/Hotwire | Quando houver lógica pura | Sim | Sim | Navegador controlado |

## Controles de fronteira

- Entrada HTTP possui limite de tamanho e strong parameters.
- Identificadores públicos não substituem autorização.
- Upload só se torna acessível após validações do servidor.
- Integrações retornam objetos ou resultados próprios, não respostas brutas espalhadas.
- Erro apresentado ao usuário não contém stack trace, segredo ou existência indevida de conta.
- Dados usados em teste e documentação são fictícios.

## Definition of Done de uma funcionalidade

Uma funcionalidade só pode ser considerada concluída quando:

1. possui SPEC aprovada e task revisada;
2. critérios de aceite estão ligados a testes proporcionais ao risco;
3. autorização positiva e negativa foi verificada;
4. falhas externas e retries relevantes foram considerados;
5. acessibilidade e viewport móvel foram verificadas quando há interface;
6. logs não ampliam exposição de dados;
7. README foi atualizado quando funcionalidade ou biblioteca mudou;
8. diff foi revisado e aprovado pelo responsável.

## Estratégia de testes

- **QUA-001:** Usar RSpec como framework de teste.
- **QUA-002:** Objetos Ruby puros devem possuir testes unitários sem banco quando aplicável.
- **QUA-003:** Modelos devem testar validações, invariantes, estados e transições legais e ilegais.
- **QUA-004:** Requests devem testar autenticação, autorização, propriedade e contratos HTTP.
- **QUA-005:** Fluxos dependentes de Turbo, Stimulus, JavaScript ou PWA devem possuir system specs.
- **QUA-006:** Não usar system spec quando request spec mais rápido prova o comportamento.
- **QUA-007:** Integrações externas devem ser simuladas e cobrir sucesso, timeout, limite, resposta inválida e indisponibilidade.
- **QUA-008:** Testes não podem chamar serviços externos reais.
- **QUA-009:** Correção de regressão deve incluir teste que falharia antes da correção quando viável.
- **QUA-010:** Não usar percentual de cobertura como substituto de cenários relevantes.

## Autenticação e autorização

- **QUA-011:** Toda autorização é validada no servidor.
- **QUA-012:** Conhecer um identificador não concede acesso ao recurso.
- **QUA-013:** Recursos devem testar usuário não autenticado e usuário autenticado sem permissão.
- **QUA-014:** CSRF, strong parameters e proteções padrão do Rails não podem ser desativados para facilitar testes.
- **QUA-015:** Senhas usam mecanismo seguro do Rails e nunca aparecem em logs.
- **QUA-016:** Segundo fator é obrigatório para administradores da plataforma.

## Privacidade

- **QUA-017:** CPF, CNPJ, nascimento, telefone, e-mail e endereço exato são dados restritos.
- **QUA-018:** Respostas públicas não podem conter coordenada real do material.
- **QUA-019:** Logs devem mascarar dados pessoais e tokens.
- **QUA-020:** Exemplos e testes usam dados fictícios.
- **QUA-021:** Alterações e acessos administrativos sensíveis devem ser auditados.
- **QUA-022:** Usuário pode solicitar cópia e exclusão conforme SPEC-01.
- **QUA-023:** Política de retenção deve ser definida antes do lançamento e revisada juridicamente.

## Uploads

- **QUA-024:** Foto de anúncio aceita JPEG, PNG ou WebP até 10 MB.
- **QUA-025:** Foto de perfil aceita formatos aprovados até 5 MB.
- **QUA-026:** Evidência aceita JPEG, PNG ou PDF até 20 MB.
- **QUA-027:** A aplicação valida extensão, tipo real, tamanho e conteúdo básico no servidor.
- **QUA-028:** Imagens devem ter metadados de localização removidos.
- **QUA-029:** Arquivos são privados por padrão e entregues por URL temporária ou proxy autorizado.
- **QUA-030:** Conteúdo ativo, scripts ou HTML em upload deve ser recusado.
- **QUA-031:** Limites de quantidade e frequência devem prevenir abuso de armazenamento.

## Conteúdo do usuário

- **QUA-032:** Texto deve ser escapado e sanitizado conforme o contexto.
- **QUA-033:** Não usar `raw` ou `html_safe` sobre entrada do usuário sem sanitização explícita.
- **QUA-034:** Formulários e endpoints devem possuir limites proporcionais contra spam e força bruta.
- **QUA-035:** Mensagens ocultadas e evidências permanecem acessíveis somente aos papéis autorizados.

## Acessibilidade e experiência

- **QUA-036:** Funcionalidades devem ser utilizáveis por teclado.
- **QUA-037:** Imagens exigem texto alternativo ou indicação adequada de decoração.
- **QUA-038:** Contraste, foco visível, rótulos e mensagens de erro devem ser perceptíveis.
- **QUA-039:** Atualizações Turbo e notificações em tempo real devem ser anunciadas de forma acessível quando necessário.
- **QUA-040:** Negar geolocalização, push ou instalação da PWA não impede o uso principal.
- **QUA-041:** PWA deve preservar progressive enhancement e não prometer funcionamento offline de negociação sem uma SPEC específica.

## Confiabilidade

- **QUA-042:** Jobs são idempotentes e retry-safe.
- **QUA-043:** Falha de e-mail, push ou mapa não desfaz transação de negócio concluída.
- **QUA-044:** Timeouts e erros externos geram registro observável sem expor segredo.
- **QUA-045:** Concorrência de reserva deve possuir teste integrado.
- **QUA-046:** Exclusões e sanções administrativas devem ser reversíveis quando permitido.

## Critérios de aceitação

- [ ] Cada fluxo crítico possui testes positivos e de autorização negativa.
- [ ] Nenhum teste automatizado depende de rede externa.
- [ ] Dados sensíveis não aparecem em páginas públicas ou logs de teste.
- [ ] Upload inválido é rejeitado antes de ficar acessível.
- [ ] Falha de integração não corrompe estoque, negociação ou conta.
- [ ] Replay ou duplo envio não duplica reserva, confirmação ou notificação.
- [ ] Fluxos principais funcionam por teclado e sem geolocalização.
- [ ] Atualizações Turbo relevantes são anunciadas de forma acessível.
- [ ] Retenção é aprovada antes do lançamento.
- [ ] A Definition of Done é aplicada a cada task futura.

## Dependências

- [SPEC-09 — Arquitetura técnica](../arquitetura/spec-09-arquitetura-tecnica.md)
- [SPEC-11 — Deploy e operação](../infraestrutura/spec-11-deploy-operacao.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](../confiabilidade/spec-15-observabilidade-auditoria-retencao.md)
- [SPEC-16 — DevOps e CI/CD](../infraestrutura/spec-16-devops-cicd.md)
