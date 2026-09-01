# ADR-0002 — Modelagem de contas e organizações

## Estado

Aceito em 31 de agosto de 2026.

## Contexto

Uma flag diretamente no usuário seria suficiente para uma pessoa física ou uma organização com um único acesso, mas organizações precisam de vários membros, papéis, unidades e cidades.

## Decisão

Separar os conceitos:

- `User`: credencial e pessoa autenticada.
- `Account`: identidade que atua na plataforma, pessoal ou organizacional.
- `Membership`: vínculo e papel de um usuário em organização.
- `OrganizationUnit`: unidade, endereço e contexto operacional.

Um usuário não pode operar simultaneamente como pessoa física e como membro de organização no MVP.

## Consequências

### Positivas

- Organização possui vários membros sem compartilhar senha.
- Permissões e auditoria apontam para a pessoa que agiu.
- Reputação pode ser agregada por organização e unidade.
- Endereços, horários e anúncios pertencem ao local correto.

### Negativas

- Cadastro e autorização exigem mais associações que uma flag simples.
- Troca de contexto e convites precisam de invariantes explícitas.

## Alternativas consideradas

- Flag em `users`: rejeitada por misturar credencial individual e entidade representada.
- Uma tabela distinta para cada tipo de usuário: rejeitada por duplicar autenticação e comportamento comum.
- Um usuário alternar livremente entre perfil pessoal e várias organizações: adiado por decisão de produto.

## Referências

- [SPEC-01 — Contas, perfis e organizações](../specs/produto/spec-01-contas-perfis-organizacoes.md)
