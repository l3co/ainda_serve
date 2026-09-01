# SPEC-14 — Jornadas, interface responsiva e PWA

**Versão:** 0.1
**Estado:** Proposta
**Depende de:** SPEC-01 a SPEC-08 e SPEC-13
**ADRs:** 0001, 0004

## Contexto

Os requisitos funcionais precisam ser apresentados como uma experiência coerente para visitantes, pessoas e organizações. Esta SPEC define navegação, telas, feedback, estados de interface, progressive enhancement e limites da PWA, sem especificar componentes antes da implementação.

## Objetivos

- Tornar as jornadas essenciais executáveis em celular e computador.
- Definir quais informações aparecem em cada etapa e para cada ator.
- Prever estados vazios, carregamento, erro, expiração e perda de permissão.
- Garantir funcionamento essencial sem geolocalização, Web Push ou instalação.

## Fora do escopo

- Identidade visual definitiva, logotipo ou design system completo.
- Aplicativos nativos.
- Negociação offline.
- Navegação interna curva a curva.

## Arquitetura de informação

### Área pública

- Página inicial com busca por material e origem.
- Resultados em lista e mapa.
- Página pública do anúncio.
- Perfil público da pessoa ou organização.
- Termos, privacidade, segurança e materiais proibidos.

### Área autenticada

- Painel inicial contextual.
- Meus anúncios e formulário de anúncio.
- Solicitações feitas e recebidas.
- Conversas e notificações.
- Favoritos e pesquisas salvas.
- Perfil, segurança, endereços e preferências.
- Avaliações e histórico agregado.

### Área organizacional

- Unidades e endereços.
- Membros, convites, papéis e atribuições.
- Anúncios e negociações por unidade.
- Preferências de notificação e indicadores internos.

### Área administrativa

- Filas de denúncias, contestações, recursos, documentos e chamados.
- Catálogo administrável.
- Visão de caso com histórico, evidências autorizadas e decisão.
- Indicadores operacionais e trilha de auditoria conforme papel.

## Inventário de telas e estados

| Tela | Atores | Ação principal | Estados obrigatórios |
|---|---|---|---|
| Início/busca | Todos | Pesquisar material | inicial, sem origem, sem resultado, resultado |
| Resultados | Todos | Filtrar e abrir anúncio | lista, mapa, carregando mapa, mapa indisponível |
| Anúncio | Todos | Solicitar ou gerenciar | disponível, parcial, reservado, pausado, encerrado |
| Cadastro | Visitante | Criar conta | pessoal, organização, inválido, confirmação pendente |
| Publicação | Conta confirmada | Revisar e publicar | rascunho, validação, termo, publicado |
| Solicitação | Interessado | Informar quantidade e mensagem | disponível, saldo alterado, bloqueado, enviada |
| Interessados | Anunciante | Comparar e selecionar | pendentes, espera, sem saldo, cancelados |
| Negociação | Partes | Combinar e confirmar | reserva, confirmação, contestação, conclusão |
| Conversa | Partes autorizadas | Enviar texto | conectada, reconectando, erro, permissão revogada |
| Caso administrativo | Papel autorizado | Analisar e decidir | fila, atribuído, aguardando parte, decidido, recurso |

## Fluxos detalhados

### Cadastro e confirmação

1. A primeira escolha é entre pessoa física e organização.
2. O formulário explica que um usuário não opera simultaneamente nos dois contextos.
3. Validações são apresentadas junto ao campo e resumidas no topo quando necessário.
4. Após envio, a página informa que o e-mail precisa ser confirmado e permite reenvio controlado.
5. Ações restritas encontradas antes da confirmação levam a essa orientação sem perder o contexto original.

### Publicação

1. Modalidade é escolhida antes do preço; doação nunca exibe campo de preço ativo.
2. Categoria determina atributos adicionais sem remover dados já preenchidos silenciosamente.
3. Quantidade, unidade e divisibilidade são apresentados juntos.
4. As fotos possuem ordem, descrição alternativa orientada e feedback individual de erro.
5. Localização pública é previamente explicada como aproximada.
6. A revisão final mostra tudo o que será público e o que permanecerá privado.
7. O termo de publicação precisa ser aceito antes de **Publicar**.

### Busca e mapa

1. O usuário pode digitar cidade, CEP ou endereço ou escolher usar localização atual.
2. A permissão do dispositivo só é solicitada após ação contextual.
3. Negar permissão mantém a entrada manual disponível e não gera nova solicitação automática.
4. Lista e mapa preservam filtros, ordenação e item selecionado.
5. Falha do mapa não impede a lista nem a abertura do anúncio.
6. O mapa apresenta área aproximada e atribuições dos fornecedores.

### Solicitação e seleção

1. A tela exibe saldo e unidade antes de solicitar.
2. **Selecionar tudo** copia o saldo atual, mas a validação final usa o saldo persistido.
3. Se o saldo mudar, a interface informa o novo máximo e pede ajuste.
4. O anunciante recebe uma lista comparável com perfil, distância, histórico e reputação.
5. A seleção apresenta quantidade reservada e efeito sobre os demais interessados antes da confirmação.

### Confirmação e contestação

1. A interface diferencia claramente venda de doação.
2. Venda mostra aviso persistente de que o pagamento ocorre fora da plataforma.
3. Cada confirmação informa qual efeito produzirá e se depende da outra parte.
4. Ação de contestar permanece disponível durante o prazo aplicável.
5. Um caso contestado mostra situação, próximos passos e prazos sem expor evidências privadas.

## Regras de interface

- **UX-001:** Nenhuma ação destrutiva ou sensível depende apenas de ícone sem rótulo acessível.
- **UX-002:** Estados não podem ser comunicados apenas por cor.
- **UX-003:** Erros preservam entradas válidas e apontam a correção necessária.
- **UX-004:** Atualizações por Turbo preservam foco ou movem-no de forma intencional.
- **UX-005:** Conteúdo inserido por usuário é tratado como texto não confiável.
- **UX-006:** Botão indisponível explica a condição quando isso ajudar o usuário.
- **UX-007:** Ações repetidas durante envio não podem duplicar publicação, mensagem, reserva ou confirmação.
- **UX-008:** Páginas privadas não deixam conteúdo sensível em cache compartilhado.
- **UX-009:** Datas e horários usam o fuso relevante e deixam prazos compreensíveis.
- **UX-010:** Textos do produto são escritos em português do Brasil.

## PWA e progressive enhancement

| Capacidade | Sem JavaScript/PWA | Com Hotwire/PWA |
|---|---|---|
| Busca e filtros | Formulário e navegação completos | Atualização parcial e preservação de estado |
| Publicação | Formulário submetido normalmente | Upload e feedback aprimorados |
| Chat | Recarregamento/polling compatível se definido | Atualização em tempo real |
| Notificações | Central interna | Atualização em tempo real e Web Push autorizado |
| Instalação | Aplicação web normal | Manifest e instalação opcional |
| Conectividade perdida | Mensagem de indisponibilidade | Shell pode carregar; mutações aguardam conexão |

A PWA não deve enfileirar silenciosamente confirmações, contestações ou mensagens como se tivessem sido aceitas offline.

## Acessibilidade

- Ordem de foco previsível e foco visível.
- Rótulos associados a todos os controles.
- Mensagens de erro associadas aos campos e anunciadas quando necessário.
- Regiões de atualização dinâmica com semântica apropriada.
- Alternativa textual para mapa e imagens relevantes.
- Alvos de toque adequados em dispositivos móveis.
- Testes dos fluxos essenciais por teclado e com leitor de tela em amostra definida.

## Critérios de aceitação

- [ ] As jornadas J01 a J08 do PRD possuem entrada, resultado e estado de erro representados.
- [ ] Busca, anúncio e solicitação funcionam sem geolocalização e sem Web Push.
- [ ] Falha do mapa não bloqueia resultados em lista.
- [ ] Troca lista/mapa preserva filtros e seleção.
- [ ] Formulários não perdem dados válidos após erro de validação.
- [ ] Ações sensíveis são idempotentes contra duplo envio.
- [ ] Usuário nunca confunde pagamento externo com pagamento protegido pela plataforma.
- [ ] Fluxos essenciais são utilizáveis por teclado em viewport móvel e desktop.

## Riscos e questões abertas

- **Risco:** o amplo painel autenticado tornar a navegação móvel confusa. Mitigação: validar primeiro as jornadas essenciais e adicionar atalhos por contexto.
- **Risco:** tempo real mascarar perda de autorização. Mitigação: revalidar autorização em toda ação e fechar streams revogados.
- **Aberto:** definir identidade visual, tipografia e tokens após aprovação da arquitetura de informação.
- **Aberto:** definir estratégia de fallback do chat quando a conexão em tempo real estiver indisponível.

## Dependências

- [PRD](../../visao-geral.md)
- [SPEC-03 — Busca e localização](spec-03-busca-localizacao.md)
- [SPEC-04 — Solicitações e negociações](spec-04-solicitacoes-negociacoes.md)
- [SPEC-13 — Papéis e autorização](../arquitetura/spec-13-papeis-autorizacao.md)
