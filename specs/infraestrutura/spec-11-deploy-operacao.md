# SPEC-11 — Deploy e operação

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** SPEC-09 e SPEC-10
**ADRs:** 0005, 0006, 0007, 0009, 0011

## Estado

Proposta.

## Objetivo

Definir topologia inicial no Railway, ambientes, segredos, banco, worker, arquivos, jobs programados e preparação do lançamento.

## Escopo

### Incluído

- Serviço web, worker, PostgreSQL e Railway Buckets.
- Variáveis, migrations, seed inicial e integração com serviços externos.
- Ambientes de desenvolvimento, teste e produção.
- Verificações de deploy, logs e recuperação básica.

### Excluído

- Deploy efetivo nesta etapa documental.
- Alta disponibilidade multi-região no MVP.
- Kubernetes, Terraform ou outra orquestração adicional sem necessidade.

## Topologia proposta

- **Web:** aplicação Rails e endpoints Hotwire/PWA.
- **Worker:** mesmo código, executando Solid Queue.
- **PostgreSQL:** persistência principal e fila conforme suporte da versão escolhida.
- **Railway Bucket:** imagens, evidências e exportações.
- **Cron/Scheduler:** tarefas de expiração, resumos e manutenção, conforme mecanismo confirmado na implementação.
- **Resend:** e-mail transacional.
- **Geoapify:** autocomplete e geocodificação.
- **OpenFreeMap:** mapa-base público consumido pelo navegador.

```text
Internet ──> Railway Web ──> PostgreSQL <── Railway Worker
                  │                 │
                  ├── Railway Buckets
                  ├── Resend
                  └── Geoapify

Browser ──> OpenFreeMap/MapLibre e link externo do Google Maps
```

Somente o processo web expõe porta pública. Worker, banco e storage usam o acesso mais restrito disponível.

## Requisitos operacionais

- **OPS-001:** Segredos e credenciais devem usar variáveis protegidas do Railway ou mecanismo seguro equivalente.
- **OPS-002:** Nenhum segredo pode ser versionado.
- **OPS-003:** Serviços web e worker devem compartilhar configuração necessária sem expor porta pública do worker.
- **OPS-004:** Conexões internas devem preferir rede privada do Railway.
- **OPS-005:** Migrations devem executar em etapa controlada antes da nova versão atender tráfego.
- **OPS-006:** Mudanças destrutivas de schema devem ser separadas da versão que deixa de usar o dado.
- **OPS-007:** Seed inicial deve ser idempotente e usar `INITIAL_ADMIN_EMAIL` ou nome equivalente aprovado.
- **OPS-008:** Seed não pode conter senha padrão.
- **OPS-009:** Primeiro administrador recebe link seguro para definir senha.
- **OPS-010:** Railway Bucket deve ser privado e entregar arquivos por acesso autorizado.
- **OPS-011:** Chaves públicas de navegador devem possuir restrições compatíveis; segredos de servidor não podem chegar ao cliente.
- **OPS-012:** Limites e consumo de Resend e Geoapify devem ser monitorados.

## Ambientes

- Desenvolvimento local padronizado com Docker e Docker Compose, usando serviços isolados e dados fictícios.
- Testes locais executados no ambiente Docker, isolados e sem chamadas externas reais.
- Produção no Railway.
- Ambiente de homologação é recomendado antes do lançamento, condicionado ao custo aprovado.

Docker não é requisito de produção por esta SPEC. A estratégia de build e runtime no Railway deverá ser confirmada separadamente antes do primeiro deploy.

## Configuração e segredos

Cada variável deverá ser documentada com finalidade, obrigatoriedade, ambiente e exemplo seguro em `.env.example` quando a aplicação existir. O documento não conterá valores reais.

Categorias previstas:

- conexão e pools do PostgreSQL;
- chave e domínio do Resend;
- chave e limites do Geoapify;
- credenciais e endpoint do Railway Buckets;
- VAPID keys para Web Push;
- host, protocolo e domínio da aplicação;
- e-mail do administrador inicial;
- configuração de fila, retenção e observabilidade.

## Saúde e prontidão

| Verificação | Health | Readiness | Observação |
|---|---:|---:|---|
| Processo Rails responde | Sim | Sim | Sem consultar serviço externo caro |
| PostgreSQL acessível | Sim | Sim | Falha impede receber tráfego mutável |
| Migrations compatíveis | Não | Sim | Revisão implantada deve reconhecer schema |
| Worker ativo | Separado | Separado | Web pode sinalizar degradação operacional |
| Resend/Geoapify | Não | Não | Monitorados por uso, sem bloquear health |
| Bucket | Não | Conforme fluxo | Falha degrada uploads, não toda navegação |

## Jobs e agendamentos

- Envio de e-mail e push.
- Expiração de anúncios e negociações.
- Resumos diários de pesquisas salvas.
- Geração de exportações e relatórios.
- Limpeza conforme política de retenção.

Todos os jobs devem ser idempotentes, tolerantes a retry e observáveis.

## Deploy

Cada deploy deve, no mínimo:

1. Instalar dependências conforme lockfile.
2. Executar verificações de qualidade definidas pelo projeto.
3. Executar testes proporcionais à mudança.
4. Preparar o banco com comando configurado e verificado pelo projeto.
5. Implantar web e worker com a mesma revisão.
6. Verificar saúde, migrations, processamento de jobs e acesso a arquivos.

Os comandos exatos não serão definidos antes da criação da aplicação e da confirmação das versões.

## Backup e recuperação

- Definir política de backup do PostgreSQL antes de produção.
- Definir retenção e recuperação de objetos críticos.
- Realizar teste de restauração antes do lançamento público.
- Documentar procedimento de rollback de aplicação e interrupção de workers.

O teste de restauração deve registrar data, origem do backup, destino isolado, duração, resultado de integridade e responsável. Um backup nunca restaurado não é evidência suficiente de recuperação.

## Observabilidade mínima

- Logs estruturados sem dados sensíveis.
- Identificação de request, job e integração quando aplicável.
- Monitoramento de falhas de jobs e integrações.
- Alertas para indisponibilidade, erros elevados e aproximação de limites externos.
- Indicadores operacionais separados dos indicadores de produto.

## Critérios de aceitação

- [ ] Web e worker executam a mesma revisão e acessam o mesmo banco.
- [ ] Worker não possui endpoint público desnecessário.
- [ ] Readiness impede tráfego quando banco ou schema estão incompatíveis.
- [ ] Seed repetido não duplica nem redefine administrador.
- [ ] Arquivos privados não são acessíveis por URL permanente pública.
- [ ] Falha de Resend ou Geoapify fica observável e não expõe credencial.
- [ ] Existe procedimento testado de backup e restauração antes do lançamento.
- [ ] Smoke test verifica web, worker, banco, storage e logs.
- [ ] Rollback declara tratamento de migrations e jobs incompatíveis.
- [ ] Termos de Uso e Política de Privacidade receberam revisão jurídica antes da abertura pública.

## Questões em aberto

- Região exata dos serviços no Railway.
- Política e custo do ambiente de homologação.
- Ferramenta de monitoramento e rastreamento de erros.
- Política final de backup, retenção e restauração.
- Domínio e configuração de e-mail do produto.
- Estratégia de build e runtime de produção oferecida pelo Railway, sem assumir Docker por antecipação.

## Dependências

- [ADR-0005 — Railway](../../adr/0005-railway-como-plataforma.md)
- [ADR-0006 — Railway Buckets](../../adr/0006-railway-buckets-armazenamento.md)
- [ADR-0007 — Solid Queue](../../adr/0007-solid-queue-processamento-assincrono.md)
- [ADR-0009 — Resend](../../adr/0009-resend-email-transacional.md)
- [ADR-0011 — Docker para desenvolvimento e testes locais](../../adr/0011-docker-para-desenvolvimento-testes-locais.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](../confiabilidade/spec-15-observabilidade-auditoria-retencao.md)
- [SPEC-16 — DevOps e CI/CD](spec-16-devops-cicd.md)
