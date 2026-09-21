### Entrega fatiada (R16–R23)

Cinco fases. As branches e o stash que já existem são **material de origem**: dá para refatorar e reorganizar, então a pilha nova nasce já no desenho final (rascunho compartilhado, kit em core). Motivos em `design.md` (“Estado atual do trabalho”, “Reorganização da pilha”, “Entrega fatiada”).

| Fase | Conteúdo | Branch | Depende de | Origem do código |
|----|----------|--------|------------|------------------|
| 1 | Domínio: `ibge_locations` + casa + `PostalAddressDraft` (core) | `feat/1-personal-address-domain` | — | branch 1; regras vindas de state/cubit (branches 3–4) |
| 2 | Dados: `ibge_locations` + casa, `postalAddressToJson`, `Environment`, DI | `feat/2-personal-address-data` | 1 | branch 2 |
| 3 | Cubit de dados pessoais: carga, CEP, picker, save, gênero `null`, DELETE | `feat/3-personal-data-address-cubit` | 2 | branches 3, 4 (cubit), 5 (strings) |
| 4 | UI: kit em core + dados pessoais e endereço na identidade nova + menu Endereços + 400 de cidade | `feat/4-personal-data-address-ui` | 3 | branch 4 (cartão, dropdown, menu, formatter, mapper) + stash (tela de endereço, picker, 400 de cidade) |
| 5 | Dependentes: endereço postal + select de gênero + identidade nova | `feat/5-dependent-postal-address` | 2, 4 + **API do dependente no ar** | main (`dependents`) + novo |

> **Vale para toda tarefa:** testes primeiro, vendo falhar antes de implementar (R05); fixtures em `*_fixture.dart`; copy só em ARB pt + en com l10n regenerado (R10); codegen quando houver DTO (R15); sem métodos privados (R08). Ao portar código das branches antigas, **portar os testes junto** e mantê-los passando sem mudar de intenção.
>
> **R27a:** nenhum commit sem a sua aprovação. Ao fim de cada fase rodo `make lint` e `make test` e paro para você validar no aparelho.
>
> **Exceção declarada a R19 (D14):** a fase 5 atravessa camadas de `dependents` (trocar o tipo de endereço quebra a compilação camada a camada). O contrato do `DependentRepository` não muda (R20 respeitado).

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
- [ ] 1.4 `make lint` + `make test`. **Parar para validação (R27a).**

## 2. Fase 2 — Dados (`feat/2-personal-address-data`)

- [x] 2.1 `Environment`: `cepLookupEndpoint(cep)` (só dígitos), `statesEndpoint`, `citiesEndpoint`, `userPersonalAddressEndpoint` — os quatro de uma vez.
- [x] 2.2 `lib/core/network/postal_address_body.dart`: `postalAddressToJson` — `cityToken`, `street`, `zipCode` (8 dígitos) e os **três opcionais sempre presentes** (valor ou `null`); nunca `placeId`, `sessionToken`, `stateToken`, `cityName`, `uf`.
- [x] 2.3 `ibge_locations/data`: DTOs, datasource, repositório, container. CEP 200/400/404 (dois `detail`, marcador nomeado para “catálogo”)/429/503/timeout; cities exige `uf`, UF inexistente → `ufNotFound`. Registrar em `main.dart` depois do Dio autenticado.
- [x] 2.4 `auth/data`: DTO, datasource e repositório da casa (body via `postalAddressToJson`). GET 404 → `Ok(null)`; PUT 404 → `cityNotFound`; PUT 400 (ProblemDetail genérico, sem lista por campo) → `validation`; DELETE 204 → `Ok(null)`; timeout → `network`. Registrar no `auth_container.dart`.
- [ ] 2.5 `make lint` + `make test`. **Parar para validação (R27a).**

## 3. Fase 3 — Cubit de dados pessoais (`feat/3-personal-data-address-cubit`)

Só presentation; sem layout. Nasce sobre o `PostalAddressDraft`.

- [x] 3.1 `PersonalDataState`: snapshot da casa + `PostalAddressDraft`, status do lookup, `CepFailure?`, picker; `isProfileDirty`, `isAddressDirty` (rascunho ≠ rascunho derivado do snapshot), `isAddressSavable`, `canSave`; `clearDraftGender` e `updateGender(Gender?)`; `ProfilePatchRequestBuilder.setGender(Gender?)` (`{'gender': null}`).
- [x] 3.2 Carga: `/me` e find de endereço em paralelo; 404 de endereço → ready com cartão vazio; perfil Err ou endereço Err não-404 → `loadFailed`; 200 hidrata o rascunho.
- [x] 3.3 CEP e picker: 8 dígitos → `LookupCep` com debounce de 400 ms (path só de dígitos); 200 aplica `withCepLookup`; 404/429/503 destravam o picker; `notFound` bloqueia o Salvar; `ListStates`; `ListCities` sempre com `uf`; trocar UF zera município.
- [x] 3.4 Save (PATCH → PUT): só perfil → PATCH; só casa gravável → PUT com write completo e depois `refreshUserProfile`; os dois → PATCH depois PUT; PATCH Err → sem PUT; PATCH ok + PUT Err → perfil sincronizado, rascunho fica, sem sucesso, sem refresh; PUT 400 → feedback genérico; `FEMALE` → `null` manda `"gender": null`; gênero já `null` e intacto → sem a chave. Sucesso só se todos os writes emitidos passaram.
- [x] 3.5 `clearAddress`: DELETE, no 204 zera snapshot e rascunho, `refreshUserProfile`, `syncProfile`, sem PUT e sem GET `/address`; Err mantém o snapshot. Salvar e PUT de troca **nunca** emitem DELETE.
- [x] 3.6 Ligar os use cases na factory do cubit (`auth_container.dart`). Testes de perfil atuais seguem passando.
- [ ] 3.7 `make lint` + `make test`. **Parar para validação (R27a).**

## 4. Fase 4 — UI (`feat/4-personal-data-address-ui`)

Toda de apresentação (o kit de core é UI). Identidade nova só nas telas do escopo (`personal-flow-identity`); nenhuma outra tela é restilizada. Sem Places.

**Kit em core (portado das branches 4 e do stash, apresentacional)**

- [ ] 4.1 Mover `auth_page_chrome.dart` para `lib/core/ui/vanep_page_chrome.dart` e renomear `Auth*` → `Vanep*` (`VanepAppBar`, `VanepPageHeader`, `VanepIconBadge`, `VanepBottomBar`, `VanepOutlinedPanel`, `VanepFieldRow`; `withSpacing` mantém). Atualizar `account_type_page`, `email_code_verification_page`, `password_reset_page`, `signup_page`. Prova: `make test` verde sem editar teste algum; `rg "Auth(AppBar|PageHeader|IconBadge|BottomBar|OutlinedPanel|FieldRow)" lib test` vazio.
- [ ] 4.2 `VanepGenderSelect` (extraído de `PersonalDataGenderDropdown`; quatro opções; `onChanged(Gender?)`), `genderLabel(Gender?)`, ARB de “Prefiro não informar”. `isRequired` e `VanepFieldLabel` em `VanepTextField` **sobre a versão da main**. Máscara `00000-000` em `lib/core/formatters/`.
- [ ] 4.3 `VanepPostalAddressForm` (de `PersonalAddressForm` + `PersonalAddressUfField`) e `VanepCityPickerSheet` (de `PersonalAddressCityPickerSheet`): recebem valores, controllers, estado do picker e callbacks; sem cubit, sem tipo de módulo; UF/município travados não abrem o picker.

**Dados pessoais e endereço**

- [ ] 4.4 Remover `ProfileMenuId.addresses` (enum, menu CLIENT, `profile_menu_card`, `profile_page`, ARB e testes). `rg profileAddresses lib test` vazio.
- [ ] 4.5 Copy e mapeamento: títulos, erros de CEP, erros da casa (cidade, validação genérica, rede), “Limpar endereço” + dialog + snack; mappers de `PersonalAddressFailure`, `CepFailure`, `IbgeLocationsFailure`; formatter de resumo do cartão.
- [ ] 4.6 `PersonalDataPage` na identidade nova: `VanepAppBar`; nome e telefone em `VanepTextField`; e-mail, documento e nascimento somente leitura; `VanepGenderSelect`; `CooldownBadge` abaixo do campo; Salvar do perfil em `VanepBottomBar`. Cartão de endereço em `VanepOutlinedPanel` (cadastrar em `action`; resumo; menu Editar / “Limpar endereço” em `danger`, com `showVanepConfirmDialog(isDestructive: true)`). Apagar `PersonalDataInlineField`, `PersonalDataGenderDropdown`, `ProfileGenderChoice`.
- [ ] 4.7 `PersonalAddressFormPage`: `VanepAppBar`, `VanepPostalAddressForm`, Salvar em `VanepBottomBar`, fecha no sucesso; erros via `VanepFeedback.showError`. Revisar tokens do `EmailChangeSheet`.

**400 de cidade (busca e área)**

- [ ] 4.8 `cityUnmatched` em `DriverSearchFailure` e `ServiceAreaFailure` (`driver_search`, `driver_service_areas`), copy “escolha outra sugestão”, testes. O back não manda `code`: reconhecer por `code` **ou** marcador de `detail` (como o stash). Consolidar `isIbgeCityUnmatchedProblem` (hoje duplicado) numa função em `lib/core/network/`. 400 com outro `detail` mantém o mapeamento; 200 vazio continua empty state.

**Conferências**

- [ ] 4.9 CLIENT, DRIVER e ASSISTANT chegam a dados pessoais sem banner novo; testes do banner de áreas seguem verdes. `git diff --stat` sem tela fora do escopo (exceto a linha Endereços e os imports do chrome). `rg PlaceAutocomplete lib/modules/auth` vazio.
- [ ] 4.10 `make lint` + `make test`. **Parar para validação no aparelho (R27a):** auth idêntica à de antes; dados pessoais e endereço na identidade nova.

## 5. Fase 5 — Dependentes (`feat/5-dependent-postal-address`)

Atravessa domínio, dados, cubit e formulário de `dependents` (D14); o contrato do `DependentRepository` não muda. O back (`feat/ibge-postal-address-dependent`) **não** está na main dele: construir contra o contrato combinado, datasource mockado nos testes (R21). **Não abrir PR** antes da API no ar.

- [ ] 5.1 Domínio: `DependentAddress` com `zipCode`, `neighborhood`, `cityToken` (sem `district`); `DependentDraft.address` como `PostalAddressDraft`; changes (create só se não em branco; update só se difere do snapshot; limpar quando em branco; **sem** amend de número); validação (parcial → `PostalAddressIssue`s; em branco → nada); `DependentCityNotFoundFailure`. Apagar `DependentAddressDraft` e `addressWasEdited`.
- [ ] 5.2 Dados: DTO lê `zipCode`, `neighborhood`, `cityToken` e ignora `district`. Body via `postalAddressToJson`: POST sem `address` se em branco; PATCH sem `address` se não mudou, `"address": null` se limpou, objeto completo se mudou (inclusive só número); nunca `placeId`/`sessionToken`. Falhas: POST 404 → cidade; PATCH 404 com marcador de cidade no `detail` → cidade, senão dependente; 400 → validação sem expor o `detail`; 409 → `unexpected`. Tirar `'placeId'` de `dependentFieldsByApiName`.
- [ ] 5.3 Cubit: `LookupCep`, `ListStates`, `ListCities`, updaters postais, `clearAddress`, mesma semântica de CEP da conta (vem do rascunho). Em branco salva sem `address`; parcial bloqueia o save sem request; `notFound` bloqueia o save; cidade não encontrada cai no município. Remover `choosePlace`, `changeAddressNumber`, `changeAddressComplement`, `removeAddress`.
- [ ] 5.4 Formulário: `VanepPostalAddressForm` + `VanepCityPickerSheet` **inline**; `VanepGenderSelect` (create sem gênero não manda a chave; limpar manda `"gender": null`). Apagar `DependentAddressField`, o uso de `PlaceAutocompleteController` e `VanepGenderChips` (+ teste). ARB: erros de endereço do dependente; remover a copy de Places e `dependentFieldGenderClear`. `dependentAddressLabel` → “rua, nº · complemento · bairro · Cidade - UF · CEP”. `rg PlaceAutocomplete lib/modules/dependents` e `rg VanepGenderChips lib test` vazios.
- [ ] 5.5 Identidade nova: `DependentsPage` e `DependentCard` (`VanepAppBar`; cada dependente num `VanepOutlinedPanel`, o padrão `highlighted` com badge em tom de ação; “definir como padrão” em `action`; “adicionar” em `VanepBottomBar`; carga, erro com retry e vazio no mesmo esqueleto) e chrome do `DependentFormPage` (`VanepTextField` no nome; nascimento como campo somente leitura que abre o date picker, com ação de limpar; Salvar em `VanepBottomBar`). Sem `VanepScreenBackground` nem `VanepGlassCard`; os widgets continuam existindo. `git diff --stat` só com arquivos de `dependents` (mais ARB).
- [ ] 5.6 Atualizar `openspec/changes/client-dependents`: marcar `dependent-address` como superada e apontar as tasks 5.x para esta change.
- [ ] 5.7 `make lint` + `make test`. **Parar para validação no aparelho (R27a).** Só commit; sem PR até a API estar no ar.
