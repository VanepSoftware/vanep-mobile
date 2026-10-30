Issue no Genwork: **VAN-78**. Branches no formato `VAN-78/<fase>-<nome>`, empilhadas a partir de `VAN-78/spec-service-request-proposal`. As telas citam as tarefas de tela do Genwork (VAN-41 a VAN-62) que cada fase fecha.

### Entrega fatiada (R16–R23)

| Fase | Conteúdo | Depende de | Em paralelo com |
|----|----------|------------|---------------|
| 1 | `Weekday` no core e domínio de `negotiations` | VAN-39 mergeada | — |
| 2 | Dados, use cases e container de `negotiations` | Fase 1 | — |
| 3 | Responsável: lista, detalhe e ações, pedir orçamento, Início e conversa (VAN-41, VAN-42, VAN-43, VAN-44, VAN-47 e Propostas · 5) | Fase 2 | — |
| 4 | Motorista: aba, negociações, pedido, ajuste, montar proposta e conversa (VAN-58 a VAN-62) | Fase 3 | — |

Por decisão do desenvolvedor, as fases 3 e 4 juntam tudo de cada lado num PR só, acima da R23 e sem teto de linhas (R17). Só as fases 1 e 2 continuam separadas, pela R20 (contratos uma fase antes das implementações). Dentro de cada fase, a ordem segue a R24. A fase 4 vem depois da 3 porque reaproveita a `Conversation` mínima, o `openNegotiationChat`, o `NegotiationTimelineCubit`, o `VanepWeekLegsGrid` e os formatadores. Toda fase termina com `make lint` e `make test` verdes e espera o teste manual no aparelho, contra o back local da pilha VAN-30, e a aprovação explícita antes de qualquer commit (R27a).

## 1. Fase 1 — Domínio (`VAN-78/1-negotiation-domain`)

- [ ] 1.1 Mover `Weekday` de `dependents/domain/value_objects/` para `lib/core/domain/weekday.dart` e trocar os imports, sem cópia; conferir com `grep -rn "enum Weekday" lib` (uma definição) e os testes de dependentes verdes
- [ ] 1.2 Testes primeiro para os value objects: `ServiceRequestStatus`, `ProposalStatus`, `ProposalAdjustmentPolicy`, `ProposalCancellationPolicy`, `ProposalAdjustmentField`, `RouteLeg` e `OperationShift` com `fromApi`/`toApi` (ida e volta, valor desconhecido → `null`), e `ClockTime` (leitura de `"12:05:00"` e `"12:05"`, escrita `"12:05"`, ordem); depois implementá-los em `negotiations/domain/value_objects/` até passarem
- [ ] 1.3 Adicionar as entidades `ClientServiceRequest`, `DriverServiceRequest`, `ClientRequestItem`, `DriverRequestItem`, `RequestedDay`, `ProposalSummary`, `Proposal`, `ProposalItem`, `ScheduleSlot`, `ProposalVehicle` e `ProposalAdjustment`, abstratas, com valores em centavos (D3); conferir que `make lint` passa
- [ ] 1.4 Testes primeiro para `clientTurnOf` e `driverTurnOf`: uma linha da tabela da spec `negotiation-data` por teste, inclusive a proposta vencida que volta a `OPEN`; depois implementar até passarem
- [ ] 1.5 Testes primeiro para `buildNegotiationHistory` (ordem por data; pedido, versões com valor, ajustes com valor ou assunto, aceite e recusa; versão aberta marcada) e `compareProposalVersions` (só os campos que mudaram; nenhuma mudança → vazio; dias, horários e veículo); depois implementar até passarem
- [ ] 1.6 Testes primeiro para `deriveOperationShift` (os quatro períodos nos dois trechos), `previewInstallmentAmount` (8000/10 → 800,00; 1000/3 → 333,33; 1 parcela) e `summarizeLegs` (ida e volta, só ida, só volta, misto); depois implementar até passarem
- [ ] 1.7 Testes primeiro para `ServiceRequestDraft`: pelo menos um aluno; cada aluno com pelo menos um trecho; dia sem trecho não vai; início de hoje em diante; mensagem até 1000. E para `ProposalDraft`: valor mensal por aluno > 0; total > 0; parcelas 1–12; vencimento 1–28; período com fim depois do início e até 12 meses; só trechos pedidos; ida com início e fim opcional depois do início; volta com início; validade 1–7; mensagem até 1000; montar a partir de um pedido e a partir de uma `Proposal`. Depois implementar até passarem
- [ ] 1.8 Adicionar `NegotiationFailure` (D10) e os contratos `ClientNegotiationRepository` e `DriverNegotiationRepository` com todas as operações das duas superfícies, só os contratos; conferir com o teste de igualdade das falhas
- [ ] 1.9 Rodar `make lint` e `make test`
- [ ] 1.10 Abrir o PR

## 2. Fase 2 — Dados, use cases e DI (`VAN-78/2-negotiation-data`)

- [ ] 2.1 Testes primeiro para os DTOs com JSON copiado das respostas do back local: as duas visões da solicitação (com e sem `currentProposal`, com `driverRating` `null`, com o `conversationToken`), a proposta (nas duas visões, com `dependentName` `null` para o motorista), slots, veículo e ajustes; valores em centavos; datas, horas e instantes. E para o JSON de envio: solicitação (sem período escolar), proposta (centavos → número com duas casas, horários `"HH:mm"`), ajuste, recusas. Depois criar os DTOs e rodar o `build_runner` até passarem
- [ ] 2.2 Testes primeiro para os datasources: caminho e método de cada operação da tabela das specs do back; `status` como lista separada por vírgula; `page`, `size` e `sort`; os erros 404, 409, 422 e 400 com `detail` e sem resposta viram as falhas do D10. Depois adicionar os endpoints no `Environment` (D11), os dois datasources e as duas implementações de repositório até passarem
- [ ] 2.3 Testes primeiro para os use cases (`SendServiceRequest`, `ListMyServiceRequests`, `FindServiceRequest`, `WithdrawServiceRequest`, `DeclineServiceRequest`, `ListProposalVersions`, `FindProposal`, `AcceptProposal`, `DeclineProposal`, `RequestProposalAdjustment`, `SendProposal`, `WithdrawProposal`): cada um repassa ao repositório e devolve o `Result` dele. Depois implementá-los até passarem
- [ ] 2.4 Adicionar `negotiations_container.dart` e registrá-lo no `main.dart`; conferir com um teste do service locator que cada use case é resolvido
- [ ] 2.5 Rodar `make lint` e `make test`; conferir as leituras e uma escrita de cada superfície contra o back local da pilha VAN-30 com os usuários do seed
- [ ] 2.6 Abrir o PR

## 3. Fase 3 — Responsável (`VAN-78/3-client-negotiations`)

### Core e lista (VAN-42)

- [ ] 3.1 Testes primeiro para `formatInstallments` e para os rótulos dos enums da negociação em `core/formatters/` (D7); depois implementá-los até passarem
- [ ] 3.2 Testes de widget primeiro para `VanepWeekLegsGrid` em `core/ui/` (só leitura; editável; trecho não permitido desativado; sábado e domingo só quando existem; semântica de cada célula); depois implementá-lo até passarem
- [ ] 3.3 Testes primeiro (`bloc_test`) para o `ClientProposalsCubit` reescrito: carrega abertas (`OPEN,ANSWERED`) e a primeira página de encerradas; agrupa pela vez; filtro por filho com vários filhos por negociação e com dependente removido; contador da conta inteira; carregar mais encerradas; cancelar pedido move para Encerradas; falha de rede com tentar de novo. Depois reescrever o domínio e o cubit do `client_proposals` sobre `negotiations` (D4) até passarem
- [ ] 3.4 Testes de widget primeiro para os cards: pendente (vários filhos, escolas diferentes, "turno varia", nota sem veículo, sem nota, parcelas, início proposto, validade), aguardando (pedido `OPEN` com horas e "enviado ontem"; ajuste solicitado), encerrada (os quatro resultados, sem valor) e a confirmação de cancelar. Depois refazer os cards até passarem
- [ ] 3.5 Testes primeiro para a `Conversation` mínima montada a partir da solicitação (D12) e para a rota `openNegotiationChat`; depois ligar "Conversar" à conversa pelo `conversationToken` (sem `conversationToken`, o botão não aparece); conferir com o teste da página
- [ ] 3.6 Apagar `ClientProposalsRepository`, os datasources de cenário e vazio, os value objects do mock, `CLIENT_PROPOSALS_SCENARIO` (`.env.example` e `Environment`) e as chaves de l10n que só eles usavam (`clientProposalsPreviousFee`, `clientProposalsNewOnVanep`, `clientProposalsOutcomeCancelled`, …); `grep -rn "ScenarioClientProposals\|clientProposalsScenario" lib test` não encontra nada

### Detalhe e ações (VAN-43)

- [ ] 3.7 Testes primeiro para o `ProposalDetailCubit`: carrega proposta, solicitação e versões em paralelo; modo pedido carrega só a solicitação; aceitar com sucesso; 409 mostra o `detail` e recarrega; 404 sai. Depois implementá-lo até passarem
- [ ] 3.8 Testes de widget primeiro para o detalhe: cada bloco da spec `client-proposal-detail`, horários por dia quando variam, taxa só quando existe, diferença e link de comparação da versão 2, rodapé só em `SENT`, versão substituída com link para a vigente, modo pedido com "Cancelar pedido". Depois implementar a página e a comparação até passarem
- [ ] 3.9 Testes primeiro para o `ProposalAdjustmentCubit` e a tela de pedir ajuste: as cinco opções com escolha única, valor por parcela para Valor, texto livre nas outras, exige valor ou mensagem, limites de 100 e 500, sucesso volta ao detalhe com o ajuste no histórico. Depois implementar até passarem
- [ ] 3.10 Testes primeiro para o `ProposalDeclineCubit` e a gaveta de recusa: cinco motivos, mensagem opcional, motivo e mensagem juntos em até 500 caracteres, sucesso encerra a negociação. Depois implementar até passarem
- [ ] 3.11 Testes de widget primeiro para "Proposta aceita": resumo, etapas com a data do aceite e sem prazos, aviso de encerramento ao assinar, "Revisar e assinar contrato" abre "Em breve", "Assinar depois" fecha. Depois implementar até passarem
- [ ] 3.12 Ligar "Ver proposta" e "Ver pedido" da lista ao detalhe; conferir com o teste da lista

### Pedir orçamento (VAN-47 e Propostas · 5)

- [ ] 3.13 Testes primeiro para o `QuoteRequestCubit`: carrega motorista, dependentes, prontidão, a grade de cada dependente e as abertas; dependente incompleto desativado; lacunas do responsável desativam o envio; grade inicial com todos os trechos; "Completar" e a volta consultam a prontidão de novo; limite de 5; envio com sucesso; 409 de pedido aberto oferece a negociação existente; 422 mantém o rascunho. Depois implementá-lo até passarem
- [ ] 3.14 Testes de widget primeiro para a tela: cabeçalho com e sem nota, alunos com caixa e "Completar", uma grade por aluno marcado, trajeto com o aviso de privacidade, início sem datas passadas, mensagem, rodapé "n de 5" e o aviso de lacuna do responsável (telefone e endereço com destino, CPF sem link). Depois implementar a página até passarem
- [ ] 3.15 Adicionar "Pedir orçamento" ao `DriverCard` da busca e ao `DriverProfilePage` (desativado com aviso quando `available = false`), o preço base sem parcelas no card, e a rota `openQuoteRequest` no `app.dart`; conferir com os testes de widget da busca e do perfil
- [ ] 3.16 Tirar a abertura da conversa pelo perfil (D12): o "Conversar com o motorista" e o `onChatTapped` do `DriverProfilePage`, a chave `driverProfileChatButton`, o `openDriverChat` do `app.dart`, o `driverToken` e o `openConversationWithDriver` do `ChatCubit` (que passa a exigir a conversa), o `OpenConversation`, o `openConversation` do repositório e do datasource, e os testes deles; trocar o texto do `conversationsInboxEmptyClient` (pt e en) para dizer que a conversa começa pelo pedido de orçamento; `grep -rn "openConversation\|OpenConversation\|openDriverChat\|driverProfileChatButton" lib test` só encontra o `openConversationChat`

### Início (VAN-41)

- [ ] 3.17 Testes primeiro para `FindNegotiationHighlights`: proposta nova só na vez do responsável; ajuste pedido não vira item; expirado nos últimos 7 dias entra e o de 8 dias não; contagem e filhos das abertas; falha → nenhum item. Depois implementá-lo até passarem
- [ ] 3.18 Testes primeiro para o `LoadClientHome` e o `ResolveSectionWithoutVan` com os itens reais junto do cenário (prioridade e limite de 3 mantidos; `NegotiatingSection` pela contagem real). Depois ajustar os dois e o `NewProposalItem` (D6) até passarem
- [ ] 3.19 Tirar do `ScenarioDailyOverviewDataSource` os itens de proposta nova e de pedido expirado e a contagem de negociações, e atualizar o `TODO(VAN-41)` (R40b); conferir com os testes de dados da Início
- [ ] 3.20 Testes de widget primeiro para os itens: "Proposta nova" com parcelas e trechos, tocar abre o detalhe, "Conversar" abre a conversa, "Pedido expirou" com "Buscar vans". Depois ajustar os widgets até passarem

### Conversa (VAN-44)

- [ ] 3.21 Testes primeiro para o `NegotiationTimelineCubit`: acha a negociação mais recente da conversa pelo `conversationToken`, lendo a página seguinte enquanto não acha e a lista não acabou; sem negociação (conversa antiga) → nada; carrega a cadeia de versões; recarrega depois de uma ação. E para a mistura de mensagens e eventos por data com separador por dia. Depois implementar até passarem
- [ ] 3.22 Testes de widget primeiro para a conversa: faixa da proposta vigente, cartões do pedido (embarque só com o bairro), das versões ("Substituída" e "Atual") e do ajuste, os dois avisos, "Ver proposta", "Aceitar" e o botão de ajuste, conversa sem negociação igual a hoje. Depois implementar até passarem
- [ ] 3.23 Ligar as ações dos cartões às telas do `client_proposals` por callback do `app.dart`; conferir com o teste do `ChatPage`

### Fechamento

- [ ] 3.24 Rodar `make lint` e `make test`; testar manualmente contra o back local:
  - lista: abertas, encerradas, filtro, cancelar pedido;
  - detalhe: aceitar, recusar, pedir ajuste, versão substituída, aceite com cadastro mudado (409);
  - pedido: para um filho, para dois, com dependente incompleto, com o responsável sem telefone, quinto e sexto pedido, pedido repetido para o mesmo motorista; o pedido abre a conversa, que aparece na caixa de entrada das duas partes;
  - Início: com e sem `CLIENT_HOME_SCENARIO`;
  - conversa: uma negociação com duas versões e um ajuste
- [ ] 3.25 Abrir o PR, avisando que ele entra na main junto com o PR 12 do back (`VAN-30/12-conversation-on-request`)

## 4. Fase 4 — Motorista (`VAN-78/4-driver-negotiations`)

### Aba, negociações, pedido e ajuste (VAN-58, VAN-59, VAN-61)

- [ ] 4.1 Testes primeiro para o `DriverNegotiationsCubit` (abertas, agrupadas por `driverTurnOf`, puxar para atualizar, falha) e o `DriverServiceRequestCubit` (carrega, recusa com motivo opcional, 409 recarrega). Depois implementá-los no módulo novo `driver_proposals` até passarem
- [ ] 4.2 Testes de widget primeiro para a aba (Negociações com a contagem, Contratos abre "Em breve"), a lista ("Maria · Theo e Alice", pedido novo, ajuste solicitado sem valor, aguardando com parcelas) e o pedido (alunos com primeiro nome e idade, trajeto pelo bairro, dias e trechos, mensagem, "Conversar" abre a conversa do pedido). Depois implementar até passarem
- [ ] 4.3 Testes primeiro para o `DriverProposalCubit` e as telas de ajuste e de proposta só leitura (ajuste com assunto, valor e mensagem; versão atual; histórico; "Recusar"; "Conversar"; "Nova versão"; sem "Manter atual"). Depois implementar até passarem
- [ ] 4.4 Trocar o `VanepComingSoon` da aba Propostas do `DriverShell` pela aba nova; conferir com o teste do `DriverShell`

### Montar proposta (VAN-60, VAN-61)

- [ ] 4.5 Testes primeiro para o `ProposalComposerCubit`: rascunho a partir do pedido e de uma proposta; vans (uma escolhida, várias com seletor, nenhuma bloqueia); horários com "aplicar a todos"; prévia da parcela; validação do `ProposalDraft`; envio com sucesso; 409 recarrega; 422 e 400 mantêm o rascunho. Depois implementá-lo até passarem
- [ ] 4.6 Testes de widget primeiro para a tela: valor mensal por aluno, total, parcelas e vencimento, período, grade com trechos não pedidos desativados, horários de ida (início e fim) e de volta (início), seletor de van, condições com as duas opções de cada menu, validade, mensagem, rodapé com a prévia, sem comissão. Depois implementar até passarem
- [ ] 4.7 Ligar "Montar proposta" do pedido e "Nova versão" do ajuste ao montar proposta; conferir com os testes das duas telas

### Conversa (VAN-62)

- [ ] 4.8 Testes primeiro para a linha do tempo do lado do motorista (acha a negociação pelo `conversationToken` na lista do motorista; faixa "Ajuste solicitado" com "Responder"; cartão do ajuste com "Nova versão"; aviso "Endereço e nome completo disponíveis após o aceite."). Depois implementar reaproveitando o `NegotiationTimelineCubit` até passarem
- [ ] 4.9 Ligar "Responder" e "Nova versão" ao montar proposta por callback do `app.dart`; conferir com o teste do `ChatPage` do motorista

### Fechamento

- [ ] 4.10 Rodar `make lint` e `make test`; testar manualmente com o motorista do seed:
  - negociações: pedido novo, recusa, ajuste solicitado, proposta só leitura;
  - montar proposta: primeira proposta, nova versão depois de um ajuste, duas versões ao mesmo tempo (409), período de 12 meses e um dia;
  - conversa: as duas pontas da mesma conversa
- [ ] 4.11 Abrir o PR
