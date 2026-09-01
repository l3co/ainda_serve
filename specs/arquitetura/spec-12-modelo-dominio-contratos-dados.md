# SPEC-12 — Modelo de domínio e contratos de dados

**Versão:** 0.1
**Estado:** Proposta
**Consolida:** SPEC-01 a SPEC-08
**ADRs:** 0001, 0002, 0003
**Autoridade:** os nomes são conceituais; esta SPEC não autoriza migrations ou classes

## Contexto

As SPECs de produto definem muitas regras, mas a implementação precisa de uma visão única das entidades, relacionamentos, quantidades, estados e dados sensíveis. Esta SPEC consolida esses contratos sem determinar antecipadamente cada tabela ou classe Rails.

## Objetivos

- Dar um vocabulário único aos fluxos de identidade, mercado, comunicação e confiança.
- Explicitar cardinalidades e invariantes que precisam sobreviver a concorrência e retries.
- Separar dados públicos, restritos e administrativos.
- Orientar migrations futuras e testes sem criar abstrações prematuras.

## Fora do escopo

- Escolher tipos exatos de coluna, índices ou nomes de migrations.
- Definir uma API pública em JSON.
- Introduzir repository, aggregate root, event sourcing ou CQRS.
- Substituir as regras funcionais das SPECs de origem.

## Princípios de modelagem

1. O código e os identificadores persistidos serão escritos em inglês.
2. O PostgreSQL é a fonte de verdade para estados e quantidades.
3. Uma restrição crítica deve existir no domínio e, quando possível, também no banco.
4. Estado histórico relevante não deve ser inferido apenas do valor atual.
5. Dados pessoais devem ser separados de projeções públicas.
6. Efeitos externos não podem decidir o commit de uma transação de negócio.
7. Uma abstração só será extraída depois que casos reais mostrarem a variação.

## Contextos conceituais

```text
Identity ── owns/represents ──> Marketplace ── creates ──> Communication
   │                              │                         │
   └── permissions                └── completion ──────────┤
                                  │                         │
                                  └──────────────> Trust & Safety
```

Os blocos são limites de raciocínio. Não exigem namespaces, engines ou componentes implantáveis separados.

## Catálogo de entidades

### Identidade

| Conceito | Responsabilidade | Relações principais | Sensibilidade |
|---|---|---|---|
| `User` | Autenticação de uma pessoa | possui uma conta pessoal ou memberships organizacionais | Restrita |
| `Account` | Identidade pública que atua na plataforma | pessoa física ou organização; possui anúncios e reputação | Mista |
| `PersonalProfile` | Dados próprios da pessoa física | pertence a uma account pessoal | Restrita |
| `Organization` | Dados da pessoa jurídica | possui units e memberships | Mista |
| `Membership` | Vínculo e papel de um user em uma organization | pertence a user e organization | Restrita |
| `OrganizationUnit` | Unidade operacional e geográfica | pertence a organization; possui addresses e listings | Mista |
| `Address` | Local real de retirada ou operação | pertence a pessoa ou unit | Altamente restrita |
| `DocumentChangeRequest` | Solicitação de alteração controlada | referencia conta, valores protegidos e decisão | Administrativa |

### Mercado

| Conceito | Responsabilidade | Relações principais | Invariante central |
|---|---|---|---|
| `Category` | Organizar tipos de material | possui attribute definitions | Pode ser desativada sem apagar histórico |
| `MeasurementUnit` | Definir unidade selecionável | usada por listings | Unidade histórica não muda retroativamente |
| `Listing` | Oferta única de venda ou doação | pertence a account e local; possui photos e requests | Uma modalidade por anúncio |
| `ListingPhoto` | Fotografia ordenada do material | pertence a listing | Entre 1 e 5 para publicar |
| `MaterialRequest` | Interesse em uma quantidade | pertence a listing e requester | Quantidade positiva e dentro do saldo no momento da criação |
| `Reservation` | Quantidade comprometida | pertence a request selecionada | Não pode exceder saldo disponível |
| `Negotiation` | Ciclo após seleção | pertence a reservation | Uma reserva ativa possui uma negociação ativa |
| `Confirmation` | Confirmação de entrega ou recebimento | pertence a negotiation e actor | Idempotente por tipo e parte |

### Comunicação e confiança

| Conceito | Responsabilidade | Relações principais | Regra de acesso |
|---|---|---|---|
| `Conversation` | Isolar comunicação de uma solicitação | pertence a material request | Apenas participantes e membros autorizados |
| `Message` | Texto enviado por participante | pertence a conversation | Preservada após ocultação visual |
| `SystemEvent` | Registrar evento imutável do fluxo | pertence a conversation ou objeto de negócio | Não editável pelo usuário |
| `Notification` | Entrega interna de um evento | pertence a recipient | Pode ser lida ou ocultada visualmente |
| `Review` | Avaliação bilateral | pertence a negotiation e papéis | Oculta até revelação bilateral ou prazo |
| `Report` | Denúncia de conteúdo ou comportamento | referencia alvo e autor | Evidências privadas |
| `Dispute` | Suspensão de conclusão de negociação | pertence a negotiation | Mantém a reserva até decisão |
| `Appeal` | Recurso contra decisão | pertence a caso e decisão anterior | No máximo três por encadeamento |
| `Block` | Impedir contato entre duas contas | direcionado de blocker para blocked | Não suspende conta globalmente |
| `AuditEvent` | Provar ação sensível | referencia ator, alvo, motivo e mudança | Imutável para usuários comuns |
| `SupportTicket` | Atendimento iniciado por formulário | pertence a requester | Acesso limitado ao vínculo e papel |

## Contratos mínimos de dados

### Conta e representação

| Campo conceitual | Regra | Exposição |
|---|---|---|
| `email` | único, normalizado e confirmado para ações relevantes | nunca público |
| `account_type` | `personal` ou `organization` | público |
| `document` | CPF ou CNPJ único, validado localmente | mascarado somente onde necessário |
| `birth_date` | obrigatória para pessoa física e deve comprovar 18 anos | nunca público |
| `public_name` | nome da pessoa ou nome público da organização | público |
| `city` e `state` | região geral do perfil | público |
| `status` | ativo, desativado, suspenso ou banido conforme regras aprovadas | efeito público limitado |

### Anúncio e estoque

| Campo conceitual | Regra | Observação |
|---|---|---|
| `kind` | `donation` ou `sale`, imutável depois de publicado | Troca exige novo anúncio |
| `quantity_total` | maior que zero | Na unidade selecionada |
| `quantity_available` | maior ou igual a zero | Alterada sob transação |
| `quantity_reserved` | maior ou igual a zero | Soma das reservas ativas |
| `quantity_completed` | maior ou igual a zero | Soma das conclusões definitivas |
| `lot_price` | obrigatório para venda | Em `BRL` |
| `unit_price` | opcional quando venda parcial é aceita | Em `BRL` por unidade declarada |
| `exact_location` | endereço e coordenada reais | Restrita ao destinatário selecionado |
| `public_location` | região e ponto deliberadamente aproximados | Pública |

Invariante quantitativa:

```text
quantity_total = quantity_available + quantity_reserved + quantity_completed
```

Cancelamentos podem mover quantidade de `reserved` para `available`. Conclusões movem de `reserved` para `completed`. Nenhuma operação pode gerar valor negativo.

### Solicitação e negociação

| Campo conceitual | Regra |
|---|---|
| `requested_quantity` | positiva e nunca acima do saldo disponível no ato da solicitação |
| `selected_quantity` | corresponde à reserva criada pelo anunciante |
| `request_status` | transição explícita conforme SPEC-04 |
| `negotiation_status` | transição explícita conforme SPEC-04 |
| `first_confirmation_at` | inicia prazo automático somente em venda |
| `last_activity_at` | atualizado por mensagem, alteração, confirmação, contestação ou ação administrativa |
| `cancellation_reason` | obrigatório após seleção; visível às partes e administração |

## Relacionamentos e cardinalidades

- Uma pessoa autenticável possui exatamente um contexto operacional ativo: pessoal ou organizacional.
- Uma organização possui um responsável e pode possuir vários administradores, operadores e unidades.
- Uma unidade pertence a exatamente uma organização.
- Um anúncio pertence a uma conta anunciante e, se organizacional, a uma unidade.
- Um anúncio possui muitas solicitações; uma solicitação pertence a um único anúncio.
- Uma solicitação pode gerar no máximo uma reserva ativa por vez.
- Uma negociação nasce de uma reserva e não existe sem ela.
- Uma solicitação possui uma conversa; mensagens de solicitações diferentes nunca se misturam.
- Cada parte pode produzir no máximo uma avaliação por papel em cada negociação elegível.

## Invariantes transversais

- **DOM-001:** Documento, e-mail e identificadores restritos nunca são usados como identificador público enumerável.
- **DOM-002:** Pessoa física e organização não compartilham o mesmo perfil operacional.
- **DOM-003:** Toda mutação organizacional registra o membro autor.
- **DOM-004:** Uma reserva só é criada se a quantidade ainda estiver disponível dentro da mesma transação.
- **DOM-005:** Repetir uma confirmação, job ou callback não duplica efeitos.
- **DOM-006:** Cancelar seleção revoga acesso ao endereço exato na mesma operação lógica.
- **DOM-007:** Ocultar conteúdo não o apaga quando existir obrigação de preservação.
- **DOM-008:** Uma sanção não reescreve avaliações ou negociações históricas.
- **DOM-009:** Exclusão de conta não inicia enquanto houver pendência impeditiva.
- **DOM-010:** Projeções públicas são derivadas somente de dados permitidos para exposição.

## Concorrência e atomicidade

Os seguintes cenários exigem transação e teste de concorrência:

1. dois interessados sendo selecionados para o último saldo;
2. atualização de quantidade enquanto existe solicitação pendente;
3. cancelamento simultâneo à confirmação;
4. conclusão automática simultânea à abertura de contestação;
5. reativação de anúncio simultânea ao job de expiração.

Quando duas ações forem incompatíveis, apenas uma poderá vencer. A ação rejeitada deve receber erro de domínio compreensível e o estado persistido deve permanecer válido.

## Dados públicos, restritos e administrativos

| Classe | Exemplos | Quem pode acessar |
|---|---|---|
| Pública | nome público, cidade, estado, reputação, anúncio, posição aproximada | qualquer visitante |
| Entre participantes | mensagens, motivo de cancelamento, endereço após seleção | participantes autorizados |
| Organizacional | métricas de membros, atribuições, configurações | membros conforme papel |
| Administrativa | evidências, documentos, histórico de decisões, auditoria | papel autorizado e caso vinculado |
| Segredo operacional | senha derivada, token, credencial externa | processo autorizado; nunca UI ou log |

## Critérios de aceitação

- [ ] Cada entidade conceitual possui responsabilidade única e origem em uma SPEC funcional.
- [ ] Cardinalidades não permitem conta sem contexto ou negociação sem reserva.
- [ ] A equação de estoque é preservada em criação, reserva, cancelamento e conclusão.
- [ ] Dados públicos e restritos possuem projeções separadas.
- [ ] A implementação futura testa as cinco condições concorrentes descritas.
- [ ] Repetição de efeitos assíncronos é idempotente.
- [ ] Nenhum nome conceitual deste documento é tratado como migration aprovada sem revisão da fase.

## Riscos e questões abertas

- **Risco:** modelar uma única classe com responsabilidades de perfil, autenticação e organização. Mitigação: respeitar as responsabilidades conceituais sem antecipar herança.
- **Risco:** usar callbacks para efeitos externos antes do commit. Mitigação: persistir primeiro e disparar efeitos de modo retry-safe.
- **Aberto:** decidir o formato final de armazenamento de localização e índice geográfico na fase de arquitetura executável.
- **Aberto:** decidir quais mudanças relevantes de anúncio exigem snapshot histórico além da auditoria genérica.

## Dependências

- [SPEC-01 — Contas, perfis e organizações](../produto/spec-01-contas-perfis-organizacoes.md)
- [SPEC-04 — Solicitações e negociações](../produto/spec-04-solicitacoes-negociacoes.md)
- [SPEC-09 — Arquitetura técnica](spec-09-arquitetura-tecnica.md)
- [SPEC-13 — Papéis e autorização](spec-13-papeis-autorizacao.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](../confiabilidade/spec-15-observabilidade-auditoria-retencao.md)
