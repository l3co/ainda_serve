# SPEC-17 — Lançamento, indicadores e evolução comercial

**Versão:** 0.1
**Estado:** Proposta
**Depende de:** PRD e SPEC-01 a SPEC-16
**ADRs:** 0005

## Contexto

O produto estará disponível nacionalmente, com divulgação inicial em São Paulo. A abertura pública precisa distinguir capacidade técnica, prontidão operacional e validação do valor do produto. Monetização futura deve permanecer visível no roadmap sem contaminar o MVP gratuito.

## Objetivos

- Definir critérios verificáveis de lançamento.
- Estabelecer indicadores de produto, segurança e operação.
- Planejar um piloto observável e reversível.
- Registrar anúncios patrocinados e planos empresariais como evolução futura separada.

## Fora do escopo

- Definir preços, cobrança, comissão ou contratos de planos.
- Implementar anúncios patrocinados no MVP.
- Estabelecer metas de crescimento sem baseline.
- Converter materiais heterogêneos em uma métrica ambiental única.

## Estratégia de lançamento

### Etapa 1 — Uso interno controlado

- Contas de teste e dados fictícios.
- Validação das jornadas J01 a J08.
- Exercícios de moderação, contestação, backup e restauração.
- Correção de bloqueadores antes de convite externo.

### Etapa 2 — Piloto convidado em São Paulo

- Usuários e organizações convidados.
- Publicação disponível, mas com acompanhamento operacional reforçado.
- Coleta de feedback sobre cadastro, publicação, busca e negociação.
- Revisão semanal de incidentes, abandonos e dúvidas recorrentes.

### Etapa 3 — Abertura nacional

- Cadastro e busca liberados em todo o Brasil.
- Comunicação clara de que a densidade de oferta varia por região.
- Monitoramento de capacidade operacional e segurança.
- Expansão de divulgação somente após estabilidade do piloto.

As etapas são uma proposta de redução de risco e precisam de aprovação antes da execução.

## Critérios de prontidão

### Produto

- [ ] Jornadas essenciais possuem critérios de aceite aprovados e executados.
- [ ] Termos de Uso, Política de Privacidade e política de materiais proibidos estão publicados.
- [ ] Limites de pagamento, transporte e qualidade aparecem nos pontos de decisão.
- [ ] Conteúdo inicial do catálogo foi revisado.

### Segurança e confiança

- [ ] Autorização negativa foi validada nos recursos privados.
- [ ] Endereço real não aparece em resposta pública.
- [ ] Denúncia crítica cria caso e oculta conteúdo conforme regra.
- [ ] Administração possui dois fatores e auditoria.
- [ ] Retenção e resposta a incidente foram aprovadas.

### Operação

- [ ] Web, worker, banco e storage passaram pelo smoke test.
- [ ] Backup e restauração foram executados com sucesso.
- [ ] Alertas mínimos estão ativos e possuem destinatário.
- [ ] Filas administrativas têm responsável e procedimento.
- [ ] Limites de serviços externos são conhecidos.

## Indicadores

### Produto

| Indicador | Definição | Segmentos mínimos |
|---|---|---|
| Anúncios publicados | Anúncios que alcançaram estado publicado no período | modalidade, categoria, estado |
| Anúncios ativos | Anúncios encontráveis ao final do período | modalidade, categoria, local |
| Primeira solicitação | Tempo entre publicação e primeira solicitação válida | modalidade e região |
| Conversão em seleção | Solicitações que geraram reserva | modalidade e região |
| Conclusão | Negociações concluídas entre elegíveis | doação e venda separadas |
| Cancelamento | Negociações canceladas entre iniciadas | etapa e modalidade |
| Contestação | Negociações contestadas entre iniciadas | motivo agregado e modalidade |

### Reaproveitamento

Quantidades concluídas são apresentadas na unidade original e por categoria. Não se somam metros, quilogramas, litros e peças em um único número. Qualquer estimativa ambiental futura exigirá metodologia documentada, fonte e margem de incerteza.

### Confiança e segurança

| Indicador | Finalidade |
|---|---|
| Denúncias por tipo | Identificar padrões de abuso e material proibido |
| Tempo até primeira ação | Medir resposta a risco crítico |
| Tempo de resolução | Medir capacidade da operação |
| Recursos e reversões | Detectar inconsistência de decisão |
| Bloqueios e reincidência | Identificar comportamento persistente sem exposição pública |

### Operação

- disponibilidade e erro do serviço web;
- fila e falha de jobs;
- duração das principais requests;
- falhas e consumo das integrações;
- sucesso de backup e restauração;
- volume de chamados e tempo por estado.

## Regras dos indicadores

- **LAN-001:** Métricas não podem expor CPF, CNPJ, endereço ou conversa.
- **LAN-002:** Contagens pequenas devem ser protegidas quando puderem reidentificar pessoa ou unidade.
- **LAN-003:** Doação e venda são reportadas separadamente quando a regra de conclusão divergir.
- **LAN-004:** Organização vê apenas seus dados e a plataforma vê agregados conforme papel.
- **LAN-005:** Uma correção histórica registra versão ou data de atualização do indicador.
- **LAN-006:** Meta comercial não altera ordenação orgânica sem SPEC e transparência próprias.

## Feedback do piloto

O formulário interno deve permitir classificar feedback como:

- dúvida de uso;
- problema funcional;
- problema de acessibilidade;
- problema de segurança ou privacidade;
- sugestão de produto;
- dificuldade de oferta ou demanda local.

Feedback crítico cria caso operacional. Sugestão não cria compromisso automático de roadmap.

## Evolução comercial futura

### Anúncios patrocinados

Antes de implementar, uma nova SPEC deverá definir:

- elegibilidade e compra do destaque;
- duração, preço e cancelamento;
- rótulo **Patrocinado** em todas as superfícies;
- separação entre ranking orgânico e patrocinado;
- limites por página e frequência;
- métricas e prevenção de abuso;
- tratamento de denúncia, pausa e reembolso quando existir cobrança.

### Planos empresariais

Antes de implementar, uma nova SPEC deverá definir:

- limites gratuitos e pagos;
- número de anúncios, membros e unidades;
- importação de catálogo;
- relatórios e exportações;
- suporte prioritário;
- ciclo de cobrança, inadimplência, downgrade e portabilidade.

Nenhuma modelagem de billing será adicionada no MVP somente para antecipar essas possibilidades.

## Critérios de sucesso do piloto

Os valores numéricos serão aprovados antes do piloto. A avaliação deverá ao menos responder:

1. Pessoas conseguem publicar sem atendimento individual?
2. Interessados encontram materiais em distância aceitável?
3. Solicitações resultam em seleção e conclusão?
4. Os limites da plataforma são compreendidos?
5. A operação consegue responder a casos críticos no prazo definido?
6. Há incidentes de privacidade, saldo ou autorização?
7. Quais abandonos impedem a próxima etapa?

## Condições de pausa

O avanço do lançamento deve ser pausado diante de:

- exposição confirmada de endereço ou documento;
- reserva inconsistente ou saldo negativo;
- incapacidade de moderar material perigoso;
- perda de evidência ou auditoria crítica;
- backup não restaurável;
- volume de casos acima da capacidade operacional definida.

## Critérios de aceitação

- [ ] Cada etapa de lançamento possui entrada, evidência e condição de pausa.
- [ ] Produto, segurança e operação possuem critérios independentes de prontidão.
- [ ] Indicadores distinguem doação e venda e preservam unidades originais.
- [ ] Metas numéricas não são inventadas antes do baseline ou aprovação.
- [ ] Monetização futura está documentada sem criar dependências no MVP.
- [ ] Abertura nacional não depende de presença física em São Paulo.

## Questões abertas

- Definir tamanho, duração e critérios de entrada do piloto convidado.
- Definir metas quantitativas e capacidade operacional por etapa.
- Definir responsáveis pelos alertas e filas antes do lançamento.
- Definir quando os dados do piloto autorizam expansão de divulgação.

## Dependências

- [PRD](../../visao-geral.md)
- [Plano geral](../../plans/plan-geral.md)
- [SPEC-15 — Observabilidade, auditoria e retenção](../confiabilidade/spec-15-observabilidade-auditoria-retencao.md)
- [SPEC-16 — DevOps e CI/CD](../infraestrutura/spec-16-devops-cicd.md)
