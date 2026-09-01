# PRD — Ainda Serve

**Versão:** 0.2
**Estado:** Proposta para revisão
**Última atualização:** 31 de agosto de 2026
**Nível:** visão de produto
**Autoridade:** este documento descreve o produto, mas não autoriza implementação

## Resumo executivo

Ainda Serve é uma plataforma nacional para doação e venda de materiais e sobras de construção. Ela aproxima pessoas físicas e organizações que possuem materiais disponíveis de pessoas e organizações interessadas em reaproveitá-los.

A plataforma facilita descoberta, comunicação, escolha do destinatário e registro da negociação. No MVP, não processa pagamentos, não contrata transporte, não garante qualidade e não assume a entrega. Esses limites devem aparecer de forma clara nos fluxos em que possam influenciar a decisão do usuário.

**Proposta de marca:** O fim da obra não é o fim do material.

## Problema

Materiais novos, sobras de obra e itens usados ainda aproveitáveis podem permanecer parados, ocupar espaço ou ser descartados porque seus proprietários não encontram com facilidade alguém próximo que os queira.

Quem procura esses materiais enfrenta o problema inverso: ofertas estão dispersas, possuem descrições inconsistentes, raramente informam quantidade e conservação com clareza e podem expor dados pessoais ou endereços antes de existir confiança entre as partes.

Os principais custos do problema são:

- desperdício de materiais ainda úteis;
- custo e esforço de descarte para pessoas e organizações;
- dificuldade de acesso a materiais por quem possui orçamento limitado;
- risco de segurança em negociações informais sem histórico;
- exposição prematura de telefone, documentos e localização exata;
- falta de rastreabilidade quando há cancelamento, abuso ou contestação.

## Resultado pretendido

Uma pessoa ou organização deve conseguir publicar um material com quantidade e condição claras, receber solicitações, conversar com interessados, escolher livremente um destinatário e registrar a conclusão.

Um interessado deve conseguir pesquisar ofertas em todo o Brasil, estimar a distância sem descobrir o endereço exato, solicitar uma quantidade disponível e avaliar a outra parte depois de uma negociação elegível.

A operação da plataforma deve conseguir moderar conteúdo, investigar casos denunciados, preservar evidências e aplicar medidas proporcionais sem transformar o Ainda Serve em intermediador financeiro ou logístico.

## Público e atores

| Ator | Contexto | Necessidade principal |
|---|---|---|
| Pessoa física anunciante | Maior de 18 anos, com material próprio disponível | Publicar, escolher interessados e concluir doação ou venda |
| Pessoa física interessada | Maior de 18 anos, procurando material | Encontrar, solicitar, conversar e receber ou comprar |
| Organização anunciante | ONG, loja, construtora ou outra pessoa jurídica | Operar por membros e unidades, com responsabilidade e histórico |
| Organização interessada | Organização que reutiliza ou adquire materiais | Solicitar em nome de uma unidade e coordenar recebimento |
| Responsável organizacional | Pessoa responsável pela conta da organização | Controlar membros, unidades e transferência de responsabilidade |
| Operador organizacional | Membro com escopo limitado | Atender anúncios e negociações atribuídos |
| Administrador da plataforma | Papel interno privilegiado | Administrar acesso, configuração e decisões críticas |
| Moderador | Papel interno de confiança e segurança | Analisar conteúdo, denúncias e medidas temporárias |
| Atendimento | Papel interno de suporte | Atender chamados e acompanhar contestações dentro de seu escopo |
| Visitante | Pessoa sem autenticação | Pesquisar e visualizar anúncios públicos sem dados restritos |

O cadastro estará aberto para todo o Brasil. A divulgação inicial será concentrada em São Paulo, sem restringir publicação ou busca a esse estado.

## Proposta de valor

### Para quem anuncia

- transformar material parado em doação ou venda;
- informar disponibilidade por lote ou unidade;
- receber interessados sem publicar contato ou endereço;
- comparar perfil, distância, histórico e reputação;
- selecionar livremente um ou mais interessados dentro do saldo;
- manter um registro da negociação e das confirmações.

### Para quem procura

- buscar por texto, categoria, condição, preço, quantidade e distância;
- visualizar ofertas em lista ou mapa aproximado;
- solicitar todo o saldo ou uma quantidade parcial;
- conversar antes da seleção;
- receber o endereço exato somente quando selecionado;
- avaliar a experiência após uma conclusão elegível.

### Para organizações

- operar com membros, papéis, unidades e endereços distintos;
- atribuir anúncios e negociações;
- configurar destinatários de notificações;
- visualizar reputação geral e por unidade;
- preservar autoria e auditoria das ações dos membros.

## Jornadas essenciais do MVP

### J01 — Criar e confirmar uma conta pessoal

1. A pessoa informa os dados cadastrais e declara ser maior de 18 anos.
2. O sistema valida localmente e-mail, CPF e data de nascimento.
3. A pessoa confirma o endereço de e-mail.
4. A conta confirmada pode publicar, solicitar e conversar.

### J02 — Criar uma organização

1. O responsável informa os dados da organização e seus próprios dados de acesso.
2. O sistema valida localmente o CNPJ e confirma o e-mail.
3. O responsável cria ao menos uma unidade e um endereço operacional.
4. Membros podem ser convidados e recebem papéis explícitos.

### J03 — Publicar um material

1. O anunciante escolhe venda ou doação.
2. Informa categoria, descrição, condição, quantidade, unidade, localização e fotos.
3. Em venda, informa preço do lote e, quando aplicável, preço por unidade.
4. Aceita os termos específicos de publicação e declara que o material é permitido.
5. O anúncio é publicado diretamente e passa a aparecer na busca.

### J04 — Encontrar e solicitar

1. Visitante ou usuário pesquisa um material e uma origem geográfica.
2. A plataforma retorna resultados com distância e posição aproximadas.
3. O usuário confirmado informa a quantidade desejada ou usa **Selecionar tudo**.
4. Uma conversa exclusiva é criada para aquela solicitação.

### J05 — Selecionar e reservar

1. O anunciante compara interessados segundo seus próprios critérios.
2. Seleciona um ou mais interessados sem exceder o saldo.
3. A quantidade é reservada de forma atômica.
4. Somente o destinatário selecionado recebe acesso ao endereço exato.
5. Os demais permanecem em espera enquanto ainda houver possibilidade de saldo.

### J06 — Concluir uma doação

1. As partes combinam retirada ou entrega fora da responsabilidade da plataforma.
2. A confirmação do anunciante conclui a movimentação do estoque.
3. O destinatário confirma o recebimento para liberar as avaliações.
4. A ausência de confirmação do destinatário não devolve material já entregue ao saldo.

### J07 — Concluir ou contestar uma venda

1. Pagamento e entrega são combinados diretamente pelas partes.
2. Anunciante e comprador podem confirmar o cumprimento.
3. A primeira confirmação inicia prazo de três dias.
4. Sem contestação, a plataforma pode concluir automaticamente ao final do prazo.
5. Contestação suspende a conclusão e encaminha o caso para análise.

### J08 — Denunciar e recorrer

1. Usuário informa motivo, circunstância e evidência.
2. O conteúdo é ocultado preventivamente quando a regra exigir.
3. Um agente autorizado analisa apenas o escopo vinculado ao caso.
4. A decisão é motivada, notificada e auditada.
5. A parte afetada pode recorrer até três vezes.

## Princípios do produto

1. **Privacidade por padrão:** endereço exato e dados pessoais não são públicos.
2. **Escolha do anunciante:** o anunciante decide com quem negociar, inclusive em doações.
3. **Transparência:** modalidade, quantidade, preço, condição, riscos e limites da plataforma devem estar claros.
4. **Segurança proporcional:** materiais perigosos são proibidos e casos críticos recebem prioridade.
5. **Responsabilidade entre as partes:** pagamento, inspeção e transporte são externos ao Ainda Serve.
6. **Acessibilidade:** os fluxos essenciais devem funcionar por teclado, leitores de tela e sem permissões opcionais.
7. **Rastreabilidade com minimização:** registrar o necessário para segurança e auditoria sem ampliar a exposição de dados.
8. **Evolução incremental:** funcionalidades e abstrações surgem de necessidades confirmadas.

## Glossário de domínio

| Termo | Definição |
|---|---|
| Conta | Identidade que atua como pessoa física ou organização |
| Usuário | Pessoa que autentica e pode representar uma conta |
| Unidade | Local ou divisão operacional de uma organização |
| Anúncio | Oferta única de um material, exclusivamente de venda ou doação |
| Saldo disponível | Quantidade que ainda pode ser solicitada e reservada |
| Saldo reservado | Quantidade comprometida com destinatário selecionado |
| Solicitação | Manifestação de interesse em uma quantidade do anúncio |
| Negociação | Fluxo iniciado pela seleção e reserva de uma solicitação |
| Conclusão | Registro de que a negociação cumpriu a confirmação exigida |
| Contestação | Suspensão motivada da conclusão para análise administrativa |
| Denúncia | Comunicação de possível violação relacionada a conteúdo ou comportamento |
| Evidência | Arquivo ou registro apresentado para sustentar denúncia, contestação ou recurso |
| Avaliação | Notas e comentário produzidos após negociação elegível |

## Escopo funcional do MVP

- Cadastro, autenticação, confirmação de e-mail, recuperação de senha e dois fatores conforme o papel.
- Perfis de pessoa física e organização.
- Membros, papéis, unidades e endereços de organizações.
- Catálogo administrável de categorias, atributos e unidades de medida.
- Anúncios de venda ou doação, com saldo divisível e até cinco fotos.
- Busca textual e geográfica, lista, mapa, filtros, favoritos e pesquisas salvas.
- Solicitações, lista de espera, seleção de interessados e reservas.
- Chat textual por solicitação.
- Confirmação de doação e venda, cancelamento e contestação.
- Avaliações bilaterais e reputação por papel, organização e unidade.
- Denúncias, bloqueios, moderação, recursos e auditoria.
- Central de notificações, e-mails transacionais e Web Push opcional.
- Administração, atendimento interno e indicadores.
- Aplicação responsiva e instalável como PWA.

## Limites de responsabilidade

O Ainda Serve:

- não recebe, guarda, divide ou devolve dinheiro;
- não contrata, rastreia ou garante transporte;
- não inspeciona presencialmente os materiais;
- não certifica segurança estrutural, origem ou adequação de uso;
- não garante comparecimento, entrega, recebimento ou qualidade;
- não substitui orientação técnica, jurídica ou ambiental;
- pode registrar, moderar e aplicar medidas internas com base em seus termos.

Esses limites não eliminam o dever da plataforma de proteger dados, aplicar suas próprias regras, preservar evidências autorizadas e responder a incidentes dentro do seu escopo.

## Fora do MVP

- Processamento de pagamentos, comissão, reembolso ou custódia de valores.
- Logística própria ou contratação de transporte pela plataforma.
- Verificação paga de identidade, biometria ou prova de vida.
- Anúncios patrocinados, publicidade externa e planos empresariais pagos.
- Aplicativos nativos para iOS ou Android.
- Conversão de materiais para uma única medida de impacto ambiental.
- Login social.
- Chat com imagens, documentos, áudio ou vídeo.
- Importação em massa de catálogo.

## Modelo de receita futuro

O MVP será gratuito. Permanecem no radar, sem autorização de implementação:

- destaque de anúncios, sempre identificado como **Patrocinado**;
- planos empresariais com mais anúncios, membros, relatórios, importação de catálogo e atendimento prioritário;
- preservação de resultados orgânicos relevantes mesmo com conteúdo patrocinado;
- ausência de publicidade externa, como banners de redes de anúncios;
- definição futura de preço, limites, elegibilidade e métricas comerciais em SPEC própria.

## Métricas de sucesso

### Métricas obrigatórias de integridade

| Métrica | Objetivo do MVP | Evidência esperada |
|---|---|---|
| Reserva acima do saldo | 0 ocorrências aceitas | Testes de concorrência e monitoramento |
| Exposição pública de endereço exato | 0 ocorrências | Testes de autorização e revisão de respostas |
| Ação administrativa crítica sem auditoria | 0 ocorrências | Trilha de auditoria consultável |
| Conta menor de 18 anos aceita conscientemente | 0 ocorrências | Validação de nascimento e testes de fronteira |
| Upload fora da política disponibilizado | 0 ocorrências conhecidas | Validação antes de acesso e testes negativos |

### Métricas de produto a acompanhar

| Métrica | Finalidade | Meta inicial |
|---|---|---|
| Anúncios publicados | Medir formação de oferta | A definir antes do lançamento |
| Solicitações por anúncio ativo | Medir encontro entre oferta e demanda | A definir após baseline |
| Negociações concluídas | Medir resultado principal | A definir após piloto |
| Tempo até primeira solicitação | Medir utilidade da descoberta | A definir após piloto |
| Taxa de cancelamento e contestação | Medir confiança e fricção | Monitorar; meta após baseline |
| Materiais reaproveitados por unidade original | Medir impacto sem conversão indevida | Exibir por categoria e unidade |
| Tempo de resolução de casos críticos | Medir capacidade operacional | Meta antes da abertura pública |

Não serão inventadas metas de aquisição ou impacto antes de existir baseline ou decisão do responsável pelo produto.

## Tecnologia confirmada

- Ruby e Ruby on Rails em versões estáveis e com suporte adequado no momento da implementação.
- Hotwire e Tailwind CSS.
- PostgreSQL para persistência, filtros, texto e dados geográficos iniciais.
- RSpec para testes unitários, de model, request e system.
- Docker e Docker Compose para desenvolvimento e testes locais, sem impor containers ao deploy de produção.
- Railway para deploy, PostgreSQL, workers e armazenamento com Railway Buckets.
- Solid Queue para processamento assíncrono inicial.
- Resend para e-mails transacionais.
- MapLibre GL JS, OpenFreeMap e Geoapify para mapas e geocodificação.
- Link externo para abrir rotas no Google Maps.

## Riscos de produto

| Risco | Probabilidade | Impacto | Resposta prevista |
|---|---|---|---|
| Oferta insuficiente em regiões fora do lançamento | Alta | Médio | Cadastro nacional com divulgação concentrada e medição regional |
| Exposição ou reidentificação da localização | Média | Crítico | Ponto deslocado, endereço restrito e testes negativos |
| Fraude, não comparecimento ou identidade falsa | Média | Alto | Validação local, histórico, reputação, denúncia e comunicação clara |
| Publicação de material perigoso | Média | Crítico | Termo obrigatório, política proibitiva, ocultação e fila prioritária |
| Reserva concorrente ou saldo negativo | Média | Crítico | Invariantes transacionais e teste integrado de concorrência |
| Sobrecarga de notificações | Alta | Médio | Central interna, agrupamento e preferências por canal |
| Limites de serviços gratuitos | Média | Médio | Monitoramento, degradação explícita e revisão por gatilho |
| Interpretação da mediação como garantia | Média | Alto | Termos claros e decisões administrativas limitadas à plataforma |

## Mapa de documentação

| Tema | Documento principal |
|---|---|
| Contas, perfis e organizações | [SPEC-01](specs/produto/spec-01-contas-perfis-organizacoes.md) |
| Anúncios e catálogo | [SPEC-02](specs/produto/spec-02-anuncios-catalogo-materiais.md) |
| Busca e localização | [SPEC-03](specs/produto/spec-03-busca-localizacao.md) |
| Solicitações e negociações | [SPEC-04](specs/produto/spec-04-solicitacoes-negociacoes.md) |
| Chat e notificações | [SPEC-05](specs/capacidades/spec-05-chat-notificacoes.md) |
| Reputação | [SPEC-06](specs/produto/spec-06-reputacao-avaliacoes.md) |
| Moderação | [SPEC-07](specs/confiabilidade/spec-07-moderacao-contestacoes.md) |
| Administração | [SPEC-08](specs/capacidades/spec-08-administracao-atendimento.md) |
| Arquitetura técnica | [SPEC-09](specs/arquitetura/spec-09-arquitetura-tecnica.md) |
| Qualidade, segurança e privacidade | [SPEC-10](specs/qualidade/spec-10-qualidade-seguranca-privacidade.md) |
| Deploy e operação | [SPEC-11](specs/infraestrutura/spec-11-deploy-operacao.md) |
| Modelo de domínio e contratos | [SPEC-12](specs/arquitetura/spec-12-modelo-dominio-contratos-dados.md) |
| Papéis e autorização | [SPEC-13](specs/arquitetura/spec-13-papeis-autorizacao.md) |
| Jornadas, interface e PWA | [SPEC-14](specs/produto/spec-14-jornadas-interface-pwa.md) |
| Observabilidade, auditoria e retenção | [SPEC-15](specs/confiabilidade/spec-15-observabilidade-auditoria-retencao.md) |
| CI/CD e engenharia de entrega | [SPEC-16](specs/infraestrutura/spec-16-devops-cicd.md) |
| Lançamento, indicadores e evolução comercial | [SPEC-17](specs/produto/spec-17-lancamento-indicadores-evolucao.md) |

## Questões abertas

| Questão | Classificação | Documento afetado |
|---|---|---|
| A confirmação do destinatário de doação expira ou permanece pendente? | Bloqueante para avaliação de doação | SPEC-04 e SPEC-06 |
| Qual é a janela de ocultação visual de mensagem? | Bloqueante para chat | SPEC-05 |
| Quais são os limites e a retenção do texto do chat? | Bloqueante para chat | SPEC-05 e SPEC-15 |
| Qual política final de retenção atende produto, segurança e LGPD? | Bloqueante para lançamento | SPEC-10 e SPEC-15 |
| Qual região, domínio, monitoramento e estratégia de homologação serão usados? | Bloqueante por fase | SPEC-11 e SPEC-16 |
| Quais metas quantitativas validarão o piloto? | Não bloqueante para fundação | SPEC-17 |

## Critérios para aprovação deste PRD

- [ ] Problema, público e limites de responsabilidade representam a intenção do produto.
- [ ] As oito jornadas essenciais cobrem o comportamento esperado do MVP.
- [ ] O escopo e os itens adiados estão separados sem ambiguidade.
- [ ] As métricas obrigatórias de integridade são aceitas.
- [ ] As questões abertas possuem classificação e documento responsável.
- [ ] O mapa de documentação cobre todo o escopo sem autorizar implementação.

## Documentos relacionados

- [Índice de especificações](specs/README.md)
- [Plano geral](plans/plan-geral.md)
- [Decisões arquiteturais](adr/)
- [Instruções para agentes](AGENT.md)
