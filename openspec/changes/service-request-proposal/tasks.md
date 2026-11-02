Issue no Genwork: **VAN-78**. Branches no formato `VAN-78/<fase>-<nome>`, empilhadas a partir de `VAN-78/spec-service-request-proposal`. As telas citam as tarefas de tela do Genwork (VAN-41 a VAN-62) que cada fase fecha.

### Entrega fatiada (R16–R23)

| Fase | Conteúdo | Depende de | Em paralelo com |
|----|----------|------------|---------------|
| 1 | `Weekday` no core e domínio de `negotiations` | VAN-39 mergeada | — |
| 2 | Dados, use cases e container de `negotiations` | Fase 1 | — |
| 3 | Core do responsável: formatadores e componentes de tela (VAN-42) | Fase 2 | Fase 4 |
| 4 | Regras e rótulos da negociação: comparação de versões, preço e horários, grupos de itens, horários por trecho, escolas, limite da recusa, rótulos dos enums e do histórico | Fase 2 | Fase 3 |
| 5 | Lista de propostas na API, cards, filtro, cancelar pedido e remoção do mock; a conversa abre pelo token e sai do perfil (VAN-42, D12) | Fases 3 e 4 | — |
| 6 | Detalhe da proposta, comparação, aceitar e "Proposta aceita" (VAN-43) | Fase 5 | — |
| 7 | Pedir ajuste e recusar a proposta (VAN-43) | Fase 6 | Fase 8 |
| 8 | Pedir orçamento na busca e no perfil (VAN-47 e Propostas · 5) | Fase 6 | Fase 7 |
| 9 | Negociação na conversa (VAN-44) e na Início (VAN-41) | Fase 7 | — |
| 10 | Testes novos do responsável, das fases 3 a 9 | Fases 3 a 9 | — |
| 11 | Motorista: peças comuns da proposta no `negotiations`, aba Propostas, lista de negociações, pedido de orçamento, recusa, ajuste solicitado e proposta só leitura (VAN-58, VAN-59, VAN-61) | Fase 10 | — |
| 12 | Motorista: montar proposta e nova versão (VAN-60, VAN-61) | Fase 11 | — |
| 13 | Motorista: negociação na conversa (VAN-62) | Fase 12 | — |
| 14 | Testes novos do motorista, das fases 11 a 13 | Fases 11 a 13 | — |

As branches ficam empilhadas na ordem dos números. As fases 1 e 2 seguem a R20 (contratos uma fase antes das implementações). O lado do responsável fica em uma fase por tela, de 3 a 9, e, por decisão do desenvolvedor, os arquivos de teste novos dele vão juntos na fase 10, contra a R25. Os testes foram escritos antes do código, como nas tarefas abaixo, e só entram no PR depois. Os testes que já existiam e que uma fase muda vão na própria fase, para cada branch passar no `make test` sozinha. As fases 6, 8 e 9 passam das 600 linhas da R23 pelo tamanho das telas. O motorista fica em três fases de tela, na ordem em que uma liga a outra: a fase 11 leva as peças comuns para o `negotiations`, sem mudar o responsável, e traz a aba, a lista, o pedido, a recusa, o ajuste e a proposta só leitura; a fase 12, o montar proposta; a fase 13, a conversa. Os arquivos de teste novos das três vão juntos na fase 14, como os do responsável na fase 10. "Montar proposta" e "Nova versão" só aparecem na fase 12. As fases do motorista passam das 600 linhas da R23, por decisão do desenvolvedor. O motorista vem depois do responsável porque reaproveita a abertura da conversa pelo token, a rota da conversa da negociação (`openClientNegotiationChat`), o `NegotiationTimelineCubit`, o `VanepWeekLegsGrid` e os formatadores. Toda fase termina com `make lint` e `make test` verdes e espera o teste manual no aparelho, contra o back local da pilha VAN-30, e a aprovação explícita antes de qualquer commit (R27a).

## 1. Fase 1 — Domínio (`VAN-78/1-negotiation-domain`)

- [x] 1.1 Mover `Weekday` de `dependents/domain/value_objects/` para `lib/core/domain/weekday.dart` e trocar os imports, sem cópia; conferir com `grep -rn "enum Weekday" lib` (uma definição) e os testes de dependentes verdes
- [x] 1.2 Testes primeiro para os value objects: `ServiceRequestStatus`, `ProposalStatus`, `ProposalAdjustmentPolicy`, `ProposalCancellationPolicy`, `ProposalAdjustmentField`, `RouteLeg` e `OperationShift` com `fromApi`/`toApi` (ida e volta, valor desconhecido → `null`), e `ClockTime` (leitura de `"12:05:00"` e `"12:05"`, escrita `"12:05"`, ordem); depois implementá-los em `negotiations/domain/value_objects/` até passarem
- [x] 1.3 Adicionar as entidades `ClientServiceRequest`, `DriverServiceRequest`, `ClientRequestItem`, `DriverRequestItem`, `RequestedDay`, `ProposalSummary`, `Proposal`, `ProposalItem`, `ScheduleSlot`, `ProposalVehicle` e `ProposalAdjustment`, abstratas, com valores em centavos (D3); conferir que `make lint` passa
- [x] 1.4 Testes primeiro para `clientTurnOf` e `driverTurnOf`: uma linha da tabela da spec `negotiation-data` por teste, inclusive a proposta vencida que volta a `OPEN`; depois implementar até passarem
- [x] 1.5 Testes primeiro para `buildNegotiationHistory` (ordem por data; pedido, versões com valor, ajustes com valor ou assunto, aceite e recusa; versão aberta marcada) e `compareProposalVersions` (só os campos que mudaram; nenhuma mudança → vazio; dias, horários e veículo); depois implementar até passarem
- [x] 1.6 Testes primeiro para `deriveOperationShift` (os quatro períodos nos dois trechos), `previewInstallmentAmount` (8000/10 → 800,00; 1000/3 → 333,33; 1 parcela) e `summarizeLegs` (ida e volta, só ida, só volta, misto); depois implementar até passarem
- [x] 1.7 Testes primeiro para `ServiceRequestDraft`: pelo menos um aluno; cada aluno com pelo menos um trecho; dia sem trecho não vai; início de hoje em diante; mensagem até 1000. E para `ProposalDraft`: total > 0; parcelas 1–12; vencimento 1–28; período com fim depois do início e até 12 meses; só trechos pedidos; cada trecho ligado com um horário; validade 1–7; mensagem até 1000; montar a partir de um pedido e a partir de uma `Proposal`. Depois implementar até passarem
- [x] 1.8 Adicionar `NegotiationFailure` (D10) e os contratos `ClientNegotiationRepository` e `DriverNegotiationRepository` com todas as operações das duas superfícies, só os contratos; conferir com o teste de igualdade das falhas
- [x] 1.9 Rodar `make lint` e `make test`
- [ ] 1.10 Abrir o PR

## 2. Fase 2 — Dados, use cases e DI (`VAN-78/2-negotiation-data`)

- [x] 2.1 Testes primeiro para os DTOs com JSON copiado das respostas do back local: as duas visões da solicitação (com e sem `currentProposal`, com `driverRating` `null`, com o `conversationToken`), a proposta (nas duas visões, com `dependentName` `null` para o motorista), slots, veículo (com `token` só na visão do motorista) e ajustes; valores em centavos; datas, horas e instantes. E para o JSON de envio: solicitação (sem período escolar), proposta (centavos → número com duas casas, horários `"HH:mm"`), ajuste, recusas. Depois criar os DTOs e rodar o `build_runner` até passarem
- [x] 2.2 Testes primeiro para os datasources: caminho e método de cada operação da tabela das specs do back; `status` como lista separada por vírgula; `conversationToken` opcional; `page` e `size`; os erros 404, 409, 422 e 400 com `detail` e sem resposta viram as falhas do D10. Depois adicionar os endpoints no `Environment` (D11), os dois datasources e as duas implementações de repositório até passarem
- [x] 2.3 Testes primeiro para os use cases do responsável (`SendServiceRequest`, `ListClientServiceRequests`, `FindClientServiceRequest`, `WithdrawServiceRequest`, `ListClientProposalVersions`, `FindClientProposal`, `AcceptProposal`, `DeclineProposal`, `RequestProposalAdjustment`) e do motorista (`ListDriverServiceRequests`, `FindDriverServiceRequest`, `DeclineServiceRequest`, `SendProposal`, `ListDriverProposalVersions`, `FindDriverProposal`, `WithdrawProposal`), com o nome do lado nos que existem nos dois: cada um repassa ao repositório e devolve o `Result` dele. Depois implementá-los até passarem
- [x] 2.4 Adicionar `negotiations_container.dart` e registrá-lo no `main.dart`; conferir com um teste do service locator que cada use case é resolvido
- [x] 2.5 Rodar `make lint` e `make test`; conferir as leituras e uma escrita de cada superfície contra o back local da pilha VAN-30 com os usuários do seed
- [ ] 2.6 Abrir o PR

## 3. Fase 3 — Core do responsável (`VAN-78/3-client-core`)

- [x] 3.1 Testes primeiro para `formatInstallments` e os outros formatadores do `core/formatters/` (datas, `joinNames`, `firstNameOf`, `joinFirstNames`, dias da semana, campo de dinheiro) (D7); depois implementá-los até passarem
- [x] 3.2 Testes de widget primeiro para `VanepWeekLegsGrid` em `core/ui/` (só leitura; editável; trecho não permitido desativado; sábado e domingo só quando existem; semântica de cada célula); depois implementá-lo até passarem
- [x] 3.3 Testes de widget primeiro para os componentes novos do `core/ui/` (`VanepChip`, `VanepExpiryChip`, `VanepCurrentDot`, `VanepInstallmentPrice`) e para o botão secundário de perigo; depois implementá-los até passarem
- [x] 3.4 Rodar `make lint` e `make test`
- [ ] 3.5 Abrir o PR

## 4. Fase 4 — Regras e rótulos da negociação (`VAN-78/4-negotiation-rules`)

- [x] 4.1 Testes primeiro para as regras novas de `negotiations/domain`: comparação de versões, horários que mudaram, mudança de preço pelo total, grupos de itens por horário e por dias, horários por trecho, escolas da solicitação e o limite do motivo com a mensagem da recusa; depois implementá-las até passarem
- [x] 4.2 Testes primeiro para os rótulos dos enums da negociação e do histórico em `negotiations/presentation/formatters/` (D7); depois implementá-los até passarem
- [x] 4.3 Rodar `make lint` e `make test`
- [ ] 4.4 Abrir o PR

## 5. Fase 5 — Lista de propostas (`VAN-78/5-client-proposals-list`)

- [x] 5.1 Testes primeiro (`bloc_test`) para o `ClientProposalsCubit` reescrito: carrega abertas (`OPEN,ANSWERED`) e a primeira página de encerradas; agrupa pela vez; filtro por filho com vários filhos por negociação e com dependente removido; contador da conta inteira; carregar mais encerradas; cancelar pedido move para Encerradas; falha de rede com tentar de novo. Depois reescrever o domínio e o cubit do `client_proposals` sobre `negotiations` (D4) até passarem
- [x] 5.2 Testes de widget primeiro para os cards: pendente (vários filhos, escolas diferentes, "turno varia", nota sem veículo, sem nota, parcelas, início proposto, validade), aguardando (pedido `OPEN` com horas e "enviado ontem"; ajuste solicitado), encerrada (os quatro resultados, sem valor) e a confirmação de cancelar. Depois refazer os cards até passarem
- [x] 5.3 Testes primeiro para a rota `openClientNegotiationChat`, que abre a conversa pelo `conversationToken` e pelo nome do motorista da solicitação (D12); depois ligar "Conversar" à conversa pelo `conversationToken` (sem `conversationToken`, o botão não aparece); conferir com o teste da página
- [x] 5.4 Tirar a abertura da conversa pelo perfil (D12): o "Conversar com o motorista" e o `onChatTapped` do `DriverProfilePage`, a chave `driverProfileChatButton`, o `openDriverChat` do `app.dart`, o `driverToken` e o `openConversationWithDriver` do `ChatCubit` (que passa a exigir o token da conversa), o `OpenConversation`, o `openConversation` do repositório e do datasource, e os testes deles; trocar o texto do `conversationsInboxEmptyClient` (pt e en) para dizer que a conversa começa pelo pedido de orçamento; `grep -rn "openConversation\|OpenConversation\|openDriverChat\|driverProfileChatButton" lib test` só encontra o `openConversationChat`
- [x] 5.5 Apagar `ClientProposalsRepository`, os datasources de cenário e vazio, os value objects do mock, `CLIENT_PROPOSALS_SCENARIO` (`.env.example` e `Environment`) e as chaves de l10n que só eles usavam (`clientProposalsPreviousFee`, `clientProposalsNewOnVanep`, `clientProposalsOutcomeCancelled`, …); `grep -rn "ScenarioClientProposals\|clientProposalsScenario" lib test` não encontra nada
- [ ] 5.6 Rodar `make lint` e `make test`; testar no aparelho contra o back local: abertas, encerradas, filtro, cancelar pedido, "Conversar" da lista e a caixa de entrada
- [ ] 5.7 Abrir o PR, avisando que ele entra na main junto com o PR 12 do back (`VAN-30/12-conversation-on-request`)

## 6. Fase 6 — Detalhe da proposta e aceite (`VAN-78/6-proposal-detail`)

- [x] 6.1 Testes primeiro para o `ProposalDetailCubit`: carrega proposta, solicitação e versões em paralelo; modo pedido carrega só a solicitação; aceitar com sucesso; 409 mostra o `detail` e recarrega; 404 sai. Depois implementá-lo até passarem
- [x] 6.2 Testes de widget primeiro para o detalhe: cada bloco da spec `client-proposal-detail`, horários por dia quando variam, taxa só quando existe, mudança de preço e link de comparação da versão 2, rodapé só em `SENT`, confirmação do aceite, versão substituída com link para a vigente, modo pedido com "Cancelar pedido". Depois implementar a página e a comparação até passarem
- [x] 6.3 Testes de widget primeiro para "Proposta aceita": resumo, etapas com a data do aceite e sem prazos, aviso de encerramento ao assinar, "Revisar e assinar contrato" abre "Em breve", "Assinar depois" fecha. Depois implementar até passarem
- [x] 6.4 Ligar "Ver proposta" e "Ver pedido" da lista ao detalhe; conferir com o teste da lista
- [ ] 6.5 Rodar `make lint` e `make test`; testar no aparelho contra o back local: aceitar, versão substituída, aceite com cadastro mudado (409), comparação entre versões
- [ ] 6.6 Abrir o PR

## 7. Fase 7 — Pedir ajuste e recusar (`VAN-78/7-proposal-adjustment-decline`)

- [x] 7.1 Testes primeiro para o `ProposalAdjustmentCubit` e a tela de pedir ajuste: as cinco opções com escolha única, mensalidade para Valor, texto livre nas outras, exige valor ou mensagem, limites de 100 e 500, sucesso volta ao detalhe com o ajuste no histórico. Depois implementar até passarem
- [x] 7.2 Testes primeiro para o `ProposalDeclineCubit` e a gaveta de recusa: cinco motivos, mensagem opcional, motivo e mensagem juntos em até 500 caracteres, confirmação, sucesso encerra a negociação, 409 recarrega o detalhe. Depois implementar até passarem
- [x] 7.3 Ligar "Pedir ajuste" e "Recusar proposta" do detalhe às duas telas por callback do `app.dart`; conferir com o teste do detalhe
- [ ] 7.4 Rodar `make lint` e `make test`; testar no aparelho contra o back local: pedir ajuste e recusar
- [ ] 7.5 Abrir o PR

## 8. Fase 8 — Pedir orçamento (`VAN-78/8-quote-request`)

- [x] 8.1 Testes primeiro para o `QuoteRequestCubit`: carrega motorista, dependentes, prontidão, a grade de cada dependente e as abertas; dependente incompleto desativado; lacunas do responsável desativam o envio; grade inicial com todos os trechos; "Completar" e a volta consultam a prontidão de novo; limite de 5; envio com sucesso; 409 de pedido aberto oferece a negociação existente; 422 mantém o rascunho. Depois implementá-lo até passarem
- [x] 8.2 Testes de widget primeiro para a tela: cabeçalho com e sem nota, alunos com caixa e "Completar", uma grade por aluno marcado, trajeto, início sem datas passadas, mensagem, rodapé "n de 5" e o aviso de lacuna do responsável (telefone e endereço com destino, CPF sem link). Depois implementar a página até passarem
- [x] 8.3 Adicionar "Pedir orçamento" ao `DriverCard` da busca e ao `DriverProfilePage` (desativado com aviso quando `available = false`), o preço base sem parcelas no card, e a rota `openQuoteRequest` no `app.dart`; conferir com os testes de widget da busca e do perfil
- [ ] 8.4 Rodar `make lint` e `make test`; testar no aparelho contra o back local: pedido para um filho, para dois, com dependente incompleto, com o responsável sem telefone, quinto e sexto pedido, pedido repetido para o mesmo motorista; o pedido abre a conversa, que aparece na caixa de entrada das duas partes
- [ ] 8.5 Abrir o PR

## 9. Fase 9 — Negociação na conversa e na Início (`VAN-78/9-chat-home-negotiations`)

### Conversa (VAN-44)

- [x] 9.1 Testes primeiro para o `NegotiationTimelineCubit`: lê a negociação mais recente da conversa pela lista filtrada por `conversationToken` (primeiro item); sem negociação (conversa antiga) → nada; carrega a cadeia de versões; recarrega depois de uma ação; falha na primeira leitura mostra a faixa com "Tentar novamente". E para a mistura de mensagens e eventos por data com separador por dia. Depois implementar até passarem
- [x] 9.2 Testes de widget primeiro para a conversa: faixa da proposta vigente, cartões do pedido (embarque só com o bairro), das versões ("Substituída" e a bolinha azul) e do ajuste, o aviso sobre acordos, "Ver proposta", "Aceitar" e o botão de ajuste, conversa sem negociação igual a hoje. Depois implementar até passarem
- [x] 9.3 Ligar as ações dos cartões às telas do `client_proposals` por callback do `app.dart`; conferir com o teste do `ChatPage`

### Início (VAN-41)

- [x] 9.4 Testes primeiro para `FindNegotiationHighlights`: proposta nova só na vez do responsável; ajuste pedido não vira item; expirado nos últimos 7 dias entra e o de 8 dias não; contagem e filhos das abertas; falha → nenhum item. Depois implementá-lo até passarem
- [x] 9.5 Testes primeiro para o `LoadClientHome` e o `ResolveSectionWithoutVan` com os itens reais junto do cenário (prioridade e limite de 3 mantidos; `NegotiatingSection` pela contagem real). Depois ajustar os dois e o `NewProposalItem` (D6) até passarem
- [x] 9.6 Tirar do `ScenarioDailyOverviewDataSource` os itens de proposta nova e de pedido expirado e a contagem de negociações, e atualizar o `TODO(VAN-41)` (R40b); conferir com os testes de dados da Início
- [x] 9.7 Testes de widget primeiro para os itens: "Proposta nova" com o selo de validade, tocar abre o detalhe, "Conversar" abre a conversa, "Pedido expirou" com "Buscar vans". Depois ajustar os widgets até passarem

### Fechamento

- [ ] 9.8 Rodar `make lint` e `make test`; testar no aparelho contra o back local: uma negociação com duas versões e um ajuste na conversa; a Início com e sem `CLIENT_HOME_SCENARIO`
- [ ] 9.9 Abrir o PR

## 10. Fase 10 — Testes do responsável (`VAN-78/10-client-negotiations-tests`)

- [x] 10.1 Trazer os arquivos de teste novos das fases 3 a 9 (core, regras e rótulos, lista, detalhe, ajuste e recusa, pedir orçamento, conversa e Início, rotas do `app.dart`)
- [x] 10.2 Rodar `make lint` e `make test`
- [ ] 10.3 Abrir o PR

## 11. Fase 11 — Negociações do motorista (`VAN-78/11-driver-negotiations`, VAN-58, VAN-59 e VAN-61)

### Peças comuns

- [x] 11.1 Mover do `client_proposals` para o `negotiations` as peças de leitura da proposta (`proposal_sections.dart`, `negotiation_blocks.dart`, estado vazio) e os formatadores que os dois lados usam (prazo, início, dias e trechos, horários por trecho, linha do aluno) (D7), sem mudar o responsável; os testes do responsável que mudam de import vão junto

### Aba e lista (VAN-58)

- [x] 11.2 Testes primeiro para `driverNegotiationsOf` (pendentes e aguardando pela `driverTurnOf`, encerradas fora, próxima página) e o `DriverNegotiationsCubit` (abertas, puxar para atualizar, próxima página, falha). Depois criar o módulo `driver_proposals` com eles e o container, registrado no `main.dart`, até passarem
- [x] 11.3 Testes de widget primeiro para a aba (Negociações com a contagem, Contratos abre "Em breve") e a lista ("Maria · Theo e Alice", pedido novo, ajuste solicitado sem valor, aguardando com "R$ 340/mês · 12x", estado vazio). Depois implementar até passarem
- [x] 11.4 Trocar o `VanepComingSoon` da aba Propostas do `DriverShell` pela aba nova; conferir com o teste do `DriverShell`

### Pedido de orçamento e recusa (VAN-59)

- [x] 11.5 Testes primeiro para o `DriverServiceRequestCubit` (carrega, 404 sai) e o `RequestDeclineCubit` (motivo opcional, até 500, 409 recarrega). Depois implementá-los até passarem
- [x] 11.6 Testes de widget primeiro para o pedido (alunos com primeiro nome e idade, trajeto pelo bairro, dias e trechos, mensagem, "Recusar" com a gaveta e "Conversar" abre a conversa do pedido). Depois implementar até passarem, com a rota da conversa do motorista no `app.dart`

### Ajuste solicitado e proposta só leitura (VAN-61)

- [x] 11.7 Testes primeiro para `LoadDriverProposal`, `DriverProposalDetail` (ajuste pendente só na versão aberta) e o `DriverProposalCubit` (carrega, 404 sai). Depois implementá-los até passarem
- [x] 11.8 Testes de widget primeiro para o ajuste (card "AJUSTE SOLICITADO · <assunto>" com a hora, a versão contra o sugerido e a mensagem; card da versão com "R$ 340/mês · 12x" e o total; histórico; "Recusar"; "Conversar"; sem "Manter atual") e para a proposta só leitura (os mesmos dados que o responsável vê, alunos pelo primeiro nome, sem ações). Depois implementar até passarem
- [x] 11.9 Ligar os itens da lista ao pedido, ao ajuste e à proposta só leitura; conferir com o teste da lista. "Montar proposta" e "Nova versão" entram na fase 12

### Fechamento

- [ ] 11.10 Rodar `make lint` e `make test`; conferir que as telas do responsável não mudaram; testar no aparelho com o motorista do seed: a lista com pedido novo, ajuste solicitado e aguardando; puxar para atualizar; abrir e recusar um pedido; ajuste de valor, de parcelas e de horários; "Ver proposta completa"; "Conversar"
- [ ] 11.11 Abrir o PR

## 12. Fase 12 — Montar proposta e nova versão (`VAN-78/12-proposal-composer`, VAN-60 e VAN-61)

- [x] 12.1 Testes primeiro para `LoadProposalComposer`, `ProposalComposerSetup` (rascunho a partir do pedido e de uma proposta; vans: uma escolhida, várias com seletor, nenhuma bloqueia, a van anterior removida pede outra) e o `ProposalComposerCubit` (horários com "aplicar a todos"; prévia da parcela; validação do `ProposalDraft`, com um centavo por parcela; envio com sucesso; 409 recarrega; 422 e 400 mantêm o rascunho). Depois implementá-los até passarem
- [x] 12.2 Testes de widget primeiro para a tela: total, parcelas e vencimento, período do contrato, grade com trechos não pedidos desativados, horários numa tabela com uma linha por dia e as colunas Ida e Volta, seletor de van, condições, "Validade da proposta" numa seção própria, mensagem, rodapé com a prévia, sem comissão. Depois implementar até passarem
- [x] 12.3 Ligar "Montar proposta" do pedido e "Nova versão" do ajuste ao montar proposta; conferir com os testes das duas telas
- [ ] 12.4 Rodar `make lint` e `make test`; testar no aparelho: primeira proposta, nova versão depois de um ajuste, duas versões ao mesmo tempo (409), período de 12 meses e um dia, sem van cadastrada
- [ ] 12.5 Abrir o PR

## 13. Fase 13 — Negociação na conversa do motorista (`VAN-78/13-driver-chat-negotiation`, VAN-62)

- [x] 13.1 Testes primeiro para a linha do tempo do lado do motorista (lê a negociação pela lista do motorista filtrada por `conversationToken`; faixa "Ajuste solicitado" com "Responder"; cartão do ajuste com "Nova versão"; aviso "Endereço e nome completo disponíveis após o aceite."). Depois implementar reaproveitando o `NegotiationTimelineCubit` até passarem
- [x] 13.2 Ligar "Responder" e "Nova versão" ao montar proposta por callback do `app.dart`; conferir com o teste do `ChatPage` do motorista
- [ ] 13.3 Rodar `make lint` e `make test`; testar no aparelho as duas pontas da mesma conversa
- [ ] 13.4 Abrir o PR

## 14. Fase 14 — Testes do motorista (`VAN-78/14-driver-negotiations-tests`)

- [ ] 14.1 Trazer os arquivos de teste novos das fases 11 a 13 (domínio, use cases, container, cubits e telas do `driver_proposals`, conversa do motorista) e os mocks do montar proposta
- [ ] 14.2 Rodar `make lint` e `make test`
- [ ] 14.3 Abrir o PR
