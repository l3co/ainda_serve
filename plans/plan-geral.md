# Plano geral de entrega do Ainda Serve

**Versão:** 0.2
**Estado:** Proposto
**Cobertura:** PRD, SPEC-01 a SPEC-17 e ADR-0001 a ADR-0011
**Autoridade:** organiza a entrega, mas não autoriza implementação

## Visão geral

Este plano traduz o produto em uma sequência de incrementos verificáveis. A estratégia combina fundação mínima, fatias verticais e redução antecipada dos riscos de identidade, localização, estoque e autorização.

As tasks executáveis ainda não existem. Elas só serão criadas depois da aprovação explícita das SPECs da fase correspondente.

## Objetivo

Entregar uma aplicação Rails nacional, responsiva e instalável como PWA, capaz de operar o ciclo de publicação, descoberta, solicitação, seleção e conclusão de materiais para venda ou doação, com privacidade, moderação e rastreabilidade proporcionais ao risco.

## Estado atual

- Repositório documental, sem aplicação Rails criada.
- PRD, dez ADRs e dezessete SPECs em estado **Proposta**.
- Tecnologia e integrações principais escolhidas em nível arquitetural.
- Nenhuma versão exata, gem, migration, ambiente ou credencial configurada.
- Nenhuma task de implementação criada ou autorizada.

## Estado desejado

- Aplicação Rails com Hotwire, Tailwind e PostgreSQL.
- Processos web e worker implantados no Railway.
- Pessoas e organizações operando em contextos exclusivos.
- Estoque protegido contra reserva concorrente e replay.
- Endereço real restrito ao destinatário selecionado.
- Comunicação, avaliação, moderação e administração auditáveis.
- Pipeline de qualidade, smoke test, backup e restauração validados.
- Lançamento controlado com métricas e condições de pausa.

## Critérios gerais de sucesso

- [ ] Cada comportamento implementado deriva de SPEC aprovada e task revisada.
- [ ] Nenhuma reserva ou conclusão aceita saldo negativo ou efeito duplicado.
- [ ] Nenhuma projeção pública expõe documento ou endereço exato.
- [ ] Papéis pessoais, organizacionais e administrativos passam por testes positivos e negativos.
- [ ] Jornadas essenciais funcionam em viewport móvel, por teclado e sem permissões opcionais.
- [ ] Falhas externas não corrompem transações concluídas.
- [ ] Deploy possui smoke test, observabilidade e recuperação exercitada.
- [ ] O responsável aprova cada fase antes do início da seguinte quando houver decisão pendente.

## Escopo

### Incluído

- Funcionalidades do [PRD](../visao-geral.md) e das [SPECs](../specs/README.md).
- Arquitetura monolítica Rails e integrações dos [ADRs](../adr/).
- Testes unitários, model, request, system, integração e concorrência conforme risco.
- Operação nacional com piloto e divulgação inicial em São Paulo.
- Documentação operacional necessária ao lançamento.

### Excluído

- Processamento interno de pagamento, comissão e reembolso.
- Contratação ou rastreamento de transporte.
- Verificação biométrica ou consulta paga de identidade.
- Aplicativos móveis nativos.
- Anúncios patrocinados e planos pagos no MVP.
- Métrica ambiental agregada sem metodologia aprovada.

### Evolução futura registrada

- Anúncios patrocinados identificados.
- Planos empresariais.
- Importação em massa.
- Verificação forte de identidade.
- Metodologia de impacto ambiental.

Esses itens permanecem fora da modelagem executável até uma SPEC própria ser aprovada.

## Premissas declaradas

| Premissa | Impacto se estiver errada | Validação |
|---|---|---|
| Rails e Hotwire atendem a experiência responsiva | Mudança de arquitetura de interface | Provar jornadas principais antes de adicionar outra stack |
| PostgreSQL atende busca e geografia iniciais | Serviço de busca/geografia adicional | Medir consultas reais antes de novo ADR |
| Railway suporta web, worker, banco e bucket no custo aceito | Revisão de plataforma | Verificar limites e custo antes da fase operacional |
| Validação local de CPF/CNPJ é suficiente para o MVP | Maior risco de identidade falsa | Monitorar fraude e revisar por gatilho |
| Pagamento e logística externos são compreendidos | Contestação e frustração maiores | Teste de conteúdo e feedback no piloto |
| Uma operação inicial pequena consegue moderar casos | Lançamento precisa ser limitado | Exercício de filas e capacidade no piloto |

## Restrições

- SDD obrigatório: código somente após SPEC aprovada.
- Código e comentários em inglês; documentação de projeto em português do Brasil.
- Ruby e Rails em versões estáveis e suportadas, escolhidas apenas na fase de fundação.
- Docker e Docker Compose são o ambiente padrão de desenvolvimento e testes locais, sem obrigatoriedade de produção.
- SOLID pragmático e princípios de *99 Bottles of OOP*.
- Não criar abstrações, engines, microserviços ou gems por antecipação.
- README atualizado na mesma mudança de funcionalidade ou biblioteca.
- Dúvidas que alterem produto, arquitetura, dados ou dependências retornam ao responsável.

## Arquitetura resumida

```text
Pessoa/Organização
        │
        ▼
Browser/PWA ── HTML/Turbo/Stimulus ──> Rails Web
                                           │
                           ┌───────────────┴───────────────┐
                           ▼                               ▼
                       PostgreSQL                    Solid Queue Worker
                           │                               │
                           └──── estado e contratos ───────┘
                                           │
                    ┌─────────────┬─────────┴───────┬─────────────┐
                    ▼             ▼                 ▼             ▼
               Resend       Geoapify       Railway Buckets    Web Push

Browser ── MapLibre/OpenFreeMap; Google Maps somente por link externo de rota
```

As fronteiras e invariantes estão na [SPEC-09](../specs/arquitetura/spec-09-arquitetura-tecnica.md) e na [SPEC-12](../specs/arquitetura/spec-12-modelo-dominio-contratos-dados.md).

## Estrutura de aplicação prevista

A árvore abaixo orienta planejamento; diretórios condicionais só serão criados quando houver uma classe aprovada que os justifique.

```text
.
├── app/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   ├── javascript/
│   ├── jobs/
│   ├── mailers/
│   ├── clients/          # condicional: primeira integração focada
│   ├── policies/         # condicional: regra de autorização focada
│   └── queries/          # condicional: consulta complexa comprovada
├── config/
├── db/
│   ├── migrate/
│   └── seeds.rb
├── spec/
│   ├── models/
│   ├── requests/
│   ├── system/
│   └── support/
├── adr/
├── plans/
├── specs/
├── tasks/                # somente após aprovação
├── AGENT.md
└── README.md
```

## Estratégia de entrega

1. **Contrato antes da implementação:** aprovar dados, estados, autorização e critérios.
2. **Fundação mínima:** gerar somente o necessário para executar a primeira fatia.
3. **Fatias verticais:** entregar uma jornada observável do formulário ao banco e ao teste.
4. **Risco cedo:** provar autenticação, privacidade geográfica e concorrência antes de ampliar o produto.
5. **Integração isolada:** comportamento interno com fakes antes de credenciais reais.
6. **Feedback rápido:** cada fase termina com demonstração e evidência.
7. **Rollout gradual:** uso interno, piloto convidado e abertura nacional.

## Visão das fases

| Fase | Objetivo | Depende de | Entrega verificável | Estado |
|---|---|---|---|---|
| 01 | Aprovar contratos e decisões | Nenhuma | PRD, SPECs e ADRs aprovados para fundação | Proposta |
| 02 | Criar fundação executável | Fase 01 | Rails/PostgreSQL/Tailwind/RSpec e CI mínimos | Proposta |
| 03 | Entregar conta pessoal | Fase 02 | Cadastro, confirmação, login, recuperação e perfil público | Proposta |
| 04 | Entregar organização mínima | Fase 03 | Organização, unidade, convite e papéis básicos | Proposta |
| 05 | Publicar e administrar anúncio | Fases 03–04 | Catálogo inicial, rascunho, fotos, termo e publicação | Proposta |
| 06 | Descobrir material com privacidade | Fase 05 | Busca pública, filtros, lista/mapa e ponto aproximado | Proposta |
| 07 | Solicitar, conversar e selecionar | Fases 05–06 | Solicitação, chat, lista de espera e reserva atômica | Proposta |
| 08 | Concluir doação e venda | Fase 07 | Confirmações, cancelamento, inatividade e contestação | Proposta |
| 09 | Entregar reputação e confiança | Fase 08 | Avaliações, denúncias, bloqueios, decisões e recursos | Proposta |
| 10 | Entregar operação administrativa | Fases 04–09 | Filas, chamados, auditoria, indicadores e seed inicial | Proposta |
| 11 | Preparar PWA e operação | Fases 06–10 | Push, acessibilidade final, CI/CD, backup e deploy validado | Proposta |
| 12 | Realizar lançamento controlado | Fase 11 | Uso interno, piloto convidado e decisão de abertura | Proposta |

## Detalhamento e gates por fase

### Fase 01 — Aprovação documental

**Valor:** remove decisões implícitas antes do custo de código.
**SPECs centrais:** todas, com foco em SPEC-12, SPEC-13 e questões bloqueantes.
**Gate:** critérios testáveis, versões documentais consistentes e aprovação explícita.
**Não inclui:** criação de tasks ou aplicação.

### Fase 02 — Fundação executável

**Valor:** primeiro ciclo local em Docker Compose com build, teste e página acessível.
**Risco reduzido:** compatibilidade real entre versões, Railway e stack escolhida.
**Decisões necessárias:** versões exatas, ferramentas de CI/lint e topologia local.
**Evidência:** aplicação e PostgreSQL sobem no ambiente Docker local e a suíte inicial executa sem rede externa.

### Fase 03 — Conta pessoal

**Fatia:** cadastrar → confirmar e-mail → autenticar → visualizar/editar perfil.
**Casos críticos:** maioridade, documento duplicado, confirmação, recuperação e autorização negativa.
**Evidência:** system spec do fluxo principal e request specs de negação.

### Fase 04 — Organização mínima

**Fatia:** criar organização → criar unidade → convidar membro → atribuir papel.
**Casos críticos:** contexto exclusivo, responsável único, remoção e transferência.
**Evidência:** matriz organizacional da SPEC-13 coberta no escopo implementado.

### Fase 05 — Anúncio publicável

**Fatia:** criar rascunho → anexar fotos → aceitar termo → publicar → pausar/reativar.
**Casos críticos:** venda/doação exclusiva, preço, validade, material proibido e metadados de imagem.
**Evidência:** anúncio público sem localização exata e arquivos privados.

### Fase 06 — Descoberta geográfica

**Fatia:** pesquisar → filtrar → alternar lista/mapa → abrir anúncio.
**Casos críticos:** permissão negada, falha do mapa, ponto deslocado e atribuições.
**Evidência:** nenhuma resposta pública inclui coordenada real.

### Fase 07 — Solicitação e reserva

**Fatia:** solicitar quantidade → conversar → comparar interessados → selecionar.
**Casos críticos:** saldo alterado, seleção concorrente, atribuição organizacional e revogação de acesso.
**Evidência:** teste de concorrência com PostgreSQL e isolamento de conversas.

### Fase 08 — Conclusão

**Fatia:** combinar entrega → confirmar → concluir ou contestar.
**Casos críticos:** diferenças entre venda e doação, prazo de três dias, replay e inatividade.
**Evidência:** linha do tempo e equação de estoque preservadas em todos os finais.

### Fase 09 — Confiança e segurança

**Fatia:** avaliar, denunciar, bloquear, decidir e recorrer.
**Casos críticos:** revelação bilateral, ocultação preventiva, evidências privadas e até três recursos.
**Evidência:** decisão auditável e acesso administrativo restrito ao caso.

### Fase 10 — Administração

**Fatia:** receber item em fila → atribuir → analisar → decidir → notificar.
**Casos críticos:** menor privilégio, seed idempotente e restauração.
**Evidência:** papéis administrativos cobertos por testes negativos.

### Fase 11 — PWA e operação

**Fatia:** instalar opcionalmente → receber push consentido → operar release observável.
**Casos críticos:** progressive enhancement, migrations, secrets, backup e rollback.
**Evidência:** smoke test e restauração documentada em ambiente seguro.

### Fase 12 — Lançamento controlado

**Fatia:** uso interno → piloto convidado → decisão de abertura nacional.
**Casos críticos:** capacidade de moderação, incidentes de privacidade e densidade de oferta.
**Evidência:** critérios da SPEC-17 medidos e decisão humana registrada.

## Caminho crítico

```text
F01 contratos
  → F02 fundação
  → F03 identidade
  → F04 organizações
  → F05 anúncios
  → F06 descoberta
  → F07 reserva
  → F08 conclusão
  → F09 confiança
  → F10 operação
  → F11 prontidão
  → F12 lançamento
```

Reputação depende de conclusão. Moderação completa depende de objetos denunciáveis. Lançamento depende de operação e recuperação, não apenas de telas prontas.

## Trabalho potencialmente paralelo

- Conteúdo de termos e materiais proibidos pode avançar durante fundação, sem substituir revisão jurídica.
- Identidade visual pode avançar depois da arquitetura de informação aprovada.
- Preparação de contas externas pode ocorrer antes das integrações, sem credenciais no repositório.
- Testes de contrato de integrações podem ocorrer em homologação quando os clientes focados existirem.

Trabalho que compartilha modelo, migration ou questão aberta não deve ser paralelizado sem coordenação explícita.

## Mapa de dependências

### Dependências humanas

- Aprovação de cada SPEC e das tasks futuras.
- Revisão de Termos de Uso, Política de Privacidade e retenção.
- Definição de capacidade e responsáveis operacionais.

### Dependências externas

- Railway, Railway PostgreSQL e Railway Buckets.
- Resend e domínio de envio.
- Geoapify.
- OpenFreeMap e ecossistema OpenStreetMap.
- Suporte a Web Push dos navegadores.

### Dependências de decisão

- Versões exatas de Ruby e Rails antes da Fase 02.
- Prazo de confirmação de doação antes da parte afetada da Fase 08/09.
- Limites e retenção de chat antes da Fase 07.
- Política de retenção antes da Fase 11/12.
- CI/CD, homologação, domínio e monitoramento antes da Fase 11.

## Estratégia de erros

- Erro de validação orienta correção e preserva entrada válida.
- Erro de autorização não revela dado ou existência indevida.
- Conflito de domínio informa que o estado mudou e exige atualização.
- Falha externa tem timeout, resultado próprio e retry somente quando seguro.
- Job esgotado fica visível à operação e não repete efeito funcional.
- Erro inesperado recebe correlação; stack trace fica fora da interface.

## Estratégia de testes

- **Unitários:** cálculos, validações e objetos Ruby puros.
- **Model:** invariantes, estados e transições legais/ilegais.
- **Request:** autenticação, autorização, ownership e contratos HTTP.
- **System:** jornadas com Turbo, Stimulus, mapa e PWA.
- **Integração local:** PostgreSQL real para constraints e concorrência.
- **Contrato externo:** respostas de integrações em ambiente controlado.
- **Operacional:** smoke test, backup, restauração e alertas.

Testes pertencem à mesma task do comportamento. Não existe fase final separada para “adicionar testes”.

## Riscos principais

| Risco | Categoria | Probabilidade | Impacto | Fase | Mitigação |
|---|---|---|---|---|---|
| Escopo inicial amplo | Cronograma | Alta | Alto | Todas | Fatias verticais, gates e adiamento explícito |
| Exposição de localização | Segurança | Média | Crítico | 06–08 | Projeção separada, autorização e testes negativos |
| Reserva concorrente | Dados | Média | Crítico | 07–08 | Transação, constraint, idempotência e teste real |
| Abuso ou material perigoso | Segurança | Média | Crítico | 05–10 | Termo, denúncia, ocultação e fila crítica |
| Regras de papel inconsistentes | Arquitetura | Média | Alto | 03–10 | Matriz central e testes positivos/negativos |
| Limites de serviços gratuitos | Integração | Média | Médio | 06, 11 | Monitoramento, degradação e gatilhos de revisão |
| Retenção inadequada | Dados | Média | Alto | 09–12 | Classificação por finalidade e revisão antes do lançamento |
| Capacidade operacional insuficiente | Operação | Média | Alto | 10–12 | Exercício interno, piloto limitado e condição de pausa |

## Estratégia de rollout

1. Desenvolvimento e testes com dados fictícios.
2. Homologação ou ambiente temporário equivalente com integrações controladas.
3. Uso interno e exercício de incidentes.
4. Piloto convidado em São Paulo sem restrição geográfica técnica.
5. Estabilização e correção de bloqueadores.
6. Abertura nacional condicionada aos critérios da SPEC-17.

## Rollback e recuperação

Cada fase com dado persistido deverá declarar:

- sinal de detecção;
- condição de parada;
- revisão ou flag a reverter;
- compatibilidade da migration;
- jobs a interromper;
- dados em risco;
- verificação de integridade após recuperação.

Mudanças documentais desta fase são reversíveis por diff. Nenhuma ação externa está autorizada por este plano.

## Questões abertas

| Questão | Afeta | Bloqueante |
|---|---|---:|
| Prazo de confirmação do destinatário na doação | Fases 08–09 | Sim para avaliação |
| Limites, ocultação e retenção do chat | Fase 07 | Sim |
| Versões de Ruby e Rails | Fase 02 | Sim |
| Provedor de CI/CD e ferramentas de qualidade | Fase 02/11 | Sim por fase |
| Imagens, serviços, volumes e comandos do ambiente Docker local | Fase 02 | Sim |
| Política final de retenção | Fases 11–12 | Sim |
| Região, homologação, domínio e monitoramento | Fase 11 | Sim |
| Metas e tamanho do piloto | Fase 12 | Sim para lançamento |
| Verificação forte de identidade | Futuro | Não |
| Preços de anúncios e planos | Futuro | Não |

## Critério para iniciar implementação

Uma fase somente pode passar de **Proposta** para **Pronta** quando:

- [ ] SPECs da fase foram aprovadas explicitamente.
- [ ] ADRs necessários foram aceitos.
- [ ] Questões bloqueantes foram resolvidas ou o escopo afetado foi removido.
- [ ] Critérios de aceitação são testáveis.
- [ ] Tasks pequenas e verticais foram criadas e revisadas.
- [ ] Dependências externas necessárias estão disponíveis sem segredo versionado.
- [ ] Riscos altos possuem detecção e recuperação.

## Documentos relacionados

- [PRD](../visao-geral.md)
- [Índice de SPECs](../specs/README.md)
- [ADRs](../adr/)
- [Instruções para agentes](../AGENT.md)
