# SPEC-15 — Observabilidade, auditoria e retenção

**Versão:** 0.1
**Estado:** Proposta
**Depende de:** SPEC-07 a SPEC-13
**ADRs:** 0005, 0007, 0009

## Contexto

Negociações, ações administrativas e integrações assíncronas precisam ser investigáveis sem transformar logs em cópia indiscriminada de dados pessoais. Esta SPEC diferencia telemetria operacional, histórico de domínio, auditoria de segurança e retenção legal.

## Objetivos

- Permitir diagnóstico de requests, jobs e integrações.
- Preservar autoria e justificativa de ações sensíveis.
- Detectar falhas que ameacem estoque, privacidade ou comunicação.
- Definir classes de retenção antes do lançamento, com prazos finais sujeitos a revisão.

## Fora do escopo

- Escolher uma plataforma paga de observabilidade nesta etapa.
- Registrar conteúdo integral de requests ou mensagens em logs.
- Definir prazo legal definitivo sem revisão adequada.
- Expor trilha administrativa diretamente ao público.

## Classes de registro

| Classe | Finalidade | Exemplos | Pode conter conteúdo do usuário? |
|---|---|---|---:|
| Log operacional | Diagnóstico técnico de curta duração | erro, duração, status, integração | Não, salvo identificador seguro |
| Evento de domínio | Explicar evolução funcional | reserva criada, anúncio pausado, confirmação | Somente metadados necessários |
| Auditoria | Provar ação sensível | acesso a evidência, alteração de papel, sanção | Motivo e mudança controlada |
| Evidência de caso | Sustentar denúncia ou contestação | arquivo, mensagem vinculada, declaração | Sim, acesso altamente restrito |
| Métrica agregada | Medir saúde e produto | contagens, taxas, latência | Não identificável |

## Correlação

- **OBS-001:** Cada request recebe identificador de correlação não derivado de dado pessoal.
- **OBS-002:** Jobs propagam identificador do evento de origem quando existir.
- **OBS-003:** Chamadas a Resend, Geoapify, storage e Web Push registram destino lógico, duração, resultado e tentativa.
- **OBS-004:** A interface de suporte pode localizar um fluxo por identificador sem expor stack trace ao usuário.
- **OBS-005:** Uma negociação possui linha do tempo de eventos de domínio independente do log operacional.

## Campos mínimos de log

| Campo | Obrigatório quando | Observação |
|---|---|---|
| `timestamp` | sempre | Horário consistente e ordenável |
| `severity` | sempre | Nível padronizado |
| `event_name` | sempre | Nome estável em inglês no código |
| `request_id` ou `job_id` | request ou job | Correlação técnica |
| `actor_id` | ação autenticada | Identificador interno, não e-mail/documento |
| `account_id` | ação em contexto de conta | Permite distinguir pessoa e organização |
| `record_type` e `record_id` | ação sobre recurso | Sem serializar o recurso completo |
| `result` | integração ou ação | sucesso, falha ou rejeição de domínio |
| `duration_ms` | operação medida | Número, não texto livre |
| `error_class` | falha | Sem segredo ou conteúdo sensível |

## Eventos críticos obrigatórios

| Evento | Registro de domínio | Auditoria | Alerta potencial |
|---|---:|---:|---:|
| Reserva criada/cancelada/concluída | Sim | Não por padrão | Saldo inválido |
| Contestação aberta/encerrada | Sim | Sim | Prazo vencido ou volume anormal |
| Acesso administrativo a conversa/evidência | Não | Sim | Acesso fora de caso |
| Papel privilegiado alterado | Sim | Sim | Sempre notificar segurança |
| Documento alterado | Sim | Sim | Sempre notificar titular |
| Conta suspensa/banida/restaurada | Sim | Sim | Sempre notificar segurança |
| Upload recusado por segurança | Não | Sim quando associado a caso | Volume anormal |
| Falha repetida de job | Não | Não | Sim |
| Falha de geocodificação ou e-mail | Não | Não | Conforme limiar |

## Proteção e minimização

- **OBS-006:** Senha, token, cookie, credencial, CPF, CNPJ completo e endereço exato nunca aparecem em log operacional.
- **OBS-007:** Texto de chat não é copiado para logs; investigação usa o registro autorizado da conversa.
- **OBS-008:** Parâmetros de busca potencialmente pessoais são reduzidos ou mascarados antes do log.
- **OBS-009:** Evidências permanecem privadas e são entregues por acesso temporário e autorizado.
- **OBS-010:** Exportação de auditoria preserva controle de acesso e registra quem exportou.

## Retenção proposta por classe

Os prazos abaixo não estão aprovados; são categorias a serem preenchidas após decisão de produto, segurança e revisão jurídica.

| Classe | Gatilho inicial | Prazo | Destino ao expirar |
|---|---|---|---|
| Logs operacionais | criação do log | A definir | exclusão ou agregação irreversível |
| Notificações visuais | entrega | A definir | exclusão da cópia visual |
| Chat sem caso aberto | encerramento da negociação | A definir | exclusão ou anonimização conforme política |
| Evidência com caso | encerramento definitivo do caso | A definir | exclusão segura conforme obrigação aplicável |
| Auditoria de ação crítica | data da ação | A definir | preservação ou anonimização conforme política |
| Exportações geradas | disponibilização | Curto e definido | exclusão do arquivo; pedido permanece registrado |
| Conta em arrependimento | solicitação elegível | 30 dias | executar exclusão/anonimização aprovada |

## Alertas mínimos antes do lançamento

- erro elevado no serviço web;
- jobs falhando repetidamente ou fila sem processamento;
- banco ou storage indisponível;
- aproximação de limites de Resend e Geoapify;
- falha em backup ou restauração programada;
- violação de invariante de estoque;
- aumento anormal de denúncias críticas;
- ação privilegiada fora do padrão esperado.

Os limiares serão definidos após baseline em homologação; ausência de baseline não justifica ausência de alerta para falha total.

## Consulta e auditoria

1. Um agente autorizado abre um caso ou recurso permitido.
2. A plataforma apresenta linha do tempo funcional separada de detalhes técnicos.
3. Acesso a conteúdo restrito exige motivo e produz novo evento de auditoria.
4. Exportação ou cópia de evidência exige capacidade específica.
5. Correção de registro não apaga o anterior; registra retificação vinculada.

## Critérios de aceitação

- [ ] Requests, jobs e integrações podem ser correlacionados sem usar dado pessoal como chave.
- [ ] Logs não contêm os dados proibidos por OBS-006 e OBS-007.
- [ ] Toda ação crítica da matriz gera auditoria com ator, motivo, alvo e data.
- [ ] Reserva e negociação possuem linha do tempo funcional consultável.
- [ ] Falha de e-mail, mapa ou push fica observável sem desfazer a transação concluída.
- [ ] Retenção possui política aprovada antes da abertura pública.
- [ ] Backup, restauração e alertas produzem evidência operacional.
- [ ] Um administrador não pode apagar silenciosamente sua própria auditoria.

## Riscos e questões abertas

- **Risco:** excesso de logs expor dados pessoais. Mitigação: allowlist de campos e testes de redaction.
- **Risco:** pouca retenção prejudicar investigação; retenção excessiva ampliar impacto. Mitigação: classificar por finalidade e revisar prazo por classe.
- **Aberto bloqueante:** definir todos os prazos de retenção.
- **Aberto:** escolher ferramenta de monitoramento e rastreamento de erros.
- **Aberto:** definir limiares após medições de homologação.

## Dependências

- [SPEC-07 — Moderação, contestações e recursos](spec-07-moderacao-contestacoes.md)
- [SPEC-10 — Qualidade, segurança e privacidade](../qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-11 — Deploy e operação](../infraestrutura/spec-11-deploy-operacao.md)
- [SPEC-12 — Modelo de domínio e contratos](../arquitetura/spec-12-modelo-dominio-contratos-dados.md)
