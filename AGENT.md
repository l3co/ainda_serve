# Instruções para agentes

## Contexto do projeto

Ainda Serve é uma plataforma nacional para venda e doação de materiais e sobras de construção. O público inclui pessoas físicas, construtoras, lojas e organizações.

A tecnologia definida é Ruby on Rails com PostgreSQL. Não escolha versões, bibliotecas, serviços externos ou componentes adicionais sem uma especificação aprovada.

O ambiente padrão de desenvolvimento e de testes locais usa Docker e Docker Compose, conforme ADR-0011. Essa decisão não autoriza inferir Docker como requisito de produção no Railway.

## Regra principal: SDD

Todo código deve se originar de uma especificação. Não implemente, gere scaffolds, instale dependências, crie migrations ou altere código da aplicação sem que exista uma especificação revisada e explicitamente aprovada pelo responsável do projeto.

Antes de implementar:

1. Inspecione o estado atual do projeto.
2. Confirme que há uma especificação para a mudança.
3. Verifique se ela contém objetivo, escopo, requisitos e critérios de aceitação.
4. Apresente dúvidas, alternativas relevantes e impactos.
5. Aguarde aprovação explícita quando a especificação ainda não estiver aprovada.
6. Implemente apenas o escopo aprovado e valide-o contra os critérios de aceitação.

Documentação, análise e elaboração de especificações podem ser realizadas quando solicitadas. Elas não autorizam automaticamente a implementação descrita.

Uma SPEC em estado `Proposta` não autoriza código. Somente inicie implementação quando a SPEC afetada estiver explicitamente aprovada e a fase correspondente possuir tarefas revisadas.

## Princípios de modelagem

- Aplique SOLID de forma pragmática, sem criar camadas ou interfaces antecipadas.
- Siga *99 Bottles of OOP*: shameless green, concreto antes do abstrato, flocking rules, Rule of Three, código TRUE e composição antes de herança.
- Mantenha comportamento no objeto que possui o estado alterado.
- Extraia objetos Ruby para cálculos puros ou responsabilidades que não pertençam a um único registro.
- Não crie `app/services` como depósito de classes que apenas delegam para models.
- Não adicione state machine para poucos estados com transições simples; prefira enumerações e métodos com guardas explícitas.
- Não adicione Devise, Pundit, CanCanCan ou dependência equivalente antes de demonstrar que os recursos nativos e o código focado são insuficientes.
- Introduza uma abstração somente depois que casos reais mostrarem a variação; não crie uma interface genérica para uma única implementação.
- Prefira mudanças pequenas, cobertas por testes e fáceis de reverter.

## Idioma da documentação e do código

- Escreva em português do Brasil todos os ADRs, SPECs, planos, tarefas e demais documentos produzidos para o projeto.
- Preserve termos técnicos, identificadores, nomes de bibliotecas, comandos, trechos de código, mensagens de erro, contratos e exemplos no idioma e na forma original. Não traduza o conteúdo literal de exemplos.
- Escreva em inglês todo código-fonte, incluindo nomes de classes, módulos, métodos, funções, variáveis, constantes, arquivos de código e identificadores de banco de dados.
- Escreva em inglês todos os comentários inseridos no código-fonte.
- Textos exibidos ao usuário devem seguir o idioma definido pela respectiva especificação.

## Organização da documentação

Organize os artefatos de documentação conforme a finalidade:

```text
.
├── adr/
│   └── NNNN-titulo-em-portugues.md
├── plans/
│   └── plano-em-portugues.md
├── specs/
│   ├── arquitetura/
│   ├── capacidades/
│   ├── confiabilidade/
│   ├── infraestrutura/
│   ├── produto/
│   ├── qualidade/
│   └── README.md
└── tasks/
    └── tarefas-em-portugues.md
```

- Numere ADRs sequencialmente com quatro dígitos: `0001-titulo-em-portugues.md`.
- Numere SPECs quando aplicável e use nomes descritivos em português: `spec-01-titulo-em-portugues.md`.
- Agrupe SPECs pelo domínio documental correspondente, criando novas categorias somente após consulta e aprovação.
- Use nomes de arquivos em minúsculas, com palavras separadas por hífens e sem acentos.
- Crie diretórios somente quando houver um artefato aprovado para armazenar; não crie estruturas vazias preventivamente.

## Qualidade das especificações

Uma SPEC deve ser detalhada proporcionalmente ao risco e permitir que a implementação futura ocorra sem decisões silenciosas. Quando aplicável, registre:

- contexto, objetivo, escopo incluído e excluído;
- atores, pré-condições e pós-condições;
- contratos de entrada, saída e dados, preservando exemplos literais;
- regras de negócio com identificadores estáveis;
- estados, transições legais e ilegais;
- invariantes, concorrência e idempotência;
- fluxos felizes, alternativos, de erro e de borda;
- autorização, privacidade, auditoria e falhas externas relevantes;
- critérios de aceitação verificáveis;
- riscos, dependências, ADRs e questões abertas classificadas.

Não repita conteúdo apenas para preencher um template. Mantenha cada decisão na SPEC mais específica e use links relativos nas demais.

Uma questão bloqueante impede a aprovação da parte afetada. Uma questão não bloqueante pode permanecer aberta somente quando seu impacto e a fase limite estiverem explícitos.

Não crie `tasks/` enquanto as SPECs da fase correspondente estiverem em estado `Proposta`. Depois da aprovação, cada task deve citar requisitos e critérios atendidos, incluir testes na mesma unidade de trabalho e produzir um resultado verificável.

## Dúvidas e decisões

Sempre consulte o responsável antes de tomar uma decisão que não esteja coberta pelas instruções ou pela especificação aprovada.

Consulte especialmente antes de:

- ampliar ou reinterpretar o escopo;
- escolher versões ou adicionar dependências;
- definir arquitetura, modelo de dados ou integrações;
- executar operações destrutivas ou irreversíveis;
- alterar contratos públicos, autenticação, autorização ou tratamento de dados;
- realizar commits, pushes, deploys ou ações em serviços externos.

Não transforme uma solicitação de análise, planejamento ou revisão em autorização para implementar.

## Skills e guardrails

As skills do projeto estão em `.codex/skills`. Ao usar uma skill, leia seu `SKILL.md` e somente as referências necessárias para a tarefa.

Os guardrails compartilhados estão em `.codex/skills/shared/guardrails.md`. Os guardrails específicos de cada tecnologia ficam na pasta `references` da skill correspondente e complementam os guardrails compartilhados.

Para tarefas Ruby ou Rails, use `.codex/skills/ruby-development`.

Para planejamento incremental, use `.codex/skills/incremental-planning`.

Antes de um comando potencialmente destrutivo ou de uma ação Git protegida, use `.codex/guardrails/bash-guard.sh`. Um retorno de código `10` exige confirmação explícita do responsável antes de prosseguir.

## Preservação do repositório

- Faça apenas alterações diretamente relacionadas à solicitação aprovada.
- Preserve mudanças existentes que não pertençam à tarefa.
- Prefira alterações pequenas, coesas e reversíveis.
- Não exclua arquivos nem reescreva histórico sem autorização explícita.
- Não exponha nem versione segredos.
- Atualize o `README.md` na mesma mudança sempre que uma funcionalidade ou biblioteca for adicionada, removida ou alterada, mantendo a documentação coerente com o estado real do projeto.
- Não considere concluída uma mudança de funcionalidade ou biblioteca enquanto a atualização correspondente do `README.md` estiver pendente.
- Informe claramente o que foi alterado e como foi validado.
