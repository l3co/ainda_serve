# ADR-0011 — Docker para desenvolvimento e testes locais

## Estado

Aceito em 1º de setembro de 2026.

## Contexto

O projeto precisa de um ambiente local reproduzível para Ruby, Rails, PostgreSQL e execução dos testes. Instalar e manter essas dependências diretamente em cada máquina aumenta a possibilidade de divergência de versões e torna a preparação inicial mais difícil de reproduzir.

O deploy de produção já foi direcionado ao Railway, mas a estratégia exata de build e execução em produção não depende desta decisão.

## Decisão

Usar Docker e Docker Compose para o ambiente padrão de desenvolvimento e para a execução local dos testes.

O ambiente local deverá, no mínimo, isolar a aplicação e o PostgreSQL. Versões de imagens, nomes dos serviços, volumes, portas, comandos e estratégia de cache serão definidos na SPEC da fundação depois da escolha das versões de Ruby e Rails.

Docker não é, por esta decisão, um requisito para o deploy de produção no Railway. A forma de build e execução em produção continuará definida pela SPEC de deploy e pelas capacidades confirmadas do Railway.

## Consequências

### Positivas

- Ambiente de desenvolvimento mais reproduzível.
- Menor dependência de Ruby, Rails e PostgreSQL instalados diretamente no host.
- Testes locais executados com versões compatíveis com as definidas pelo projeto.
- Preparação inicial e diagnóstico do ambiente podem usar os mesmos comandos documentados.

### Negativas

- Docker passa a ser requisito da máquina de desenvolvimento.
- Montagem de volumes e desempenho de arquivos podem variar entre sistemas operacionais.
- O ambiente local em container pode divergir do runtime de produção se essa diferença não for validada.
- Comandos de desenvolvimento precisam considerar ownership, sinais e encerramento correto dos processos.

### Neutras

- A pipeline de CI pode executar os testes em container ou por outro mecanismo equivalente, desde que use as mesmas versões e cumpra a SPEC-16.
- Serviços externos permanecem simulados nos testes automatizados.

## Alternativas consideradas

- Instalar Ruby, Rails e PostgreSQL diretamente no host: rejeitada como fluxo padrão por aumentar variação entre máquinas; pode existir apenas como fluxo não suportado oficialmente.
- Exigir Docker também em produção: rejeitada nesta decisão porque o usuário limitou o escopo a desenvolvimento e testes locais.
- Usar uma máquina virtual completa: rejeitada por maior peso e complexidade para o escopo inicial.

## Restrições

- Não criar `Dockerfile`, `compose.yaml`, scripts ou imagens antes da aprovação da SPEC e das tasks da Fase 02.
- Não assumir que uma validação local em Docker prova compatibilidade com o Railway.
- Não incluir segredos reais em imagem, arquivo Compose ou exemplo versionado.
- Testes devem continuar sem chamadas externas reais.

## Gatilhos para revisão

- Limitação relevante de desempenho ou compatibilidade no sistema operacional usado pela equipe.
- Divergência recorrente entre ambiente local e Railway.
- Railway exigir uma estratégia de container de produção que justifique unificação posterior.
- CI não conseguir reproduzir as versões e dependências do ambiente local.

## Referências

- [SPEC-10 — Qualidade, segurança e privacidade](../specs/qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-11 — Deploy e operação](../specs/infraestrutura/spec-11-deploy-operacao.md)
- [SPEC-16 — DevOps, CI/CD e engenharia de entrega](../specs/infraestrutura/spec-16-devops-cicd.md)
- [Plano geral](../plans/plan-geral.md)
