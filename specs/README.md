# Especificações do Ainda Serve

**Versão do conjunto:** 0.2
**Estado:** Proposta para revisão
**Cobertura:** SPEC-01 a SPEC-17

## Autoridade e estado

As especificações descrevem o comportamento pretendido, os limites e as evidências necessárias para implementação. Todas permanecem em estado **Proposta**. Nenhuma delas autoriza código, scaffolds, dependências, migrations ou deploy até receber aprovação explícita e possuir tarefas revisadas para a fase correspondente.

## Convenções

- Documentação em português do Brasil.
- Termos técnicos, identificadores, comandos, mensagens e exemplos preservados na forma original.
- Código, comentários de código e identificadores persistidos em inglês.
- Requisitos com identificadores estáveis para rastreabilidade.
- Critérios de aceitação escritos como condições observáveis e verificáveis.
- Nomes conceituais não autorizam classes ou tabelas antes da revisão técnica da fase.
- Questões abertas classificadas pelo impacto e resolvidas antes da parte afetada.
- Mudanças de comportamento atualizam SPEC, plano e README quando aplicável.

## Estrutura esperada de uma SPEC

Uma SPEC proporcionalmente completa deve conter:

1. versão, estado, dependências e ADRs;
2. contexto, objetivo e limites;
3. atores e pré-condições quando aplicável;
4. contratos de entrada, saída ou dados relevantes;
5. requisitos funcionais e invariantes;
6. estados, transições e concorrência quando aplicável;
7. fluxos felizes, alternativos e de falha;
8. privacidade, autorização e observabilidade relevantes;
9. critérios de aceitação verificáveis;
10. riscos, questões abertas e referências.

Nem toda SPEC precisa repetir todos os tópicos. A informação deve permanecer na fonte de verdade mais específica e ser referenciada pelas demais.

## Índice

### Produto

| SPEC | Responsabilidade |
|---|---|
| [SPEC-01 — Contas, perfis e organizações](produto/spec-01-contas-perfis-organizacoes.md) | Identidade de pessoas e organizações, membros, documentos e ciclo da conta |
| [SPEC-02 — Anúncios e catálogo de materiais](produto/spec-02-anuncios-catalogo-materiais.md) | Catálogo, publicação, fotos, condição, estoque e materiais proibidos |
| [SPEC-03 — Busca e localização](produto/spec-03-busca-localizacao.md) | Busca pública, filtros, mapa, privacidade geográfica e pesquisas salvas |
| [SPEC-04 — Solicitações e negociações](produto/spec-04-solicitacoes-negociacoes.md) | Interesse, seleção, reserva, confirmação, cancelamento e conclusão |
| [SPEC-06 — Reputação e avaliações](produto/spec-06-reputacao-avaliacoes.md) | Avaliação bilateral, revelação e reputação por papel e unidade |
| [SPEC-14 — Jornadas, interface e PWA](produto/spec-14-jornadas-interface-pwa.md) | Arquitetura de informação, estados de UI, acessibilidade e progressive enhancement |
| [SPEC-17 — Lançamento, indicadores e evolução comercial](produto/spec-17-lancamento-indicadores-evolucao.md) | Piloto, prontidão, métricas, pausa e monetização futura |

### Capacidades

| SPEC | Responsabilidade |
|---|---|
| [SPEC-05 — Chat e notificações](capacidades/spec-05-chat-notificacoes.md) | Conversas textuais, eventos e entrega por plataforma, e-mail e Web Push |
| [SPEC-08 — Administração e atendimento](capacidades/spec-08-administracao-atendimento.md) | Filas, chamados, catálogo, indicadores e administrador inicial |

### Confiabilidade

| SPEC | Responsabilidade |
|---|---|
| [SPEC-07 — Moderação, contestações e recursos](confiabilidade/spec-07-moderacao-contestacoes.md) | Denúncias, evidências, medidas, decisões e recursos |
| [SPEC-15 — Observabilidade, auditoria e retenção](confiabilidade/spec-15-observabilidade-auditoria-retencao.md) | Logs, correlação, trilhas, alertas e classes de retenção |

### Arquitetura

| SPEC | Responsabilidade |
|---|---|
| [SPEC-09 — Arquitetura técnica](arquitetura/spec-09-arquitetura-tecnica.md) | Limites do monólito Rails, camadas pragmáticas e integrações |
| [SPEC-12 — Modelo de domínio e contratos de dados](arquitetura/spec-12-modelo-dominio-contratos-dados.md) | Entidades conceituais, cardinalidades, dados e invariantes |
| [SPEC-13 — Papéis, escopos e autorização](arquitetura/spec-13-papeis-autorizacao.md) | Matrizes de capacidade, propriedade, atribuição e acesso administrativo |

### Qualidade

| SPEC | Responsabilidade |
|---|---|
| [SPEC-10 — Qualidade, segurança e privacidade](qualidade/spec-10-qualidade-seguranca-privacidade.md) | Estratégia de testes, ameaças, uploads, privacidade e Definition of Done |

### Infraestrutura

| SPEC | Responsabilidade |
|---|---|
| [SPEC-11 — Deploy e operação](infraestrutura/spec-11-deploy-operacao.md) | Topologia Railway, ambientes, configuração, saúde e recuperação |
| [SPEC-16 — DevOps, CI/CD e engenharia de entrega](infraestrutura/spec-16-devops-cicd.md) | Gates, build, migrations, release, smoke test e rollback |

## Ordem de leitura recomendada

1. [PRD](../visao-geral.md) — problema, público, jornadas e limites.
2. [SPEC-12](arquitetura/spec-12-modelo-dominio-contratos-dados.md) — vocabulário e invariantes.
3. [SPEC-13](arquitetura/spec-13-papeis-autorizacao.md) — quem pode fazer o quê.
4. SPEC-01 a SPEC-08 — comportamento funcional.
5. [SPEC-14](produto/spec-14-jornadas-interface-pwa.md) — composição na experiência.
6. SPEC-09, SPEC-10, SPEC-15 e SPEC-16 — arquitetura, qualidade e operação.
7. [SPEC-17](produto/spec-17-lancamento-indicadores-evolucao.md) — critérios de lançamento.
8. [Plano geral](../plans/plan-geral.md) — sequência de entrega.

## Rastreabilidade

```text
PRD/Jornada
   └── SPEC/requisito
         └── critério de aceitação
               └── task aprovada
                     └── teste/evidência
                           └── mudança revisada
```

Uma task futura deve citar as SPECs e os identificadores atendidos. Um critério sem teste automatizado possível deve indicar a evidência manual ou operacional esperada.

## Questões bloqueantes conhecidas

| Questão | Bloqueia |
|---|---|
| Prazo da confirmação do destinatário em doação | Avaliação e encerramento de doação |
| Janela, tamanho, frequência e retenção do chat | Implementação do chat |
| Política final de retenção | Lançamento público |
| Versões de Ruby/Rails e ferramentas da pipeline | Fundação executável |
| Região, domínio, monitoramento e homologação | Deploy de produção |
| Termos e políticas revisados | Publicação e lançamento |

## Fluxo de aprovação

1. Revisar contexto, escopo, contratos, requisitos e critérios.
2. Resolver questões bloqueantes da fase.
3. Registrar alteração no documento fonte e nas referências afetadas.
4. Aprovar explicitamente a SPEC ou o conjunto da fase.
5. Atualizar o [plano geral](../plans/plan-geral.md).
6. Criar `tasks/` somente para o escopo aprovado.
7. Revisar as tarefas antes de qualquer implementação.

## Checklist de aprovação de uma SPEC

- [ ] Objetivo e fora do escopo estão claros.
- [ ] Atores, dados e permissões relevantes estão definidos.
- [ ] Estados e falhas não deixam comportamento crítico implícito.
- [ ] Critérios de aceitação podem gerar testes ou evidências objetivas.
- [ ] Dependências e ADRs estão corretos.
- [ ] Questões bloqueantes foram resolvidas ou a parte afetada foi adiada.
- [ ] O documento não prescreve abstração sem necessidade demonstrada.
