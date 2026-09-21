### Entrega fatiada (R16–R23)

Seis fases. As branches e o stash que já existem são **material de origem**: dá para refatorar e reorganizar, então a pilha nova nasce já no desenho final (rascunho compartilhado, kit em core). Motivos em `design.md` (“Estado atual do trabalho”, “Reorganização da pilha”, “Entrega fatiada”).

| Fase | Conteúdo | Branch | Depende de | Origem do código |
|----|----------|--------|------------|------------------|
| 1 | Domínio: `ibge_locations` + casa + `PostalAddressDraft` (core) | `feat/1-personal-address-domain` | — | branch 1; regras vindas de state/cubit (branches 3–4) |
| 2 | Dados: `ibge_locations` + casa, `postalAddressToJson`, `Environment`, DI | `feat/2-personal-address-data` | 1 | branch 2 |
| 3 | Cubit de dados pessoais: carga, CEP, picker, save, gênero `null`, DELETE | `feat/3-personal-data-address-cubit` | 2 | branches 3, 4 (cubit), 5 (strings) |
| 4 | Kit de UI em core: chrome movido, `VanepGenderSelect` (dados pessoais e cadastro), formulário postal, picker, card do CEP, spinner no campo + 400 de cidade | `feat/4-postal-address-core-ui` | 3 | branch 4 (dropdown, formatter) + stash (picker, 400 de cidade) |
| 5 | Dados pessoais e endereço na identidade nova: flag de lookup no cubit, hidratação da casa, telas, menu Endereços | `feat/5-personal-data-address-ui` | 4 | branch 4 (cartão, mappers, menu) + stash (tela de endereço) |
| 6 | Dependentes: endereço postal + select de gênero + identidade nova | `feat/6-dependent-postal-address` | 2, 5 + **API do dependente no ar** | main (`dependents`) + novo |

> **Vale para toda tarefa:** testes primeiro, vendo falhar antes de implementar (R05); fixtures em `*_fixture.dart`; copy só em ARB pt + en com l10n regenerado (R10); codegen quando houver DTO (R15); sem métodos privados (R08). Ao portar código das branches antigas, **portar os testes junto** e mantê-los passando sem mudar de intenção.
>
> **R27a:** nenhum commit sem a sua aprovação. Ao fim de cada fase rodo `make lint` e `make test` e paro para você validar no aparelho.
>
> **Por que 4 e 5 são duas fases:** a UI era uma fase só e passou de 5 mil linhas. O kit de core (fase 4) não depende de tela nenhuma; as telas (fase 5) o consomem.
>
> **Exceção declarada a R19 (D14):** a fase 6 atravessa camadas de `dependents` (trocar o tipo de endereço quebra a compilação camada a camada). O contrato do `DependentRepository` não muda (R20 respeitado).

## 0. Reorganização da pilha (git, sem código novo)

Só com a sua aprovação. Recomendação: refazer a pilha a partir da main em vez de propagar a main por 5 merges e refatorar depois.

- [x] 0.1 Commitar esta spec em `spec/personal-address` (já contém a main desde `bba38b0`).
- [x] 0.2 Renomear as 5 branches antigas para `old/<nome>` (referência; nada é apagado). O `stash@{0}` fica intacto.
- [x] 0.3 Criar cada branch nova (nomes da tabela) **quando a fase começa**, empilhada sobre a anterior (a 1 sai de `spec/personal-address`). Portar por fase, sem `stash pop`: `git checkout old/<branch> -- <paths>` e `git show stash@{0}:<path>`. Ficam de fora `openspec/*` e `vanep_text_field.dart` do stash.
- [ ] 0.4 Depois da validação de todas as fases: você decide se descarta `old/*` e o stash.

## 1. Fase 1 — Domínio (`feat/1-personal-address-domain`)

Sem Dio, DTO nem endpoint. `auth` MUST NOT importar `ibge_locations` (`cityToken` na casa é `String`).

- [x] 1.1 `ibge_locations/domain`: `BrazilianState`, `BrazilianCity` (sem `ibge_code`), `CepLookup` (rua e bairro anuláveis), página de catálogo, `CepFailure` (`invalidFormat`, `notFound`, `cityNotInCatalog`, `rateLimited`, `unavailable`, `network`, `unexpected`), `IbgeLocationsFailure`, `IbgeLocationsRepository` e use cases `LookupCep`, `ListStates`, `ListCities`. Portar da branch 1.
- [x] 1.2 `lib/core/domain/postal_address_draft.dart`: `PostalAddressDraft`, `PostalAddressIssue`, `PostalAddressLimits` (Dart puro). Testar normalização; `isBlank`, `isComplete`, `isSavable`, `issues`; `withCepLookup` (trava cidade, **substitui** rua/bairro, trava bairro só se veio, não toca número/complemento); `withCepUnavailable` (destrava, limpa o que veio do lookup); `withCepUnknown` (idem + bloqueia até o CEP mudar); `withUf` zera município; `withCity`; caps 255/16/128/128. Portar as regras e os casos de teste dos campos soltos do state/cubit das branches 3–4.
- [x] 1.3 `auth/domain`: `PersonalAddress` (sem `googlePlaceId`, converte para rascunho), `PersonalAddressWrite` (só nasce de rascunho **gravável** — completo e sem CEP inexistente; sem chaves da API — R01), `PersonalAddressFailure` (`cityNotFound`, `validation`, `network`, `unexpected`), `PersonalAddressRepository` e use cases `FindMyPersonalAddress`, `UpsertMyPersonalAddress`, `DeleteMyPersonalAddress`.
- [x] 1.4 `make lint` + `make test`. **Parar para validação (R27a).**

## 2. Fase 2 — Dados (`feat/2-personal-address-data`)

- [x] 2.1 `Environment`: `cepLookupEndpoint(cep)` (só dígitos), `statesEndpoint`, `citiesEndpoint`, `userPersonalAddressEndpoint` — os quatro de uma vez.
- [x] 2.2 `lib/core/network/postal_address_body.dart`: `postalAddressToJson` — `cityToken`, `street`, `zipCode` (8 dígitos) e os **três opcionais sempre presentes** (valor ou `null`); nunca `placeId`, `sessionToken`, `stateToken`, `cityName`, `uf`.
- [x] 2.3 `ibge_locations/data`: DTOs, datasource, repositório, container. CEP 200/400/404 (dois `detail`, marcador nomeado para “catálogo”)/429/503/timeout; cities exige `uf`, UF inexistente → `ufNotFound`. Registrar em `main.dart` depois do Dio autenticado.
- [x] 2.4 `auth/data`: DTO, datasource e repositório da casa (body via `postalAddressToJson`). GET 404 → `Ok(null)`; PUT 404 → `cityNotFound`; PUT 400 (ProblemDetail genérico, sem lista por campo) → `validation`; DELETE 204 → `Ok(null)`; timeout → `network`. Registrar no `auth_container.dart`.
- [x] 2.5 `make lint` + `make test`. **Parar para validação (R27a).**

## 3. Fase 3 — Cubit de dados pessoais (`feat/3-personal-data-address-cubit`)

Só presentation; sem layout. Nasce sobre o `PostalAddressDraft`.

- [x] 3.1 `PersonalDataState`: snapshot da casa + `PostalAddressDraft`, status do lookup, `CepFailure?`, picker; `isProfileDirty`, `isAddressDirty` (rascunho ≠ rascunho derivado do snapshot), `isAddressSavable`, `canSave`; `clearDraftGender` e `updateGender(Gender?)`; `ProfilePatchRequestBuilder.setGender(Gender?)` (`{'gender': null}`).
- [x] 3.2 Carga: `/me` e find de endereço em paralelo; 404 de endereço → ready com cartão vazio; perfil Err ou endereço Err não-404 → `loadFailed`; 200 hidrata o rascunho.
- [x] 3.3 CEP e picker: 8 dígitos → `LookupCep` com debounce de 400 ms (path só de dígitos); 200 aplica `withCepLookup`; 404/429/503 destravam o picker; `notFound` bloqueia o Salvar; `ListStates`; `ListCities` sempre com `uf`; trocar UF zera município.
- [x] 3.4 Save (PATCH → PUT): só perfil → PATCH; só casa gravável → PUT com write completo e depois `refreshUserProfile`; os dois → PATCH depois PUT; PATCH Err → sem PUT; PATCH ok + PUT Err → perfil sincronizado, rascunho fica, sem sucesso, sem refresh; PUT 400 → feedback genérico; `FEMALE` → `null` manda `"gender": null`; gênero já `null` e intacto → sem a chave. Sucesso só se todos os writes emitidos passaram.
- [x] 3.5 `clearAddress`: DELETE, no 204 zera snapshot e rascunho, `refreshUserProfile`, `syncProfile`, sem PUT e sem GET `/address`; Err mantém o snapshot. Salvar e PUT de troca **nunca** emitem DELETE.
- [x] 3.6 Ligar os use cases na factory do cubit (`auth_container.dart`). Testes de perfil atuais seguem passando.
- [x] 3.7 `make lint` + `make test`. **Parar para validação (R27a).**

## 4. Fase 4 — Kit de UI em core (`feat/4-postal-address-core-ui`)

Só componentes reutilizáveis e o que os usa fora das telas de conta; nenhuma tela de dados pessoais muda aqui. Identidade nova de auth intacta. Sem Places.

- [x] 4.1 Mover `auth_page_chrome.dart` para `lib/core/ui/vanep_page_chrome.dart` e renomear `Auth*` → `Vanep*` (`VanepAppBar`, `VanepPageHeader`, `VanepIconBadge`, `VanepBottomBar`, `VanepOutlinedPanel`, `VanepFieldRow`; `withSpacing` mantém). Atualizar `account_type_page`, `email_code_verification_page`, `password_reset_page`, `signup_page`. Prova: `make test` verde sem editar teste algum; `rg "Auth(AppBar|PageHeader|IconBadge|BottomBar|OutlinedPanel|FieldRow)" lib test` vazio.
- [x] 4.2 `VanepGenderSelect` (quatro opções; `onChanged(Gender?)`; texto legível no tema escuro quando desabilitado), `genderLabel(Gender?)`, ARB de “Prefiro não informar”. O cadastro passa a usá-lo (`SignupForm.clearGender`, `SignupCubit.updateGender(Gender?)`; sem gênero o body do signup não leva a chave) e a data de nascimento do cadastro deixa de mostrar o horário.
- [x] 4.3 `VanepTextField`: `isRequired` e `VanepFieldLabel` **sobre a versão da main**; `isLoading` com spinner. `VanepReadOnlyField`. Máscara `00000-000` em `lib/core/formatters/`.
- [x] 4.4 `VanepPostalAddressForm`, `VanepCityPickerSheet` e `VanepCepAddressCard`: recebem valores, callbacks e `isLookingUpCep`; sem cubit, sem tipo de módulo. Rua, número e complemento sempre visíveis; a localização muda por modo (`postalLocationModeOf`): nenhuma, card do CEP (resolvido) ou UF e município (fallback manual). O card é um ícone de endereço e uma linha “Bairro, Município – UF”.
- [x] 4.5 `cityUnmatched` em `DriverSearchFailure` e `ServiceAreaFailure` (`driver_search`, `driver_service_areas`), copy “escolha outra sugestão”, testes. O back não manda `code`: reconhecer por `code` **ou** marcador de `detail`. `isIbgeCityUnmatchedProblem` numa função só em `lib/core/network/`. 400 com outro `detail` mantém o mapeamento; 200 vazio continua empty state.
- [x] 4.6 `make lint` + `make test`. **Parar para validação (R27a):** auth idêntica à de antes (só o gênero do cadastro mudou); busca e área com a mensagem nova no 400.

## 5. Fase 5 — Dados pessoais e endereço (`feat/5-personal-data-address-ui`)

Identidade nova só nas telas do escopo (`personal-flow-identity`); nenhuma outra tela é restilizada. Consome o kit da fase 4.

- [x] 5.1 Cubit: `PersonalDataState.isLookingUpCep` (do 8º dígito até a resposta, debounce incluído). Casa gravada hidratada com o bairro travado quando tem bairro (`PostalAddressDraft.fromParts`). Apagar os getters sem uso `isDirty` e `isMunicipalityLocked`.
- [x] 5.2 Remover `ProfileMenuId.addresses` (enum, menu CLIENT, `profile_menu_card`, `profile_page`, ARB e testes). `rg profileAddresses lib test` vazio.
- [x] 5.3 Copy e mapeamento: títulos, subtítulos, erros de CEP, erros da casa (cidade, validação genérica, rede), “Limpar endereço” + dialog + snack; mappers de `PersonalAddressFailure`, `CepFailure`, `IbgeLocationsFailure`; formatter de resumo do cartão.
- [x] 5.4 `PersonalDataPage` na identidade nova: `VanepAppBar` sem título + `VanepPageHeader` (título e subtítulo) no corpo; nome e telefone em `VanepTextField`; e-mail, documento e nascimento somente leitura; `VanepGenderSelect`; `CooldownBadge` abaixo do campo; Salvar do perfil em `VanepBottomBar`. Cartão de endereço em `VanepOutlinedPanel` (cadastrar em `action`; resumo; menu Editar / “Limpar endereço” em `danger`, com `showVanepConfirmDialog(isDestructive: true)`). Apagar `PersonalDataInlineField`, `PersonalDataGenderDropdown`, `ProfileGenderChoice`, `PersonalDataGenderChips` e `profileGenderLabel`.
- [x] 5.5 `PersonalAddressFormPage`: `VanepAppBar` sem título + `VanepPageHeader` no corpo, `VanepPostalAddressForm`, Salvar em `VanepBottomBar`, fecha no sucesso; erros via `VanepFeedback.showError`. Tokens do `EmailChangeSheet` na identidade nova. A lista de estados só carrega no fallback manual.
- [x] 5.6 CLIENT, DRIVER e ASSISTANT chegam a dados pessoais sem banner novo; testes do banner de áreas seguem verdes. `git diff --stat` sem tela fora do escopo (exceto a linha Endereços). `rg PlaceAutocomplete lib/modules/auth` vazio.
- [x] 5.7 `make lint` + `make test`. **Parar para validação no aparelho (R27a):** dados pessoais e endereço na identidade nova; cadastro, edição, limpar e CEP com falha.

## 6. Fase 6 — Dependentes (`feat/6-dependent-postal-address`)

Atravessa domínio, dados, cubit e formulário de `dependents` (D14); o contrato do `DependentRepository` não muda. O back (`feat/ibge-postal-address-dependent`) **não** está na main dele: construir contra o contrato combinado, datasource mockado nos testes (R21). **Não abrir PR** antes da API no ar.

- [ ] 6.1 Domínio: `DependentAddress` com `zipCode`, `neighborhood`, `cityToken` (sem `district`); `DependentDraft.address` como `PostalAddressDraft`; changes (create só se não em branco; update só se difere do snapshot; limpar quando em branco; **sem** amend de número); validação (parcial → `PostalAddressIssue`s; em branco → nada); `DependentCityNotFoundFailure`. Apagar `DependentAddressDraft` e `addressWasEdited`.
- [ ] 6.2 Dados: DTO lê `zipCode`, `neighborhood`, `cityToken` e ignora `district`. Body via `postalAddressToJson`: POST sem `address` se em branco; PATCH sem `address` se não mudou, `"address": null` se limpou, objeto completo se mudou (inclusive só número); nunca `placeId`/`sessionToken`. Falhas: POST 404 → cidade; PATCH 404 com marcador de cidade no `detail` → cidade, senão dependente; 400 → validação sem expor o `detail`; 409 → `unexpected`. Tirar `'placeId'` de `dependentFieldsByApiName`.
- [ ] 6.3 Cubit: `LookupCep`, `ListStates`, `ListCities`, updaters postais, `clearAddress`, mesma semântica de CEP da conta (vem do rascunho). Em branco salva sem `address`; parcial bloqueia o save sem request; `notFound` bloqueia o save; cidade não encontrada cai no município. Remover `choosePlace`, `changeAddressNumber`, `changeAddressComplement`, `removeAddress`.
- [ ] 6.4 Formulário: `VanepPostalAddressForm` + `VanepCityPickerSheet` **inline**; `VanepGenderSelect` (create sem gênero não manda a chave; limpar manda `"gender": null`). Apagar `DependentAddressField`, o uso de `PlaceAutocompleteController` e `VanepGenderChips` (+ teste). ARB: erros de endereço do dependente; remover a copy de Places e `dependentFieldGenderClear`. `dependentAddressLabel` → “rua, nº · complemento · bairro · Cidade - UF · CEP”. `rg PlaceAutocomplete lib/modules/dependents` e `rg VanepGenderChips lib test` vazios.
- [ ] 6.5 Identidade nova: `DependentsPage` e `DependentCard` (`VanepAppBar`; cada dependente num `VanepOutlinedPanel`, o padrão `highlighted` com badge em tom de ação; “definir como padrão” em `action`; “adicionar” em `VanepBottomBar`; carga, erro com retry e vazio no mesmo esqueleto) e chrome do `DependentFormPage` (`VanepTextField` no nome; nascimento como campo somente leitura que abre o date picker, com ação de limpar; Salvar em `VanepBottomBar`). Sem `VanepScreenBackground` nem `VanepGlassCard`; os widgets continuam existindo. `git diff --stat` só com arquivos de `dependents` (mais ARB).
- [ ] 6.6 Atualizar `openspec/changes/client-dependents`: marcar `dependent-address` como superada e apontar as tasks 5.x dela para esta change.
- [ ] 6.7 `make lint` + `make test`. **Parar para validação no aparelho (R27a).** Só commit; sem PR até a API estar no ar.
