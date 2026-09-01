# Ainda Serve

**O fim da obra não é o fim do material.**

Ainda Serve será uma plataforma nacional para pessoas, construtoras, lojas e organizações anunciarem, venderem ou doarem materiais e sobras de construção. A proposta é reduzir desperdícios, ampliar o acesso a materiais e estimular a economia circular na construção civil.

## Estado do projeto

O projeto está na fase de descoberta e especificação. A aplicação ainda não foi criada.

Nenhuma funcionalidade deve ser implementada antes de possuir uma especificação revisada e aprovada.

O conjunto documental atual contém um PRD, onze ADRs, dezessete SPECs e um plano geral detalhado. Todos os artefatos executáveis permanecem no estado **Proposta**; o diretório `tasks/` ainda não existe por decisão do processo SDD.

## Tecnologia definida

- Ruby e Ruby on Rails em versões estáveis e com suporte adequado no início da implementação
- Hotwire e Tailwind CSS
- PostgreSQL para persistência, busca e dados geográficos iniciais
- RSpec para testes unitários, de model, request e system
- Docker e Docker Compose para desenvolvimento e testes locais; não são requisito de produção por esta decisão
- Railway para deploy, PostgreSQL, workers e Railway Buckets
- Solid Queue para processamento assíncrono inicial
- Resend para e-mails transacionais
- MapLibre GL JS, OpenFreeMap e Geoapify para mapas e geocodificação
- Link externo para abertura de rotas no Google Maps

As versões exatas e dependências serão confirmadas nas respectivas especificações antes da implementação.

## Desenvolvimento orientado a especificações

O projeto adota **Specification-Driven Development (SDD)**. Toda alteração de código deve ter origem em uma especificação prévia.

O fluxo esperado é:

1. Entender o problema, o objetivo e as restrições.
2. Registrar uma especificação com requisitos, critérios de aceitação e decisões relevantes.
3. Apresentar dúvidas, alternativas e impactos ao responsável pelo projeto.
4. Obter aprovação explícita da especificação.
5. Planejar e implementar somente o escopo aprovado.
6. Validar o resultado contra os critérios de aceitação.

Quando um requisito estiver ambíguo ou uma decisão puder alterar produto, arquitetura, dados, segurança, dependências ou escopo, o trabalho deve ser interrompido para consulta antes da implementação.

### Manutenção deste documento

O `README.md` deve ser atualizado na mesma mudança sempre que uma funcionalidade ou biblioteca for adicionada, removida ou alterada. A documentação deve representar o estado real do projeto, e a mudança não será considerada concluída enquanto essa atualização estiver pendente.

### Idioma e organização da documentação

ADRs, SPECs, planos, tarefas e demais documentos do projeto devem ser escritos em português do Brasil. Termos técnicos, identificadores, nomes de bibliotecas, comandos, mensagens de erro e códigos usados como exemplos devem permanecer na forma original, sem tradução.

O código-fonte, seus identificadores e os comentários inseridos no código devem ser escritos em inglês.

A documentação será organizada por finalidade:

```text
adr/                  Decisões arquiteturais numeradas
plans/                Planos de execução
specs/arquitetura/    Arquitetura e contratos estruturais
specs/capacidades/    Capacidades funcionais e técnicas
specs/confiabilidade/ Resiliência, monitoramento e observabilidade
specs/infraestrutura/ Ambiente, entrega e operação
specs/produto/        Requisitos e experiências do produto
specs/qualidade/      Testes e critérios de qualidade
tasks/                Decomposição do trabalho aprovado
```

Os nomes dos arquivos de documentação devem estar em português, em minúsculas, sem acentos e separados por hífens. ADRs usam quatro dígitos, como `0001-titulo-em-portugues.md`; SPECs usam o padrão `spec-01-titulo-em-portugues.md` quando numeradas. Os diretórios serão criados somente quando houver documentos aprovados para armazenar.

## Diretrizes para agentes

As instruções operacionais do projeto estão em [`AGENT.md`](AGENT.md). As skills e os guardrails locais ficam em [`.codex/`](.codex/).

O verificador de comandos sensíveis pode ser executado assim:

```sh
.codex/guardrails/bash-guard.sh 'comando a verificar'
```

Um retorno com código `10` significa que o comando exige confirmação explícita antes da execução.

## Documentação do produto

- [`visao-geral.md`](visao-geral.md): PRD com problema, atores, jornadas, limites, métricas e riscos.
- [`specs/README.md`](specs/README.md): índice das dezessete especificações, convenções e fluxo de aprovação.
- [`plans/plan-geral.md`](plans/plan-geral.md): arquitetura, fases verticais, gates, dependências, riscos e rollout.
- [`adr/`](adr/): decisões arquiteturais aceitas.

As SPECs atuais estão em estado **Proposta**. Nenhuma implementação está autorizada até que a especificação da fase correspondente seja revisada e explicitamente aprovada.

Ordem de leitura recomendada:

1. PRD e jornadas em [`visao-geral.md`](visao-geral.md).
2. Modelo e invariantes na [SPEC-12](specs/arquitetura/spec-12-modelo-dominio-contratos-dados.md).
3. Matriz de acesso na [SPEC-13](specs/arquitetura/spec-13-papeis-autorizacao.md).
4. SPECs funcionais de 01 a 08.
5. Experiência na [SPEC-14](specs/produto/spec-14-jornadas-interface-pwa.md).
6. Arquitetura, qualidade, operação e lançamento nas SPECs 09 a 17.
7. Sequência de entrega em [`plans/plan-geral.md`](plans/plan-geral.md).

Cada SPEC detalha, conforme seu domínio, contratos, pré-condições, estados, falhas, privacidade, critérios de aceitação e dependências. Os nomes de classes e estruturas apresentados nesses documentos são conceituais e não autorizam geração de código ou migrations.

## Escopo inicial do produto

- Público: pessoas físicas, construtoras, lojas e ONGs.
- Abrangência: todo o Brasil.
- Itens: materiais e sobras de construção.
- Operações: venda e doação.
- Pagamentos e logística: combinados diretamente entre as partes; a plataforma não processa valores nem garante entrega.
- MVP: gratuito para pessoas e organizações.
- Futuro: anúncios patrocinados e planos empresariais, sem publicidade externa e sujeitos a especificação própria.
