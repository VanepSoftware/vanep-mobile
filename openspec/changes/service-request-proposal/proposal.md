## Why

A change do back `service-request-proposal` (vanep-api-java, pilha VAN-30, PRs #293 a #304) entrega a negociação inteira: o responsável pede orçamento, o motorista responde com uma proposta versionada, e o responsável aceita, recusa ou pede ajuste. No app, a Início (VAN-41) e a lista de propostas (VAN-42) estão sobre dados de exemplo, o detalhe e a conversa do responsável não existem, e a aba Propostas do motorista é "Em breve". Os mocks também partiram de suposições que a API não confirma: um filho por pedido, um turno só por pedido, dias sem ida e volta, um resultado "expirada" para a proposta vencida (que na verdade reabre o pedido). Esta change liga as telas do canvas "Vanep — Início, Vans e Propostas" na API real e corrige o modelo onde o mock errou.

O contrato do back e o mapeamento fechado com o desenvolvedor mandam. O canvas e os mocks são referência: onde discordam do back, a spec diz o que vale.

## What Changes

- **Camada de dados da negociação**, num módulo novo `lib/modules/negotiations/`: solicitação e proposta, nas visões do responsável e do motorista, com o resumo da proposta vigente (`currentProposal`), o filtro por vários status e os erros do back (404, 409, 422) mapeados. Todas as telas abaixo leem dela.
- **Responsável**
  - **Pedir orçamento** (canvas Propostas · 5), aberto pelo botão "Pedir orçamento" da busca e do perfil do motorista. Alunos com caixa de marcar; quem não está pronto para contrato aparece desativado com "Completar". Uma grade de dias e trechos por filho, preenchida a partir dos dias e turnos dele. Início desejado, mensagem e "n de 5 pedidos abertos".
  - **Lista de propostas** (VAN-42) ligada na API: Pendentes, Aguardando resposta e Encerradas a partir dos status reais; um card pode ter mais de um filho; cancelar pedido; Encerradas paginadas e sem valor.
  - **Detalhe da proposta** (VAN-43): versão, validade, "12x de R$ 300", total, diferença para a versão anterior e comparação, aluno, dias e trechos, embarque em casa e saída da escola, condições, mensagem e histórico.
  - **Pedir ajuste**, **recusar** e **proposta aceita** (canvas Propostas · 6, 7 e 8). A tela de aceita existe como vitrine: assinatura abre "Em breve".
  - **Negociação na conversa** (VAN-44): o chat mostra, junto das mensagens, o pedido, as versões e os ajustes, montados no app a partir da API.
  - **A conversa começa pelo pedido:** como no spike e no back (PR 12 da VAN-30), a conversa do par nasce com o pedido de orçamento. O "Conversar com o motorista" sai do perfil, e "Conversar" nas telas da negociação abre a conversa do pedido.
  - **Início** (VAN-41): "Proposta nova", "Pedido expirou" (7 dias) e o card de negociações saem da API.
- **Motorista**
  - **Negociações** (VAN-58) na aba Propostas: Pendentes (pedido novo e ajuste solicitado) e Aguardando resposta.
  - **Pedido de orçamento** (VAN-59) com recusa.
  - **Montar proposta** e **nova versão** (VAN-60 e VAN-61): valor mensal por aluno, total digitado pelo motorista, parcelas, vencimento, período, dias e trechos, horário de embarque (ida) e de saída (volta) por dia, van, condições, validade e mensagem.
  - **Negociação na conversa** (VAN-62), com o mesmo modelo do responsável, e "Conversar" no pedido, no ajuste e na proposta.
- **BREAKING (interno):** o domínio do `client_proposals` (`PendingProposal`, `SentRequest`, `ClosedProposal`, `ProposalOutcome`, `ProposalsFeed`) é reescrito a partir do módulo `negotiations`. `CLIENT_PROPOSALS_SCENARIO` e o datasource de cenários da lista são apagados. Os itens de negociação do cenário da Início saem do `ScenarioDailyOverviewDataSource`; o resto do cenário (rota do dia, mensalidade, contrato) continua mock.
- `Weekday` sai de `dependents/domain/value_objects/` e vai para `lib/core/domain/`, porque a negociação também usa.

## Capabilities

### New Capabilities

- `negotiation-data`: leitura e escrita da solicitação e da proposta nas duas visões, o resumo da proposta vigente, a regra de "de quem é a vez" e os erros.
- `client-quote-request`: pedir orçamento a um motorista para um ou mais filhos, com a prontidão do cadastro e a grade de dias e trechos.
- `client-proposals-feed`: a lista de propostas do responsável sobre a API, com o filtro por filho, as encerradas e o cancelar pedido.
- `client-proposal-detail`: o detalhe da proposta e as ações do responsável (pedir ajuste, recusar, aceitar), mais a tela de proposta aceita.
- `client-home-negotiations`: os itens de negociação da Início do responsável vindos da API.
- `negotiation-chat`: a negociação mostrada dentro da conversa, para o responsável e para o motorista.
- `driver-negotiations`: a aba Negociações do motorista, o pedido de orçamento e a recusa.
- `driver-proposal-composer`: montar a proposta e mandar uma nova versão.

### Modified Capabilities

Nenhuma. `openspec/specs/` ainda está vazio. Esta change substitui os requisitos da change `client-proposals-list` (VAN-42, ainda não arquivada) que dependiam do mock: "antes R$ X", "Nova na Vanep com o veículo", o resultado "expirada" da proposta e o requisito "Mocked data until the API exists". Na change `client-home-screen` (VAN-41), substitui só a origem dos itens de negociação no "Data source contract".

## Impact

**Módulo novo `lib/modules/negotiations/`:** entidades, value objects, falhas, contratos de repositório, DTOs, datasources, implementações e use cases das duas visões.

**Módulos alterados:**
- `client_proposals`: domínio, dados, cubit e cards reescritos; telas novas de detalhe, ajuste, recusa, aceita e pedir orçamento.
- `client_home`: a origem dos itens de negociação.
- `conversations`: a linha do tempo da negociação na conversa; a conversa aberta pelo token do pedido; sai a abertura pelo `driverToken`.
- `driver_search` e `drivers`: o botão "Pedir orçamento"; o "Conversar com o motorista" sai do perfil.
- `driver`: a aba Propostas troca o `VanepComingSoon` pelas telas novas.
- `driver_vans`: só leitura, para o seletor de van.
- `dependents`: só o `Weekday`, que vai para o core.

**`Environment`:** endpoints de `/api/clients/me/service-requests`, `/api/clients/me/proposals`, `/api/drivers/me/service-requests` e `/api/drivers/me/proposals`.

**Localização:** todos os textos novos em `app_pt.arb` e `app_en.arb`; as chaves que só o mock usava saem.

**Dependências:**

| Necessidade | Situação | Efeito aqui |
|---|---|---|
| Pilha VAN-30 do back | PRs #293 a #304 abertas, fora da main e de `api.vanep.com.br`; o PR 12 (`VAN-30/12-conversation-on-request`: a solicitação abre a conversa, traz o `conversationToken` e as listas filtram por ele) existe só no back local | O app só vai para a main depois do back na main e em `api.vanep.com.br`; o QA manual usa o back local; a fase 3 entra na main junto com o PR 12 |
| VAN-39 (redesign de dependentes) | PRs #113 e #117 a #120 abertas, rebaseadas na main | Pedir orçamento usa a grade, a prontidão e o `SchoolShift` com 4 valores da VAN-39 |
| Contrato no aceite (fase 3), assinatura (fase 4), retirada das outras negociações (fase 5) | Fora da VAN-30 | O texto "Em caso de aceite, o contrato é gerado" fica e é revisto antes de usuário real; "Revisar e assinar" abre "Em breve" |

**Fora de escopo:** contratos (lista e detalhe), assinatura, cartões guardados no chat (fase 6), comissão e "você recebe" (fase 9), push (fase 10), retirar proposta e "Aceitando novos alunos" sem tela, bloqueio, e tudo o que o back não tem: ocupação da van, acréscimo na rota, origem do cliente, sobrenome da família, chegada à escola, espera no ponto, regra da taxa de reserva, "motoristas parecidos" e "Manter atual".
