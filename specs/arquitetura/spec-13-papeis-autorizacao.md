# SPEC-13 — Papéis, escopos e autorização

**Versão:** 0.1
**Estado:** Proposta
**Depende de:** SPEC-01, SPEC-07, SPEC-08 e SPEC-12
**ADRs:** 0002, 0008

## Contexto

O produto combina conta pessoal, representação de organização e papéis internos da plataforma. A autorização não pode depender apenas de autenticação nem de esconder botões: cada ação precisa considerar ator, conta representada, vínculo, papel, propriedade, atribuição, estado do recurso e finalidade do acesso.

## Objetivos

- Consolidar papéis e escopos em uma matriz verificável.
- Definir regras de negação por padrão e acesso mínimo.
- Impedir que conhecimento de identificador conceda acesso.
- Tornar acessos administrativos sensíveis justificáveis e auditáveis.

## Fora do escopo

- Escolher uma gem de autorização.
- Definir código de policies ou controllers.
- Criar novos papéis sem aprovação do produto.

## Princípios

1. Toda autorização é validada no servidor.
2. Ausência de regra explícita significa acesso negado.
3. O papel concede capacidade; propriedade, atribuição e estado ainda podem restringi-la.
4. Acesso administrativo a dado sensível exige finalidade vinculada a caso.
5. A interface pode ocultar ações indisponíveis, mas isso não substitui a proteção do servidor.
6. Alteração de papel invalida imediatamente permissões futuras, sem apagar autoria histórica.

## Atores e escopos

| Ator | Escopo base | Restrições adicionais |
|---|---|---|
| Visitante | Conteúdo público | Sem favoritos, solicitação ou chat |
| Usuário não confirmado | Própria conta e favoritos | Sem publicar, solicitar ou conversar |
| Conta pessoal confirmada | Recursos próprios e negociações participantes | Não opera organização simultaneamente |
| `responsible` | Toda a organização | Transferência exige confirmação por e-mail |
| `administrator` | Organização, membros, unidades e operações | Não transfere responsabilidade sem fluxo próprio |
| `operator` | Recursos atribuídos | Sem gestão ampla de membros ou configuração |
| `platform_administrator` | Administração completa | Dois fatores e auditoria obrigatórios |
| `moderator` | Conteúdo e casos de moderação | Sem banimento definitivo se não autorizado pela regra final |
| `support_agent` | Chamados e casos atribuídos | Sem banimento definitivo ou acesso livre a conversas |

## Matriz de capacidades públicas e pessoais

| Ação | Visitante | Não confirmado | Pessoal confirmado | Observação |
|---|---:|---:|---:|---|
| Pesquisar e abrir anúncio | Sim | Sim | Sim | Somente projeção pública |
| Favoritar | Não | Sim | Sim | Exige autenticação |
| Salvar pesquisa e receber alerta | Não | Não | Sim | Exige e-mail confirmado |
| Publicar anúncio | Não | Não | Sim | Exige conta ativa e termo aceito |
| Solicitar material | Não | Não | Sim | Não pode solicitar anúncio próprio |
| Conversar | Não | Não | Sim | Somente conversa participante |
| Ver endereço exato | Não | Não | Condicional | Somente destinatário selecionado |
| Avaliar | Não | Não | Condicional | Somente negociação elegível |
| Denunciar | Não | Sim | Sim | Regra final de confirmação será validada na fase |
| Bloquear outra conta | Não | Sim | Sim | Impede contato futuro |

## Matriz organizacional

| Ação | `responsible` | `administrator` | `operator` |
|---|---:|---:|---:|
| Editar perfil da organização | Sim | Sim | Não |
| Criar e editar unidade | Sim | Sim | Não |
| Convidar e remover membro | Sim | Sim | Não |
| Alterar papel de membro | Sim | Sim, exceto responsável | Não |
| Transferir responsabilidade | Sim | Não | Não |
| Publicar anúncio | Sim | Sim | Sim, no escopo atribuído |
| Atribuir anúncio ou negociação | Sim | Sim | Não |
| Ver todas as conversas organizacionais | Sim | Sim | Não |
| Ver conversa atribuída | Sim | Sim | Sim |
| Configurar destinatários de notificações | Sim | Sim | Não |
| Ver métricas internas por membro | Sim | Sim | Não |
| Solicitar exclusão da organização | Sim | Não | Não |

## Matriz administrativa

| Ação | `platform_administrator` | `moderator` | `support_agent` | Exigência |
|---|---:|---:|---:|---|
| Gerenciar papéis da plataforma | Sim | Não | Não | Auditoria reforçada |
| Gerenciar catálogo | Sim | Sim, se delegado | Não | Motivo em alteração sensível |
| Ocultar/restaurar anúncio | Sim | Sim | Não | Caso ou motivo registrado |
| Ocultar/restaurar avaliação | Sim | Sim | Não | Caso ou motivo registrado |
| Analisar denúncia | Sim | Sim | Condicional | Escopo atribuído |
| Acessar conversa denunciada | Sim | Sim | Condicional | Somente trecho/caso necessário |
| Mediar contestação | Sim | Sim | Sim | Não movimenta valores |
| Aplicar advertência | Sim | Sim | Condicional | Conforme política aprovada |
| Aplicar suspensão temporária | Sim | Sim | Não | Decisão motivada |
| Aplicar banimento definitivo | Sim | Não | Não | Regra crítica e recurso disponível |
| Corrigir documento diretamente | Não | Não | Não | Usar fluxo da SPEC-01 |
| Restaurar conteúdo | Sim | Sim | Condicional | Respeitar decisão vigente |

## Regras de escopo

- **AUT-001:** Um usuário só atua no contexto de conta associado à sessão atual.
- **AUT-002:** Membro removido perde acesso organizacional imediatamente.
- **AUT-003:** Operador só acessa anúncios, negociações e conversas atribuídos.
- **AUT-004:** Responsável e administrador podem ver conversas organizacionais para operação, com autoria de acesso disponível para auditoria.
- **AUT-005:** Papel interno não concede acesso a conversa sem caso, chamado ou permissão operacional explícita.
- **AUT-006:** Endereço exato depende de seleção ativa e é revogado no cancelamento.
- **AUT-007:** Autor de denúncia não recebe acesso às evidências ou dados privados da outra parte.
- **AUT-008:** Uma parte bloqueada não cria nova solicitação nem mensagem para quem a bloqueou.
- **AUT-009:** Recurso encerrado não pode ser reaberto acima do limite aprovado sem decisão excepcional auditada.
- **AUT-010:** Exportação de dados só inclui o titular e registros que podem ser legalmente compartilhados com ele.

## Decisões sensíveis

As ações abaixo exigem autenticação recente, segundo fator quando aplicável e registro de auditoria:

- transferência de responsável;
- alteração de e-mail ou documento;
- atribuição ou remoção de papel administrativo;
- suspensão ou banimento;
- acesso administrativo a conversa ou evidência;
- exportação e exclusão de dados;
- restauração de conteúdo após decisão.

## Cenários de autorização

### Caso feliz: operador atribuído

Um operador abre a negociação atribuída, responde ao interessado e registra uma confirmação permitida. O sistema associa todas as ações ao membro e à organização.

### Negação: identificador conhecido

Um usuário autenticado tenta abrir uma conversa alheia por URL conhecida. O servidor responde sem revelar participantes, conteúdo ou existência além do necessário.

### Revogação: membro removido

Um administrador remove um operador. Novas requests desse operador são negadas imediatamente; mensagens e eventos anteriores continuam associados a ele no histórico.

### Acesso administrativo justificado

Um moderador abre uma denúncia vinculada a uma mensagem e acessa somente a conversa necessária. O acesso registra caso, motivo, data, administrador e escopo consultado.

## Critérios de aceitação

- [ ] Toda capacidade da matriz possui teste de permissão positiva e negativa na fase correspondente.
- [ ] Conhecer um identificador não permite acessar recurso fora do escopo.
- [ ] Membro removido não mantém acesso por sessão antiga.
- [ ] Operador não acessa recurso organizacional não atribuído.
- [ ] Endereço exato é revogado quando a seleção deixa de ser válida.
- [ ] Acesso administrativo sensível exige caso e produz auditoria.
- [ ] `support_agent` não consegue aplicar banimento definitivo.
- [ ] A interface e o servidor apresentam a mesma decisão, sem depender da interface para segurança.

## Riscos e questões abertas

- **Risco:** regras dispersas por controllers gerarem decisões inconsistentes. Mitigação: política focada por recurso, sem criar framework interno genérico.
- **Risco:** sessão manter escopo após remoção de membro. Mitigação: verificar vínculo vigente em ações protegidas e definir invalidação de sessão na implementação.
- **Aberto:** confirmar se usuário não confirmado pode denunciar ou se denúncia exigirá confirmação de e-mail.
- **Aberto:** definir quais medidas temporárias poderão ser aplicadas por `support_agent`.

## Dependências

- [SPEC-01 — Contas, perfis e organizações](../produto/spec-01-contas-perfis-organizacoes.md)
- [SPEC-07 — Moderação, contestações e recursos](../confiabilidade/spec-07-moderacao-contestacoes.md)
- [SPEC-08 — Administração e atendimento](../capacidades/spec-08-administracao-atendimento.md)
- [SPEC-12 — Modelo de domínio e contratos](spec-12-modelo-dominio-contratos-dados.md)
