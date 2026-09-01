# SPEC-16 — DevOps, CI/CD e engenharia de entrega

**Versão:** 0.1
**Estado:** Proposta
**Depende de:** SPEC-09, SPEC-10, SPEC-11 e ADR-0010
**ADRs:** 0005, 0007, 0010, 0011

## Contexto

O MVP tratará identidade, documentos, endereço, conversas e decisões administrativas. A entrega precisa detectar regressões antes do deploy, aplicar migrations de forma controlada e permitir recuperação sem depender de procedimentos improvisados.

## Objetivos

- Definir gates mínimos de qualidade para cada mudança.
- Separar validação de código, build, release e deploy.
- Tornar migrations, seeds e workers verificáveis.
- Preparar rollback e smoke test antes da abertura pública.

## Fora do escopo

- Executar deploy nesta etapa documental.
- Escolher o provedor de repositório ou CI sem confirmação.
- Introduzir Kubernetes, Terraform ou múltiplas regiões.
- Exigir cobertura percentual isolada como definição de qualidade.

## Fluxo de entrega proposto

```text
SPEC aprovada → task revisada → mudança + testes → revisão → CI verde
→ build imutável → migration controlada → deploy web/worker
→ smoke test → observação → conclusão ou rollback
```

Desenvolvimento e testes locais usam Docker e Docker Compose. A pipeline de CI deverá reproduzir as versões e os contratos desse ambiente, mas não fica obrigada por esta SPEC a executar dentro de container.

## Gates de integração contínua

| Gate | Objetivo | Falha bloqueia integração? |
|---|---|---:|
| Formatação e lint | Detectar inconsistência e erros estáticos configurados | Sim |
| Testes unitários e de model | Provar regras e invariantes | Sim |
| Request specs | Provar autenticação, autorização e contratos HTTP | Sim |
| System specs selecionadas | Provar fluxos com Hotwire/JavaScript | Sim para fluxo afetado |
| Segurança de dependências | Detectar vulnerabilidades conhecidas | Sim conforme severidade aprovada |
| Análise de segredos | Impedir credencial versionada | Sim |
| Integridade documental | Validar links, IDs e atualização necessária do README | Sim |
| Build de produção | Provar que o artefato executável pode ser criado | Sim |

## Regras da pipeline

- **CIC-001:** Testes automatizados não acessam serviços externos reais.
- **CIC-002:** A mesma revisão de código gera os processos web e worker.
- **CIC-003:** Dependências são instaladas a partir de lockfile versionado.
- **CIC-004:** Segredos não são necessários para gates que podem usar fakes.
- **CIC-005:** Falha de qualquer gate obrigatório impede merge e deploy automático.
- **CIC-006:** Artefato aprovado não é reconstruído com conteúdo diferente entre validação e deploy.
- **CIC-007:** Toda mudança de funcionalidade ou biblioteca atualiza o README na mesma entrega.
- **CIC-008:** Toda correção de regressão inclui teste que reproduz o defeito quando viável.
- **CIC-009:** O fluxo local documentado executa aplicação e testes por Docker Compose, sem exigir Ruby ou PostgreSQL instalados diretamente no host.
- **CIC-010:** A validação local em Docker não substitui smoke test no runtime real do Railway.

## Estratégia de testes na entrega

| Nível | Frequência | Ambiente | Integrações |
|---|---|---|---|
| Unit/model/request | Toda mudança | Teste isolado | Fakes ou stubs |
| System essencial | Toda mudança que afeta jornada | Navegador controlado | Serviços simulados |
| Concorrência | Mudanças de estoque/reserva | Banco real de teste | Sem rede externa |
| Contrato externo | Agendado ou antes de release | Homologação controlada | Credenciais próprias |
| Smoke test | Todo deploy | Ambiente implantado | Verificação mínima real |
| Restauração | Antes do lançamento e periodicamente | Ambiente seguro | Backup não destrutivo |

## Migrations e compatibilidade

1. Mudanças de schema começam aditivas quando existir dado em produção.
2. A aplicação nova não deve depender da remoção imediata de coluna antiga.
3. Backfill grande, se necessário, roda separadamente e de forma retomável.
4. Remoção destrutiva ocorre somente após estabilização e confirmação de não uso.
5. Toda migration é testada a partir do estado anterior suportado.
6. O procedimento de rollback declara se a migration é reversível ou exige correção progressiva.

## Estratégia de release

- Releases devem possuir identificador imutável e relação com o commit revisado.
- Migrations executam em etapa controlada antes de receber tráfego incompatível.
- Web e worker são atualizados de forma coordenada.
- Jobs antigos e novos devem coexistir durante janela de atualização quando necessário.
- Flags de funcionalidade serão usadas somente quando reduzirem risco real de rollout.

## Smoke test mínimo

Após deploy, verificar sem alterar dados reais de usuários:

1. página pública e health check respondem;
2. conexão com PostgreSQL está saudável;
3. migrations esperadas foram aplicadas;
4. worker processa um job seguro e identificável;
5. storage privado aceita ciclo controlado de escrita e leitura;
6. integração de e-mail está configurada sem enviar para endereço real indevido;
7. logs e correlação aparecem sem segredos.

## Rollback e recuperação

**Condição de parada:** falha de autenticação, reserva, migrations, acesso a arquivo, fila ou exposição de dados após release.

**Recuperação esperada:**

1. interromper expansão da nova revisão;
2. impedir execução de jobs incompatíveis;
3. restaurar a revisão anterior quando o schema continuar compatível;
4. aplicar correção progressiva quando houver escrita já persistida;
5. validar integridade de estoque e autorizações;
6. registrar incidente e sensor preventivo correspondente.

## Ambientes

| Ambiente | Finalidade | Dados | Serviços externos |
|---|---|---|---|
| Desenvolvimento | Feedback local em Docker Compose | Fictícios | Fakes por padrão |
| Teste local | Automação determinística em Docker | Efêmeros | Proibidos |
| CI | Gates automatizados com versões equivalentes | Efêmeros | Proibidos, salvo contrato controlado separado |
| Homologação | Verificar release e integrações | Sintéticos | Contas controladas |
| Produção | Operação pública | Reais | Configuração protegida |

Homologação é recomendada, mas sua permanência depende de custo aprovado. Se não existir ambiente permanente, o plano deve definir alternativa temporária antes do lançamento.

## Critérios de aceitação

- [ ] Pipeline impede integração quando um gate obrigatório falha.
- [ ] Testes automatizados não dependem de rede externa.
- [ ] Build aprovado é o mesmo promovido para deploy.
- [ ] Migrations possuem estratégia de compatibilidade e recuperação.
- [ ] Web e worker executam a mesma revisão.
- [ ] Smoke test cobre banco, worker, storage e observabilidade.
- [ ] Um teste de restauração ocorre antes da abertura pública.
- [ ] README acompanha toda mudança de funcionalidade ou biblioteca.

## Riscos e questões abertas

- **Risco:** pipeline longa incentivar atalhos. Mitigação: separar gates rápidos e system specs proporcionais ao risco.
- **Risco:** migration incompatível com worker antigo. Mitigação: expansão e contração, coexistência e deploy coordenado.
- **Aberto:** confirmar GitHub Actions ou outro mecanismo de CI/CD.
- **Aberto:** definir ambiente de homologação e orçamento.
- **Aberto:** escolher ferramentas de lint, auditoria e análise de segredos após versões de Ruby e Rails.

## Dependências

- [SPEC-09 — Arquitetura técnica](../arquitetura/spec-09-arquitetura-tecnica.md)
- [SPEC-10 — Qualidade, segurança e privacidade](../qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-11 — Deploy e operação](spec-11-deploy-operacao.md)
- [ADR-0010 — RSpec](../../adr/0010-rspec-estrategia-testes.md)
- [ADR-0011 — Docker para desenvolvimento e testes locais](../../adr/0011-docker-para-desenvolvimento-testes-locais.md)
