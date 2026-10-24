Issue no Genwork: **VAN-39**. Branches no formato `VAN-39/<fase>-<nome>`.

### Entrega fatiada (R16–R23)

| Fase | Conteúdo | Depende de | Em paralelo com |
|----|----------|------------|---------------|
| 1 | Peças de core (inclusive legenda no `VanepAppBar` e `VanepSection`) e contratos de domínio (dependents, schools, contract_readiness) | — | — |
| 2 | Camada de dados dos três módulos, use cases e DI | Fase 1 mergeada; PR 3 do back para o QA manual | — |
| 3 | Todos os cubits: lista, detalhe e os quatro editores | Fase 2 mergeada | — |
| 4 | Telas de lista, detalhe e editores | Fase 3 mergeada | — |
| 5 | Wizard, modo de completar, entradas, remoção do código antigo | Fase 4 mergeada | — |

Nesta change, o desenvolvedor aceitou um teto de cerca de 1000 linhas produtivas por PR, em vez das 600 da R23. As fases 1 e 2 juntam, cada uma, duas camadas vizinhas num PR. A R20 continua valendo: toda interface entra uma fase antes da implementação dela. Toda fase termina com `make lint` e `make test` verdes e depois espera o teste manual no aparelho e a aprovação explícita antes de qualquer commit (R27a).

## 1. Fase 1 — Core e domínio (`VAN-39/1-dependents-redesign-core-domain`)

- [ ] 1.1 Testes primeiro: `test/core/domain/cpf_test.dart` (com os casos de CPF movidos do signup-form do auth) e `test/core/formatters/cpf_input_formatter_test.dart`; conferir que falham antes da mudança
- [ ] 1.2 Mover `isValidCpf`, `cpfCheckDigit` e `cpfDigitCount` para `lib/core/domain/cpf.dart`, e `CpfInputFormatter` e `formatPartialCpf` para `lib/core/formatters/cpf_input_formatter.dart`; trocar os imports de `auth` e `assistant` sem deixar cópia (`grep -rn "isValidCpf\|CpfInputFormatter" lib` mostra só as definições do core); os testes de auth e assistant continuam passando
- [ ] 1.3 Adicionar `SchoolShift` (`MORNING`, `AFTERNOON`, `NIGHT`, `FULLTIME`) em `lib/core/domain/school_shift.dart`, com `fromApi`/`toApi` como o `Gender`; conferir com `school_shift_test.dart` (ida e volta, valor desconhecido → `null`)
- [ ] 1.4 Adicionar o `includedPrimaryTypes` opcional em `PlaceAutocompleteDataSource.findSuggestions` e repassá-lo pelo `PlaceAutocompleteController`; conferir com o teste do body da requisição que ele só vai quando é passado, e que os testes do Places continuam verdes
- [ ] 1.5 Estender `VanepMenuItem`/`VanepMenuTile` com `trailingIcon` (chevron por padrão) e um widget `content` opcional embaixo do título; conferir com um teste de widget para cada um e confirmar que o menu do perfil não muda
- [ ] 1.6 Adicionar `VanepMapPlaceholder` em `lib/core/ui/` (ruas desenhadas, `pinIcon`, `label` opcional, chip `actionLabel` opcional que não faz nada, semântica de mapa ilustrativo, `TODO` citando o pré-requisito de coordenadas no back) e as chaves de l10n dele (`mapPlaceholderSemantics`, `mapAdjustAction`); conferir com um teste de widget: o rótulo aparece, tocar no chip não faz nada, o rótulo de semântica existe
- [ ] 1.7 Estender `VanepAppBar` com uma `caption` opcional embaixo do título e `actions` opcionais; título, legenda e ações são todos opcionais e cada um só aparece quando é passado; conferir com um teste de widget para cada combinação (nada, só título, título + legenda, com ações) e confirmar que as 13 chamadas atuais continuam iguais
- [ ] 1.8 Adicionar `VanepSection` em `lib/core/ui/` (título opcional em `VanepTypography.sectionTitle`, nota opcional apagada à direita como "5 dias", link de ação opcional à direita como "Editar", conteúdo obrigatório), extraído do `ProfileMenuSectionView`, que passa a usá-lo; conferir com um teste de widget (sem título, só título, título + nota, título + ação que chama o callback) e confirmar que os testes do menu do perfil continuam verdes
- [ ] 1.9 Testes primeiro para o `SchoolWeek`: regra de turno padrão no `turnOn` (dia antes, depois dia depois, depois `MORNING`), `turnOff`, `changeShift`, `dayCount`, `days` começando na segunda, igualdade por valor; depois adicionar `Weekday` e `SchoolWeek` em `dependents/domain/value_objects/` até passarem
- [ ] 1.10 Testes primeiro para o rascunho: `DependentField.document` e `DependentField.school` são rastreados pelo `DependentChanges`; `validateDependentDraft` recusa CPF inválido e aceita CPF vazio. Depois estender `Dependent` com `school` (`DependentSchool`: `token`, `name`) e `document`, e `DependentDraft` com `document` e `schoolToken`, até passarem
- [ ] 1.11 Adicionar `DependentRejectedFailure(detail)` e estender `DependentRepository` com `findSchoolDays(token)`, `replaceSchoolDays(token, SchoolWeek)` e `removeDependent(token)` (só o contrato); conferir que `dependent_failure_test.dart` cobre a igualdade da falha nova
- [ ] 1.12 Adicionar `lib/modules/schools/domain/` (`School`, `SchoolFailure`, `SchoolRepository.resolveSchool(placeId, sessionToken)`) e `lib/modules/contract_readiness/domain/` (`ContractReadiness`, `ReadinessGap`, `ContractReadinessSubject`, `ContractReadinessField`, `ContractReadinessFailure`, `ContractReadinessRepository.findReadiness(dependentTokens)`), só os contratos; conferir com um teste que `gapsOfDependent(token)` mantém só as entradas `DEPENDENT` daquele token
- [ ] 1.13 Rodar `make lint` e `make test`
- [ ] 1.14 Abrir o PR

## 2. Fase 2 — Dados, use cases e DI (`VAN-39/2-dependents-redesign-data`)

- [ ] 2.1 Testes primeiro para os DTOs de dependentes: `DependentDto` lê `school` e `document` (e a ausência deles); `dependentChangesToJson` escreve `document` (dígitos ou `null`) e `schoolToken`; o DTO de dia da grade lê e escreve `{weekday, schoolShift}`; o body do `PUT` é `{"days": [...]}`, começando na segunda, e vazio para uma semana vazia
- [ ] 2.2 Atualizar `DependentDto` (+ `DependentSchoolDto`), adicionar o DTO de dia da grade e a conversão de/para `SchoolWeek`, e rodar o `build_runner`; a 2.1 passa
- [ ] 2.3 Testes primeiro para o datasource e o repositório de dependentes: caminhos de `GET`/`PUT /{token}/school-days`, `DELETE /{token}`, 4xx com `detail` → `DependentRejectedFailure`, 404 → `DependentNotFoundFailure`, sem resposta → `DependentNetworkFailure`; depois implementar `findSchoolDays`, `replaceSchoolDays` e `removeDependent` até passarem
- [ ] 2.4 Testes primeiro para escolas: `SchoolDto` a partir do `SchoolResponseDTO` (token e nome); o datasource do resolve envia `{placeId, sessionToken}` e aceita 200 e 201; 4xx com `detail` → `SchoolFailure.rejected`. Depois adicionar `Environment.schoolResolveEndpoint`, o DTO, o datasource e o `SchoolRepositoryImpl` até passarem
- [ ] 2.5 Testes primeiro para a prontidão: o DTO lê `{ready, missing[]}` com e sem `dependentToken`; a requisição envia `dependentTokens` como parâmetro de query repetido; qualquer falha vira `ContractReadinessFailure`. Depois adicionar `Environment.contractReadinessEndpoint`, o DTO, o datasource e o `ContractReadinessRepositoryImpl` até passarem
- [ ] 2.6 Testes primeiro para `FindSchoolDays`, `ReplaceSchoolDays`, `RemoveDependent`, `ResolveSchool` e `FindContractReadiness` (cada um repassa ao repositório e devolve o `Result` dele); depois implementá-los até passarem
- [ ] 2.7 Adicionar `schools_container.dart` e `contract_readiness_container.dart`, registrá-los onde os outros containers são registrados, e registrar os use cases novos de dependentes; conferir com um teste do service locator que cada um é resolvido
- [ ] 2.8 Rodar `make lint` e `make test`; conferir manualmente school-days, remoção, resolve e prontidão contra o back local em `feat/service-request-proposal-school-days` (a prontidão só quando o PR 7 do back existir)
- [ ] 2.9 Abrir o PR

## 3. Fase 3 — Estado (`VAN-39/3-dependents-redesign-state`)

- [ ] 3.1 Testes primeiro (`bloc_test`) para o `DependentsCubit`: a carga pede a prontidão uma vez com todos os tokens; sem tokens → sem requisição; falha na prontidão → `readinessByToken == null` e a lista carregada mesmo assim; `replaceDependent`, `addDependent` e `removeDependent` mantêm a ordem do back; `removeDependent` recarrega para pegar o padrão promovido; `refreshReadiness` depois de uma mudança; definir padrão atualiza as duas linhas. Depois implementar as mudanças no `DependentsCubit` e no `DependentsState` até passarem
- [ ] 3.2 Testes primeiro para o `DependentDetailCubit`: carregando → carregado(`SchoolWeek`); falha → falhou e tentar de novo; `applySavedWeek` troca a grade. Depois implementá-lo e registrá-lo como factory que recebe o token até passarem
- [ ] 3.3 Testes primeiro para o `DependentPersonalDataCubit`: criação e edição; salvar desabilitado enquanto nada mudou; o `PATCH` leva só os campos tocados (só o nome, `document: null` ao apagar, `gender: null` para não informado); CPF inválido e data no futuro impedem salvar; a falha mantém o rascunho. Depois implementá-lo até passarem
- [ ] 3.4 Testes primeiro para o `DependentPickupCubit`, movendo os casos de endereço de `dependent_form_cubit_address_test.dart`; salvar toca só `address`. Depois implementá-lo a partir da metade de endereço do `DependentFormCubit` (movida, não copiada) até passarem
- [ ] 3.5 Testes primeiro para o `DependentSchoolCubit`: pré-seleciona a escola atual; salvar desabilitado para a mesma escola; resolve e depois atualização; uma recusa no resolve mantém a seleção e mostra o detail; uma falha na atualização mantém a seleção; a sessão do Places é encerrada depois de um resolve com sucesso. Depois implementá-lo até passarem
- [ ] 3.6 Testes primeiro para o `DependentSchoolDaysCubit`: carga, ligar/desligar e troca de turno pelo `SchoolWeek`, salvar desabilitado enquanto igual à semana carregada, sucesso emite a semana salva, falha mantém as edições. Depois implementá-lo até passarem
- [ ] 3.7 Rodar `make lint` e `make test`
- [ ] 3.8 Abrir o PR

## 4. Fase 4 — Telas (`VAN-39/4-dependents-redesign-pages`)

- [ ] 4.1 Testes primeiro para `describeSchoolWeekBar` (sete segmentos começando na segunda; `MORNING`/`AFTERNOON`/`NIGHT` → meio período, `FULLTIME` → integral, desligado → nenhum; contagem de dias com aula para o rótulo do leitor de tela) e `dependentReadinessItems` (ordem, itens feitos, `n de 4`, campo → passo do wizard); depois implementar os dois em `dependents/presentation/formatters/` até passarem
- [ ] 4.2 Testes de widget primeiro para a lista: título da linha com `· Padrão`, subtítulo com idade e escola, linha âmbar de incompleto só quando a prontidão aponta lacunas, estado vazio, skeleton, erro com tentar de novo. Depois refazer a `DependentsPage` (cabeçalho com botão de adicionar, linhas agrupadas, "Adicionar dependente") até passarem; os botões de adicionar continuam abrindo o formulário antigo até a fase 5
- [ ] 4.3 Testes de widget primeiro para o detalhe: card de cabeçalho; card de prontidão só quando não está pronto; regras de "Não informado"; linha Dias e turnos com título e barra de sete dias (sem resumo em texto, skeleton enquanto carrega, tentar de novo na falha, semântica "Dias e turnos, n dias"); linhas Van/Contrato não fazem nada; "Definir como padrão" no menu ⋮ só com 2 ou mais dependentes e quando não é o padrão; confirmação de remoção → sucesso volta para a lista, falha continua no detalhe. Depois implementar a `DependentDetailPage`, que lê o dependente do `DependentsCubit` pelo token e abre a partir das linhas da lista, até passarem
- [ ] 4.4 Testes de widget primeiro para Dados pessoais (quatro campos, máscara de CPF, mensagens de validação, salvar desabilitado enquanto nada mudou, devolve o dependente salvo) e Embarque (mapa estático com "Ajustar no mapa" sem ação, formulário preenchido, salvar devolve o dependente, adaptado de `dependent_address_form_page_test.dart`). Depois implementar `DependentPersonalDataBody`/`Page` e `DependentPickupBody`/`Page` até passarem
- [ ] 4.5 Testes de widget primeiro para Escola (resultados da busca, escola atual pré-selecionada, a seleção atualiza o rótulo do mapa, salvar desabilitado para a mesma escola, mensagem de falha na busca) e Dias e turnos (sete linhas começando na segunda, contador, rótulo de semântica do switch, seletor com os quatro turnos, "Sem aula" quando desligado, salvar desabilitado enquanto nada mudou). Depois implementar `DependentSchoolBody`/`Page` e `DependentSchoolDaysBody`/`Page` até passarem
- [ ] 4.6 Ligar as linhas do detalhe aos quatro editores e entregar os resultados ao `DependentsCubit` / `DependentDetailCubit`, mais `refreshReadiness`; conferir com um teste de widget do detalhe por linha
- [ ] 4.7 Adicionar todos os textos novos em `app_pt.arb` e `app_en.arb`
- [ ] 4.8 Rodar `make lint` e `make test`
- [ ] 4.9 Abrir o PR

## 5. Fase 5 — Wizard e limpeza (`VAN-39/5-dependents-redesign-wizard`)

- [ ] 5.1 Testes primeiro para o `DependentWizardCubit`: o modo de criação tem quatro passos e o passo 1 não pode ser pulado; o modo de completar monta os passos a partir das lacunas de prontidão, na ordem da criação; pular avança sem salvar; a falha de um passo mantém o passo; voltar do passo 1 no modo de criação termina sem dependente; voltar depois disso termina com o dependente criado. Depois implementá-lo até passarem
- [ ] 5.2 Testes de widget primeiro para a rota do wizard: legenda "Passo n de N", "Continuar"/"Concluir"/"Pular", o detalhe substitui o wizard no fim, o voltar segue a spec, e a lista inclui o dependente novo. Depois implementar a `DependentWizardPage`, reaproveitando os quatro corpos de editor com a barra inferior do wizard, até passarem
- [ ] 5.3 Apontar os botões de adicionar da lista e o botão "Completar cadastro" do detalhe para o wizard; conferir com testes de widget da lista e do detalhe
- [ ] 5.4 Apagar `DependentFormPage`, `DependentAddressFormPage`, `DependentCard`, `DependentFormCubit`, `DependentFormState`, os testes deles e qualquer helper que ficar sem uso; `grep -rn "DependentFormCubit\|DependentFormPage\|DependentCard" lib test` não encontra nada
- [ ] 5.5 Adicionar todos os textos novos em `app_pt.arb` e `app_en.arb`, e remover as chaves que só as telas apagadas usavam
- [ ] 5.6 Rodar `make lint` e `make test`; testar manualmente o fluxo inteiro contra o back local (criar com todos os passos, criar pulando, completar pelo detalhe, editar cada editor, definir padrão, remover)
- [ ] 5.7 Abrir o PR
