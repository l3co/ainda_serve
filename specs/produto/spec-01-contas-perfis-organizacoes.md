# SPEC-01 — Contas, perfis e organizações

**Versão:** 0.2
**Estado:** Proposta
**Depende de:** PRD
**ADRs:** 0002, 0008

## Estado

Proposta.

## Objetivo

Definir cadastro, autenticação, perfis pessoais, organizações, membros, unidades e ciclo de vida das contas.

## Escopo

### Incluído

- Pessoa física e organização.
- E-mail, senha, confirmação, recuperação e dois fatores.
- Responsável, administradores e operadores de organização.
- Unidades, endereços e membros.
- Perfil público, documentos e exclusão de conta.

### Excluído

- Login social.
- Biometria, prova de vida ou consulta paga de documentos.
- Uma pessoa operar simultaneamente com perfil pessoal e organizacional.

## Modelo conceitual

- `User`: pessoa que autentica com e-mail e senha.
- `Account`: identidade que atua na plataforma, do tipo pessoa física ou organização.
- `Membership`: vínculo de um `User` com uma organização e seu papel.
- `OrganizationUnit`: unidade operacional e endereço de uma organização.

Os nomes acima são conceitos e não autorizam migrations ou classes antes da aprovação da arquitetura detalhada.

## Atores e pré-condições

| Ação | Ator | Pré-condição | Resultado esperado |
|---|---|---|---|
| Criar conta pessoal | Visitante | E-mail e CPF ainda não vinculados | Conta não confirmada |
| Criar organização | Visitante responsável | E-mail e CNPJ ainda não vinculados | Organização e responsável pendentes de confirmação |
| Convidar membro | Responsável ou administrador | Organização ativa e e-mail válido | Convite com papel e expiração |
| Transferir responsabilidade | Responsável atual | Destinatário é administrador elegível | Transferência pendente de confirmação |
| Alterar documento | Titular autenticado | Fluxo simples ou administrativo conforme histórico | Documento revalidado e auditado |
| Excluir conta | Titular elegível | Sem pendência impeditiva | Período de arrependimento iniciado |

## Contratos conceituais

### Pessoa física

| Dado | Obrigatório | Validação | Exposição |
|---|---:|---|---|
| Nome | Sim | Não vazio e dentro do limite aprovado | Público |
| E-mail | Sim | Normalizado, único e confirmável | Privado |
| Telefone | Sim | Formato brasileiro aceito e normalizado | Privado |
| CPF | Sim | Formato, dígitos verificadores e unicidade | Nunca público por inteiro |
| Data de nascimento | Sim | Deve comprovar 18 anos ou mais | Privada |
| Cidade e estado | Sim | Localidade brasileira reconhecida | Públicos |

### Organização

| Dado | Obrigatório | Validação | Exposição |
|---|---:|---|---|
| Razão social | Sim | Não vazia | Administrativa |
| Nome público | Sim | Não vazio | Público |
| CNPJ | Sim | Formato, dígitos verificadores e unicidade | Nunca público por inteiro |
| Tipo | Sim | ONG, loja, construtora ou outra organização | Público |
| Responsável | Sim | Usuário confirmado e vínculo exclusivo | Público apenas como papel, não documento |
| Unidade inicial | Para operar | Nome, cidade, estado e endereço restrito | Região pública; endereço restrito |

## Ciclo de vida

| Estado conceitual | Pode autenticar | Pode publicar/solicitar | Saída permitida |
|---|---:|---:|---|
| Não confirmada | Sim, com restrições | Não | confirmar, corrigir e-mail, solicitar exclusão |
| Ativa | Sim | Sim | desativar, suspender por decisão, solicitar exclusão |
| Desativada em arrependimento | Sim para recuperação | Não | recuperar ou concluir exclusão após 30 dias |
| Suspensa | Conforme medida | Não ou parcialmente | recurso, término da medida, banimento |
| Banida | Não | Não | recurso dentro do limite |

Transições devem preservar histórico e rejeitar alterações incompatíveis com pendências.

## Requisitos funcionais

### Cadastro e autenticação

- **CON-001:** O acesso deve usar e-mail e senha.
- **CON-002:** O e-mail deve ser único e confirmado antes de publicar, solicitar ou conversar.
- **CON-003:** Uma conta não confirmada pode navegar e favoritar anúncios.
- **CON-004:** Deve existir recuperação de senha por e-mail.
- **CON-005:** Alterações de e-mail exigem confirmação no novo endereço e aviso no endereço anterior.
- **CON-006:** Dois fatores devem ser obrigatórios para administradores da plataforma e opcionais para os demais usuários.
- **CON-007:** Notificações de segurança não podem ser desativadas.

### Pessoa física

- **CON-008:** O cadastro deve coletar nome, e-mail, telefone, cidade, estado, CPF e data de nascimento.
- **CON-009:** O usuário deve declarar ter 18 anos ou mais, e a data informada deve confirmar a maioridade.
- **CON-010:** CPF deve ser único e validado localmente por formato e dígitos verificadores.
- **CON-011:** CPF nunca deve ser exibido publicamente por inteiro.

### Organização

- **CON-012:** O cadastro deve coletar razão social, nome público, CNPJ, tipo, responsável, e-mail, telefone, cidade e estado.
- **CON-013:** Tipos iniciais incluem ONG, loja, construtora e outra organização.
- **CON-014:** CNPJ deve ser único e validado localmente por formato e dígitos verificadores.
- **CON-015:** CNPJ nunca deve ser exibido publicamente por inteiro.
- **CON-016:** O responsável cria a organização e convida membros por e-mail.
- **CON-017:** Membros convidados precisam confirmar o e-mail, mas não precisam cadastrar CPF no MVP.
- **CON-018:** Uma organização pode possuir várias unidades, endereços e cidades.
- **CON-019:** Cada anúncio deve pertencer a uma unidade e pode ter um membro responsável.

### Papéis organizacionais

- **CON-020:** O papel `responsible` controla a organização e a transferência de responsabilidade.
- **CON-021:** O papel `administrator` gerencia membros, unidades, endereços, anúncios e negociações.
- **CON-022:** O papel `operator` gerencia anúncios e negociações atribuídos.
- **CON-023:** Administradores podem convidar e remover membros.
- **CON-024:** Administradores podem visualizar conversas da organização; operadores veem somente o que lhes for atribuído.
- **CON-025:** A transferência do responsável deve apontar para outro administrador e exigir confirmação por e-mail.
- **CON-026:** Ações relevantes de membros devem registrar autor, data e alteração.

### Exclusividade do contexto

- **CON-027:** Um `User` não pode operar simultaneamente como pessoa física e como membro de organização.
- **CON-028:** A tentativa de ingressar em uma organização com perfil pessoal ativo deve orientar a escolha de um único contexto, sem apagar histórico automaticamente.

### Perfil público

- **CON-029:** O perfil pode conter fotografia ou logotipo sujeito a denúncia e moderação.
- **CON-030:** O perfil público exibe nome, tipo de conta, cidade, estado, data de entrada, reputação, histórico agregado e anúncios ativos.
- **CON-031:** Telefone, e-mail, CPF, CNPJ completo, data de nascimento e endereço exato não são públicos.

### Alteração de documentos

- **CON-032:** Antes da primeira atividade relevante, CPF, CNPJ e nascimento podem ser corrigidos com nova validação local e unicidade.
- **CON-033:** Depois de anúncio, negociação ou avaliação, a alteração exige solicitação administrativa, senha, confirmação por e-mail e segundo fator quando habilitado.
- **CON-034:** Toda alteração controlada deve registrar valor anterior, novo valor, motivo, data e responsável.
- **CON-035:** Documento banido ou já utilizado não pode ser atribuído a outra conta.
- **CON-036:** Mudança de CNPJ só preserva reputação e histórico após análise da continuidade da entidade.

### Exclusão e portabilidade

- **CON-037:** A exclusão possui prazo de arrependimento de 30 dias.
- **CON-038:** O prazo começa somente depois do encerramento de negociações, contestações e recursos pendentes.
- **CON-039:** Durante o prazo, a conta fica desativada e pode ser recuperada mediante autenticação e confirmação por e-mail.
- **CON-040:** O usuário pode solicitar cópia de seus dados e atividades; inicialmente, o atendimento pode gerar o arquivo.
- **CON-041:** Registros que precisem ser preservados para segurança, auditoria ou obrigação legal devem deixar de ser públicos e seguir política de retenção aprovada.

## Requisitos não funcionais

- Senhas nunca podem ser armazenadas em texto simples.
- Autorização deve ser validada no servidor.
- Dados pessoais não devem aparecer em logs ou exemplos.
- Upload de perfil aceita formato de imagem aprovado e até 5 MB.
- Interfaces devem ser acessíveis por teclado e leitores de tela.

## Critérios de aceitação

- [ ] Pessoa maior de idade cria e confirma uma conta pessoal por e-mail.
- [ ] Pessoa não confirmada navega e favorita, mas não publica nem conversa.
- [ ] Responsável cria organização, unidade e convites de membros.
- [ ] Papéis impedem ações fora das permissões definidas.
- [ ] CPF, CNPJ e e-mail duplicados são rejeitados sem revelar a conta existente.
- [ ] Datas exatamente no limite de 18 anos são aceitas e abaixo do limite são rejeitadas.
- [ ] Dados sensíveis não aparecem no perfil público, logs ou respostas de erro.
- [ ] Mudança de documento após atividade exige fluxo administrativo.
- [ ] Transferência só termina depois da confirmação do novo responsável.
- [ ] Exclusão com pendência aguarda resolução antes de iniciar os 30 dias.
- [ ] Repetir convite, confirmação ou recuperação não duplica efeitos.

## Cenários de falha e borda

- Cadastro com documento válido em formato, mas já banido, deve falhar sem revelar a conta anterior.
- Convite aceito depois da expiração deve orientar novo convite.
- Remoção do último responsável deve ser impossível.
- Transferência não confirmada mantém o responsável anterior.
- Organização com negociação pendente não inicia exclusão.
- Alteração simultânea de e-mail deve aceitar apenas o fluxo confirmado mais recente conforme regra a detalhar na fase.

## Questões abertas

- Definir validade e política de reenvio de convites e confirmações.
- Definir limites de tentativas de autenticação, recuperação e dois fatores na SPEC técnica da fase.
- Confirmar se denúncia por conta não confirmada permanece permitida conforme SPEC-13.

## Dependências

- [ADR-0002 — Modelagem de contas e organizações](../../adr/0002-modelagem-contas-organizacoes.md)
- [ADR-0008 — Autenticação e autorização nativas](../../adr/0008-autenticacao-autorizacao-nativas-rails.md)
- [SPEC-10 — Qualidade, segurança e privacidade](../qualidade/spec-10-qualidade-seguranca-privacidade.md)
- [SPEC-12 — Modelo de domínio e contratos](../arquitetura/spec-12-modelo-dominio-contratos-dados.md)
- [SPEC-13 — Papéis e autorização](../arquitetura/spec-13-papeis-autorizacao.md)
