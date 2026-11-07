## Context

A motivação, as dependências e o escopo estão no `proposal.md`. Os requisitos estão nos specs desta change.

Estado atual que molda o desenho:

- **`client_proposals` (VAN-42):** `ClientProposalsRepository` com `findProposals()` e `findChildren()`. Os value objects (`PendingProposal`, `SentRequest`, `ClosedProposal`, `ProposalsFeed`) têm um filho por entrada, um `SchoolShift` só e `weekdays: List<int>`. Os dados vêm de `EmptyProposalsDataSource` (produção) ou de `ScenarioClientProposalsDataSource` (`CLIENT_PROPOSALS_SCENARIO`). "Conversar", "Ver proposta", "Ver pedido" e "Cancelar pedido" abrem "Em breve".
- **`client_home` (VAN-41):** `LoadClientHome` monta a Início a partir de `ClientHomeRepository.findDailyOverview()` (tudo vem de um cenário só, `CLIENT_HOME_SCENARIO`) e de `ResolveSectionWithoutVan` (endereço e dependentes reais). `NewProposalItem`, `ExpiredRequestItem` e `NegotiatingSection` só existem no cenário.
- **`conversations`:** `Conversation` (abstrata) tem `token`, `driverToken`, `driverName`, `clientName` e `lastMessageAt`. Hoje o responsável abre a conversa pelo "Conversar com o motorista" do perfil (`openDriverChat` → `ChatCubit` com `driverToken` → `OpenConversation` → `POST /api/conversations`).
- **`driver`:** a aba Propostas do `DriverShell` é um `VanepComingSoon`.
- **Reaproveitáveis:** `FindDriverProfile` (nota, vans com modelo, ano e capacidade, `available`), `ListMyVans` (vans do motorista com token), `FindMyDependents`, `FindSchoolDays`, `FindContractReadiness`, o wizard de dependente no modo de completar (VAN-39), `formatMoney(l10n, cents)`, `SchoolShift` com 4 valores, `VanepSegmentedControl`, `VanepSection`, `VanepAppBar` com legenda, `readProblemDetail`, `Result<E, T>`.

Fatos do back em que o desenho se apoia (vanep-api-java, pilha `VAN-30/*`, versão local):

- A solicitação nas duas visões traz `currentProposal` (`token`, `version`, `status`, `totalAmount`, `installments`, `installmentAmount`, `validUntil`, `startsOn`, `hasPendingAdjustment`), `null` fora de `ANSWERED` e `CONVERTED`. A visão do cliente traz `driverRating`.
- O filtro `status` das listas aceita vários valores (`?status=OPEN,ANSWERED`). As listas são `Page` do Spring (20 por página), sempre ordenadas por `createdAt` decrescente: a ordem está fixa na consulta, e um `sort` mandado pelo app só entraria como critério de desempate.
- A proposta traz `installmentAmount` e `lastInstallmentAmount` (a última parcela leva o resto da divisão, para as parcelas fecharem o total), os itens com `slots` (`weekday`, `leg` `OUTBOUND`/`RETURN`, `shift` `MORNING`/`AFTERNOON`/`NIGHT` e `pickupTime`, um horário só por trecho: o embarque em casa na ida e na escola na volta), o veículo (placa, marca, modelo, ano, cor e capacidade, sem foto; na visão do motorista, também o `token` da van, mesmo removida) e os `adjustments`. Na visão do motorista, `dependentName` vem `null` e só `dependentFirstName` vem preenchido.
- A conversa do par nasce com a primeira solicitação (PR 12 da pilha, `VAN-30/12-conversation-on-request`, D23 do back). As duas visões da solicitação trazem `conversationToken`, a mesma para todas as solicitações do par, e ela continua aberta depois que a solicitação se encerra. As duas listas aceitam `?conversationToken=`, combinável com `status`, que devolve só as solicitações do par daquela conversa, da mais nova para a mais antiga; a conversa de outro par ou um token desconhecido devolvem página vazia. O `POST /api/conversations` saiu, e o `ConversationResponseDTO` não mudou.
- Os erros são `ResponseStatusException` com o `detail` traduzido, sem código: 404, 409 (corrida e prazo: `open_exists`, `service_request.not_open`, `not_current`, `expired`, `accept.stale`, `sent_conflict`, `proposal.request.not_open`), 422 (regra: `not_ready`, `open_limit`, `driver.not_available`, `day.no_school`, `link.blocked`, `link.has_contract`, `period.*`, `items.mismatch`, `slots.not_requested`, `adjustment.empty`) e 400 (Bean Validation).

## Goals / Non-Goals

**Goals:**

- Um dono para cada fato da negociação (R06a): o módulo `negotiations` é dono dos dados e das regras derivadas (de quem é a vez, histórico, comparação de versões, turno da rota, prévia da parcela). Telas só leem e despacham.
- O responsável e o motorista leem o mesmo modelo, com a visão de cada um.
- Cada fase compila e passa nos testes sozinha. Nas fases do responsável, a aba Propostas do motorista continua "Em breve" até a fase 11.

**Non-Goals:**

- Cache, modo offline ou atualização em tempo real da negociação.
- Qualquer regra que o back já aplica (prontidão, limite de 5, prazos, travas) reimplementada no app. O app só mostra e desativa o que o back informa.

## Decisions

### D1. Um módulo `negotiations` para solicitação e proposta

`lib/modules/negotiations/` guarda as duas coisas, nas duas visões:

- **Entidades:** `ClientServiceRequest` e `DriverServiceRequest` (com `ClientRequestItem` / `DriverRequestItem` e `RequestedDay`), `ProposalSummary`, `Proposal` (com `ProposalItem`, `ScheduleSlot`, `ProposalVehicle` e `ProposalAdjustment`).
- **Value objects:** os enums de status, menus e ajuste, `RouteLeg`, `OperationShift`, `ClockTime` (hora e minuto, sem Flutter), `ServiceRequestDraft` e `ProposalDraft` com a validação dos campos.
- **Contratos:** `ClientNegotiationRepository` e `DriverNegotiationRepository`, um por superfície `/me`, mais `NegotiationFailure`.

*Alternativa considerada:* dois módulos como no back (`service_requests` e `proposals`). Rejeitada: a solicitação carrega o resumo da proposta e a proposta aponta para a solicitação, e os dois módulos se importariam.

*Alternativa considerada:* tudo dentro do `client_proposals`. Rejeitada: a Início, a conversa e o motorista também leem a negociação, e um módulo de tela não pode ser importado pelos outros (R02).

### D2. Regras derivadas no domínio, uma vez cada

Funções puras no domínio de `negotiations`, testadas sozinhas e usadas por todas as telas:

| Regra | Usada por |
|---|---|
| `clientTurnOf(request)` / `driverTurnOf(request)`: a tabela de vez da `negotiation-data` | lista do responsável, Início, lista do motorista, conversa |
| `buildNegotiationHistory(request, versions)`: pedido, versões, ajustes, aceite ou recusa, em ordem | detalhe do responsável, ajuste do motorista, conversa |
| `compareProposalVersions(previous, current)`: só os campos que mudaram | detalhe do responsável |
| `deriveOperationShift(schoolShift, leg)`: `MORNING`, `AFTERNOON` e `NIGHT` mantêm o turno; `FULLTIME` dá `MORNING` na ida e `AFTERNOON` na volta | montar proposta |
| `previewInstallmentAmount(totalCents, installments)`: divisão com os centavos truncados, a mesma do back | montar proposta (é a única conta de dinheiro do app) |
| `summarizeLegs(days)`: ida e volta, só ida, só volta ou misto | cards e cartões |

### D3. Dinheiro em centavos, datas e horas sem fuso

Os valores viram `int` em centavos na borda (DTO), como o `formatMoney` já espera. A leitura arredonda `valor × 100` (o back manda no máximo duas casas e até dez dígitos inteiros), e a escrita manda `centavos / 100` como número. `LocalDate` vira `DateTime` local sem hora, lido pelo `parseIsoCalendarDate` que os dependentes já usam; só a data de nascimento do dependente fica como texto ISO, como no `Dependent`, para reaproveitar o `findAgeInYears`. `LocalTime` (`"12:05:00"`) vira `ClockTime`. `Instant` vira `DateTime` em UTC, mostrado no fuso do aparelho.

### D4. `client_proposals` reescrito sobre `negotiations`

O `ClientProposalsRepository`, os datasources de cenário, o `EmptyProposalsDataSource` e os value objects do mock saem (R43). O cubit da lista passa a usar os use cases de `negotiations` (`ListMyServiceRequests` com os status de cada aba, `WithdrawServiceRequest`) e o `FindMyDependents`, que já alimentava o filtro. O agrupamento sai de `clientTurnOf` (D2). O feed guarda as negociações abertas (uma página, porque são no máximo 5) e as encerradas paginadas. O filtro casa um filho com qualquer item da negociação.

Ficam e são ajustados: a gaveta do filtro, o botão de filtro, o `VanepSegmentedControl`, o skeleton, o estado vazio. Os três cards são refeitos: vários filhos, nota sem veículo, parcelas, sem "antes".

O mesmo módulo ganha as telas do responsável (detalhe, comparação, pedir ajuste, recusar, aceita e pedir orçamento), cada uma com o próprio cubit:

| Tela | Cubit | Carrega | Salva |
|---|---|---|---|
| Detalhe (proposta ou pedido) | `ProposalDetailCubit` | `LoadProposalDetail`: proposta, solicitação e cadeia de versões em paralelo; no modo pedido, só a solicitação | `AcceptProposal`; no modo pedido, `WithdrawServiceRequest` |
| Pedir ajuste | `ProposalAdjustmentCubit` | — (recebe a proposta) | `RequestProposalAdjustment` |
| Recusar | `ProposalDeclineCubit` | — | `DeclineProposal` |
| Pedir orçamento | `QuoteRequestCubit` | `LoadQuoteRequest`: perfil do motorista, alunos (`LoadQuoteStudents`: dependentes, prontidão e grade de cada um) e negociações abertas; na volta de "Completar", só os alunos de novo | `SendServiceRequest` |

Os rascunhos ficam nos value objects do domínio (`ServiceRequestDraft`, o pedido de ajuste), e os cubits só guardam o rascunho e o estado de envio (R06a). A carga que junta vários use cases fica em use cases de `client_proposals/domain`, como o `LoadClientProposals`, e as regras de cada tela ficam nos value objects: o aluno pronto, as lacunas do responsável, o limite de 5 e quando o pedido pode ser enviado (`QuoteRequestSetup`). O agrupamento dos alunos por horário e por dias fica em `negotiations/domain`, ao lado do `groupItemsBySchool`, para a fase 11 reaproveitar.

Recusar volta ao detalhe com o resultado: recusada fecha o detalhe; 409 ou 404 mostram a mensagem e recarregam o detalhe, como o aceite. A mensagem da recusa tem o limite que sobra do motivo mais longo, para caber com qualquer motivo nos 500 caracteres do back. O motivo vai como o texto da tela, porque o back guarda texto livre.

Na lista, cancelar um pedido move ele para Encerradas na hora e recarrega a lista do back, que ordena e pagina as encerradas. Uma página de encerradas que chega depois de uma recarga é descartada. Com um filho escolhido, a lista carrega todas as páginas de encerradas, porque o back não filtra por dependente e o contador da aba precisa do total do filho.

### D5. Pedir orçamento

- **Entradas:** o `DriverCard` da busca, que hoje abre o perfil pelo toque no card inteiro, ganha o botão "Pedir orçamento" e o preço base (o `DriverSearchResult` já traz `basePrice`), e o `DriverProfilePage` troca o "Conversar com o motorista" por "Pedir orçamento" (D12). A navegação fica no `app.dart` (`openQuoteRequest(context, driverToken)`), como as outras rotas, e chega aos módulos por callback.
- **Grade inicial:** para cada dependente marcado, o rascunho liga Ida e Volta em todos os dias da grade escolar dele (`FindSchoolDays`). A grade é lida uma vez por dependente quando a tela abre; um responsável tem poucos dependentes.
- **Lacunas do responsável:** `PHONE` leva ao `PersonalDataPage` (auth) e `ADDRESS` ao `PersonalAddressFormPage`, as duas telas que já existem, e ao voltar a prontidão é consultada de novo. `DOCUMENT` aparece no aviso sem link, porque o CPF do responsável é pedido no cadastro e o app não tem tela para editá-lo. O mapeamento campo → rótulo → destino fica numa tabela só, na apresentação.
- **409 de pedido já aberto:** o cubit procura nas negociações abertas a que tem o mesmo `driverToken` e oferece abrir o detalhe dela.

### D6. Início: negociação real junto do cenário

Um use case novo em `client_home`, `FindNegotiationHighlights`, lê duas listas de `negotiations`: as abertas e a primeira página das `EXPIRED` (as mais recentes pela ordem do back). Ele devolve os `NewProposalItem` (só a vez do responsável, D2), os `ExpiredRequestItem` com `updatedAt` nos últimos 7 dias e a contagem e os filhos das negociações abertas. O `LoadClientHome` junta esses itens ao "Precisa de você" do cenário, e o `ResolveSectionWithoutVan` monta o `NegotiatingSection` a partir da contagem real.

O cenário perde os itens de proposta e de pedido expirado e a contagem de negociações. O resto continua igual, com o `TODO(VAN-41)` atualizado (R40b). Uma falha na leitura das negociações vira "nenhum item", sem erro na tela.

`NewProposalItem` passa a guardar o token da proposta, o `driverToken`, as parcelas e a validade, no lugar de `roundTrip` e `monthlyFeeCents`.

*Alternativa considerada:* um datasource que mistura API e cenário dentro do `ClientHomeRepository`. Rejeitada: esconderia a regra de prioridade e da janela de 7 dias na camada de dados.

### D7. Peças compartilhadas de UI e de rótulos

Usadas por mais de um módulo de tela (`client_proposals`, `client_home`, `conversations` e o módulo do motorista). As que não dependem de nenhum módulo vão para `lib/core/` (R02, R10b); os rótulos da negociação vão para o próprio `negotiations`:

- `VanepWeekLegsGrid` em `core/ui/`: a grade Ida/Volta por dia, em modo só leitura (detalhe, pedido do motorista, cartões) ou editável com os trechos permitidos (pedir orçamento, montar proposta).
- `formatInstallments(l10n, installments, cents)` em `core/formatters/`: "R$ 300/mês · 12x", ou "R$ 3.600 à vista" com uma parcela só.
- Os rótulos dos enums da negociação (reajuste, cancelamento, assunto do ajuste, situação da negociação e da proposta, trechos), a mensagem de cada `NegotiationFailure`, o horário, o veículo e o título de cada evento do histórico num único arquivo, `modules/negotiations/presentation/formatters/negotiation_labels.dart`. Ele fica no `negotiations`, e não no `core`, para o `core` não depender de um módulo. Os módulos de tela que usam esses rótulos já dependem do domínio de `negotiations`; essa é a única apresentação de um módulo que outros importam, só com rótulos e peças de leitura, nunca com telas nem cubits.
- As peças de leitura da proposta que o responsável e o motorista mostram iguais, em `modules/negotiations/presentation/widgets/`: as seções do detalhe (`proposal_sections.dart`: valor, dias e trechos, horários, condições, mensagem e histórico), as peças de card (`negotiation_blocks.dart`: título de seção, cabeçalho de pessoa, link, caixa de termos e opção de escolha única) e o estado vazio. Elas nasceram no `client_proposals` e vão para o `negotiations` na fase 11, junto com as primeiras telas do motorista que as usam; o cabeçalho do motorista e os alunos com nome completo continuam no `client_proposals`. Os formatadores que os dois lados usam (prazo, início, dias e trechos, horários por trecho e a linha do aluno) vão junto para o `negotiation_labels.dart`.
- Formatadores genéricos que mais de um módulo de tela usa: `joinNames`, `firstNameOf` (sai do `vanep_greeting_header.dart`) e `joinFirstNames` (os primeiros nomes dos filhos), os rótulos dos dias da semana e `formatWeekdayList` (saem do `dependents` e do `client_proposals`), as datas (`calendar_date_formatter.dart`) e o campo de dinheiro (`MoneyInputFormatter`, que a fase 12 reaproveita no montar proposta).
- `VanepTextField` ganha `minLines` e `maxLines` para as mensagens.

O `Weekday` sai de `dependents/domain/value_objects/` e vai para `core/domain/`, ao lado do `SchoolShift`, sem cópia (R06a), junto com a constante `weekdaysMondayToFriday`. A grade do core não conhece `RouteLeg`: as linhas são genéricas (`VanepWeekLegsGrid<T>`), e cada tela passa o trecho como `T`.

### D8. Negociação na conversa

O `ChatPage` ganha a faixa da proposta vigente e os cartões da negociação, num cubit próprio (`NegotiationTimelineCubit`, em `conversations`), separado do `ChatCubit` das mensagens. Ele lê a negociação mais recente da conversa (lista da parte que está vendo, todos os status, `conversationToken` da conversa, primeiro item da primeira página) e a cadeia de versões. O mesmo cubit serve às duas partes; o lado muda a lista lida e os rótulos. Para isso o cubit, o use case (`FindConversationNegotiation`) e as ações são tipados pela visão (`NegotiationTimelineCubit<ClientServiceRequest>` na fase 9, `<DriverServiceRequest>` na fase 11), sem *cast*. A mistura de mensagens e eventos por data é uma função de apresentação (`buildChatTimeline`); a lista monta cada item sob demanda a partir dessas entradas, e a `ConversationNegotiation` calcula os eventos uma vez. Se a primeira leitura da negociação falha, a conversa mostra no lugar da faixa da proposta "Não foi possível carregar a negociação." com "Tentar novamente", e as mensagens continuam funcionando; uma recarga que falha mantém o que já está na tela. As ações dos cartões ("Ver proposta", "Aceitar", "Pedir ajuste") chegam por callback do `app.dart` e abrem as telas do `client_proposals`, sem importar um módulo de tela no outro (R02). "Aceitar" abre o detalhe daquela versão e aceita pelo mesmo `ProposalDetailCubit` (`loadAndAccept`), então o 409 e a tela de aceita seguem o caminho do detalhe. Na fase 9 só o responsável tem a linha do tempo; a conversa do motorista continua como hoje até a fase 11.

### D9. Motorista em um módulo de tela novo

`lib/modules/driver_proposals/` traz a aba "Propostas" (Negociações / Contratos), a lista, o pedido, a tela do ajuste, a proposta só leitura e o montar proposta:

| Tela | Cubit | Usa |
|---|---|---|
| Negociações | `DriverNegotiationsCubit` | `ListMyServiceRequests` (motorista, `OPEN,ANSWERED`) e `driverTurnOf` |
| Pedido | `DriverServiceRequestCubit` | `FindServiceRequest`, `DeclineServiceRequest` |
| Ajuste e proposta só leitura | `DriverProposalCubit` | `FindProposal`, `ListProposalVersions`, `buildNegotiationHistory` |
| Montar proposta | `ProposalComposerCubit` | `ListMyVans` (`driver_vans`), `ProposalDraft`, `deriveOperationShift`, `previewInstallmentAmount`, `SendProposal` |

O `DriverShell` troca o `VanepComingSoon` pela aba. O `ProposalDraft` nasce vazio a partir do pedido (dias e trechos pedidos, início desejado, validade 7, reajuste "IPCA na renovação" e cancelamento "aviso de 30 dias + 10%" como no canvas) ou preenchido a partir de uma `Proposal` (nova versão), já com a van da versão anterior pelo `token` da visão do motorista; se essa van não está mais entre as do `ListMyVans`, o seletor pede outra. O rascunho só deixa ligar trechos que a família pediu, a mesma regra que o back aplica no envio (`422 proposal.slots.not_requested`).

### D10. Erros

`NegotiationFailure` é sealed: `NegotiationNetworkFailure`, `NegotiationNotFoundFailure`, `NegotiationConflictFailure(detail)` (409), `NegotiationRejectedFailure(detail)` (422), `NegotiationInvalidFailure` (400) e `NegotiationUnexpectedFailure`. O `detail` vem do `readProblemDetail`. A reação de cada tela segue a tabela da `negotiation-data`: o cubit recarrega no 409 e mantém o rascunho no 422 e no 400.

*Alternativa considerada:* mapear cada chave de mensagem do back para um tipo de falha. Rejeitada: o back não manda código, e comparar o texto traduzido quebraria com qualquer mudança de texto.

### D11. Endpoints

O `Environment` ganha `clientServiceRequestsEndpoint`, `clientProposalsEndpoint`, `driverServiceRequestsEndpoint` e `driverProposalsEndpoint`. Os caminhos com token (`/{token}/withdraw`, `/{token}/proposals`, `/{token}/accept`, `/{token}/decline`, `/{token}/adjustments`) são montados a partir deles, como `dependentSchoolDaysEndpoint`. O filtro de status vai como lista separada por vírgula, e o `conversationToken` como parâmetro opcional das duas listas.

### D12. A conversa começa pelo pedido

Pelo spike, a solicitação é a primeira mensagem, e o back passou a abrir a conversa no envio (PR 12 da VAN-30). No app:

- **"Conversar" das telas da negociação**, das duas partes, abre a conversa pelo `conversationToken` da solicitação, sem chamada para abrir. O `ChatCubit` depende só do token da conversa, e o `ChatPage` recebe o nome da outra parte; nenhuma `Conversation` é montada no app. A rota `openClientNegotiationChat(context, request)` passa o token e o `driverName` da solicitação ao `openConversationChat`, e a caixa de entrada passa o token e o nome da conversa (`openInboxConversation`); a fase 11 acrescenta a rota do motorista
- **Sai a abertura pelo perfil:** o "Conversar com o motorista" do `DriverProfilePage` (`onChatTapped`, `driverProfileChatButton`), o `openDriverChat` do `app.dart`, o `driverToken` e o `openConversationWithDriver` do `ChatCubit`, o `OpenConversation`, o `openConversation` do repositório e do datasource, e os testes deles. O `ChatCubit` passa a exigir o token da conversa. Sem a abertura pelo motorista, o 404 das conversas só pode ser a conversa que não existe: a falha `ConversationDriverUnavailableFailure` vira `ConversationNotFoundFailure`, com o texto de conversa indisponível
- **Caixa de entrada vazia do responsável:** o `conversationsInboxEmptyClient` deixa de mandar abrir o perfil e diz que a conversa com um motorista começa quando ele pede um orçamento
- **Conversa sem negociação:** as conversas abertas antes do PR 12 não têm solicitação; elas continuam funcionando como hoje, sem faixa e sem cartões

A abertura pelo token e a saída da abertura pelo perfil entram na fase 5, junto com o "Conversar" da lista, e as fases do responsável vão para a `main` junto com o PR 12 do back. A conversa do motorista (VAN-62) deixa de esperar pelo back e entra na fase 13.

## Risks / Trade-offs

- [A comparação de versões é calculada no app (`compareProposalVersions`, `findScheduleChanges`), porque o back manda cada versão inteira e nenhum diff] → As versões não mudam depois de enviadas e os horários casam por aluno, dia e trecho, então o cálculo é estável; um campo novo da proposta só entra na comparação quando o app o incluir. Se o web passar a comparar versões, o diff deve ir para o back, para não haver duas regras de "o que mudou"
- [O PR 12 do back tira o `POST /api/conversations`, que o "Conversar" do perfil usa] → A fase 5 tira esse botão; o PR 12 e as fases do responsável entram na `main` juntos. Até lá, contra o back local da pilha, o botão do perfil responde 404.
- [A pilha VAN-30 não está na main nem em `api.vanep.com.br`, e o PR 12 ainda não foi para o origin] → O QA manual de cada fase usa o back local; o app só vai para a main depois do back na main e em `api.vanep.com.br`.
- [O texto "Em caso de aceite, o contrato é gerado" é falso até a fase 3 do back] → Decisão do desenvolvedor, porque não há usuário real. Fica listado para revisar antes de produção.
- [O responsável pode aceitar propostas de dois motoristas para o mesmo filho até a fase 5 do back] → Risco assumido pelo desenvolvedor.
- [A tela de pedir orçamento lê a grade de cada dependente] → Uma chamada por dependente, só ao abrir. Responsável com muitos dependentes é raro; se pesar, o back pode mandar a grade na lista de dependentes.
- [As listas do back vêm sempre por `createdAt`] → A Início lê só a primeira página das `EXPIRED` e filtra pelo `updatedAt` dos últimos 7 dias; um pedido criado antes de outros 20 expirados e expirado depois deles fica de fora, o que é raro.
- [O prefixo do turno da rota (`deriveOperationShift`) pode não refletir a rota real do motorista] → É só o rótulo do trecho, que o back exige; os horários são do motorista. A regra fica numa função só, fácil de trocar.
- [As fases 6, 8 e 9 passam das 600 linhas da R23, as fases 10 e 14 levam os testes de cada lado depois do código, contra a R25, e as fases 11 a 13 do motorista passam das 600 linhas da R23] → Decisão do desenvolvedor no plano (R17). Os testes foram escritos antes do código; cada branch passa no `make test` sozinha porque os testes antigos que uma fase muda vão nela. Um erro de uma fase só aparece na cobertura nova quando a fase com os testes do lado entra (10 ou 14); a revisão pode seguir as seções do `tasks.md`.

## Migration Plan

Só mobile, sem migração de dados. As fases de cada lado trocam as telas de mock ou de "Em breve" pela versão real e apagam o mock na fase da tela (a lista do responsável na fase 5). Rollback é reverter o PR da fase.

### Phased delivery (R16–R23)

Branches no formato `VAN-78/<fase>-<nome>`, empilhadas a partir de `VAN-78/spec-service-request-proposal`, que nasce da `VAN-39/4-dependents-redesign-pages`.

| Fase | Conteúdo | Depende de | Em paralelo com |
|---|---|---|---|
| 1 | `Weekday` para o core; domínio de `negotiations`: entidades, value objects, rascunhos com validação, regras derivadas (D2), falhas e contratos | VAN-39 mergeada | — |
| 2 | Dados de `negotiations` (DTOs, datasources, repositórios, endpoints no `Environment`), use cases e container | Fase 1 | — |
| 3 | Core do responsável: formatadores (`formatInstallments`, datas, nomes, dias, dinheiro) e componentes (`VanepWeekLegsGrid`, chips, bolinha, preço parcelado) (VAN-42) | Fase 2 | Fase 4 |
| 4 | Regras e rótulos da negociação: comparação de versões, preço e horários, grupos de itens, horários por trecho, escolas, limite da recusa, rótulos dos enums e do histórico (D2, D7) | Fase 2 | Fase 3 |
| 5 | Lista na API com `client_proposals` reescrito, cards novos, cancelar pedido e remoção do cenário (VAN-42); a conversa abre pelo token e sai do perfil (D12) | Fases 3 e 4 | — |
| 6 | Detalhe, comparação, aceitar e "Proposta aceita" (VAN-43) | Fase 5 | — |
| 7 | Pedir ajuste e recusar (VAN-43) | Fase 6 | Fase 8 |
| 8 | Pedir orçamento na busca e no perfil (VAN-47, Propostas · 5) | Fase 6 | Fase 7 |
| 9 | Negociação na conversa (VAN-44) e Início com as negociações reais (VAN-41) | Fase 7 | — |
| 10 | Testes novos do responsável, das fases 3 a 9 | Fases 3 a 9 | — |
| 11 | Motorista: peças de leitura e formatadores comuns do `client_proposals` para o `negotiations` (D7), sem mudar o responsável; módulo `driver_proposals`, aba Propostas, lista de negociações, pedido de orçamento, recusa, ajuste solicitado e proposta só leitura (VAN-58, VAN-59, VAN-61) | Fase 10 | — |
| 12 | Motorista: montar proposta e nova versão (VAN-60, VAN-61) | Fase 11 | — |
| 13 | Motorista: negociação na conversa (VAN-62) | Fase 12 | — |
| 14 | Testes novos do motorista, das fases 11 a 13 | Fases 11 a 13 | — |

A R20 continua valendo: os contratos (fase 1) entram uma fase antes das implementações (fase 2), e por isso essas duas ficam separadas. O responsável fica em uma fase por tela (3 a 9), com a base comum na frente, e os arquivos de teste novos dele vão juntos na fase 10, por decisão do desenvolvedor. O motorista fica em três fases, na ordem em que uma liga a outra: lista, pedido, ajuste e proposta só leitura na 11, junto com as peças comuns que vão para o `negotiations`; montar proposta na 12; conversa na 13; os testes novos das três vão na fase 14, como os do responsável na fase 10. O motorista vem depois do responsável porque reaproveita a abertura da conversa pelo token, a rota da conversa da negociação (`openClientNegotiationChat`), o `NegotiationTimelineCubit`, o `VanepWeekLegsGrid` e os formatadores, que nascem nas fases 3, 5 e 9.
