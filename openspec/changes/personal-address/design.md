## Context

Motivação em `proposal.md`. Contrato em `specs/`: `personal-address`, `postal-address-form`, `dependent-postal-address`, `gender-select`, `personal-flow-identity`, `places-ibge-city-match`.

**Estado atual do trabalho (branches locais, sem push e sem PR).** Já existe uma pilha de branches por merge (`feat/1-personal-address-domain` ⊂ `feat/2-personal-address-data` ⊂ `feat/3-personal-data-address-cubit` ⊂ `feat/4-personal-data-address-save` ⊂ `feat/5-personal-address-delete`), todas baseadas na main **anterior** ao N-177, mais um `stash@{0}` sobre a ponta da 5. Elas são o **material de origem** desta change, não um limite: as fases podem ser reorganizadas e refeitas onde for preciso, e a pilha final tem **5 fases** (ver “Entrega fatiada”). O que há nelas:

- **branch 1 — domínio:** `ibge_locations/domain` completo e `auth/domain` da casa (`PersonalAddress`, `PersonalAddressWrite` com `toJsonMap()` e builder, falhas, repositório, use cases).
- **branch 2 — dados:** DTOs, datasources, repositórios, containers e `Environment` dos dois módulos.
- **branch 3 — cubit:** carga, CEP, picker; o cubit já tem `updateZipCode`, `lookupDraftCep`, `openCityPicker`, `refreshStates`, `selectUf`, `refreshCities`, `selectCity`, `save`, `clearAddress`.
- **branch 4 — save + parte da UI:** `save()` (PATCH → PUT), `PersonalDataAddressCard` na página, `PersonalDataGenderDropdown` (select de gênero, com `ProfileGenderChoice`), remoção do item Endereços do menu, formatter `personal_address_display`, mapper `personal_address_failure_l10n`, ARB.
- **branch 5 — DELETE:** strings de ARB de “limpar endereço”.
- **`stash@{0}` — resto da UI e o 400 de cidade:** `PersonalAddressFormPage`, `PersonalAddressCityPickerSheet`, `PersonalAddressUfField`, o 400 de cidade IBGE em `driversearch` / `driverserviceareas`, testes, e as tasks 5.1–5.14 do plano antigo marcadas `[x]`. Também uma edição de `vanep_text_field.dart` (que a main reescreveu) e edições obsoletas de `openspec/`.

Decisões de comportamento que o código e o stash já têm e que esta change **adota** (não redecide): o endereço é editado numa **página própria** (`PersonalAddressFormPage`), aberta por um cartão com resumo e menu Editar / Limpar endereço, com Salvar próprio; o Salvar da página de dados pessoais só liga com o perfil sujo; o CEP 200 **trava** UF e município (e o bairro, se veio), **substitui** rua e bairro, e uma falha do lookup **destrava** o picker; `CepFailure.notFound` **bloqueia** o Salvar até trocar o CEP. Tudo isso está nas specs.

Estado atual do app (main depois do N-177, do módulo de dependentes e do refactor de interface do PR #69) em que este design se apoia:

- **Refactor de interface (main, PR #69).** O app saiu do tema escuro para o claro: `VanepTheme.dark()` deu lugar a `VanepTheme.light()`, e os tokens escuros (`backgroundDeep`, `backgroundMid`, `backgroundSoft`, `foreground`, `brand`, `glow*`, `glass*`, `surfaceGradient*`) foram apagados. `VanepGlassCard`, `VanepGradientBackground` e `VanepScreenBackground` **não existem mais**. Entraram `VanepCard`, `VanepMenuCard`, `VanepHomeTopBar`, `VanepComingSoonPage` e `VanepSkeleton`. A gestão de conta saiu da `ProfilePage` (apagada) para uma gaveta lateral: `lib/shell/shell_account_drawer.dart` + `auth/presentation/widgets/account_drawer.dart`, que hoje é dona de `handleProfileMenuSelection`. Os tokens claros em que esta change se apoia (`card`, `action`, `textPrimary`, `textSecondary`, `textMuted`, `cardBorder`, `inputBorder`, `placeholder`, `divider`, `danger`) sobreviveram intactos.

- Na main, `PersonalDataPage` + `PersonalDataCubit` carregam `GET /api/user/me` e gravam nome/telefone/gênero no `PATCH /api/user/me`. E-mail é um sheet à parte. A página é um `Scaffold` + `AppBar` com campos de sublinhado inline (`PersonalDataInlineField` em `PersonalDataRow`) e gênero em chips. Não há bloco de endereço nem chamada a `/api/user/me/address`. (As branches 3 a 5 já mudam isso; ver acima.)
- `OnboardingStep.personalAddress` já mapeia `PERSONAL_ADDRESS`. Nada na UI lê isso. `SERVICE_AREA` é banner pulável só no `DriverShell`.
- Autocomplete do Places vive em `lib/core/places/` + `VanepPlaceAutocompleteField` e é usado por **busca**, **área de atuação** e, hoje, pelo **formulário de dependente**. Esta change tira o Places da casa e do dependente. Chaves Android/iOS do Places continuam só para busca e áreas.
- Menu de perfil do CLIENT tem `ProfileMenuId.addresses` desabilitado. `dependents` já está `enabled: true`. Menus de motorista e assistente não têm `addresses`.
- **Dependentes (main):** módulo `lib/modules/dependents/` completo. `DependentAddress` tem `street`, `number`, `complement`, `district`, `cityName`, `stateUf`. `DependentAddressDraft` guarda `placeId` + `sessionToken` + `label` + `number` + `complement`; `addressWasEdited` reconhece “só número/complemento mudou” e o body manda `address` sem `placeId` (amend). O formulário usa `VanepPlaceAutocompleteField` e `PlaceAutocompleteController`. Gênero é `VanepGenderChips` + botão “Não informar”. Páginas usam `Scaffold` + `AppBar` e o kit visual da main (`VanepCard`, `VanepSkeletonList`).
- **Auth nativo (main):** telas de login/cadastro/verificação/reset com a identidade nova. `VanepTextField` (rótulo acima, borda 10, foco `VanepColors.action`) e `VanepPrimaryButton` (`action`, raio 10) foram **alterados em `lib/core/ui/`**; o chrome de página (`AuthAppBar`, `AuthPageHeader`, `AuthIconBadge`, `AuthBottomBar`, `AuthOutlinedPanel`, `AuthFieldRow`, `withSpacing`) mora em `lib/modules/auth/presentation/widgets/auth_page_chrome.dart`. Tokens novos: `VanepColors.action`, `success`, `inputBorder`, `cardBorder`, `placeholder`; `VanepTypography.fieldLabel`, `fieldValue`, `loginTitle`.
- `Gender` e o formatador de nascimento moram em `lib/core/`. `readProblemDetail` / `readProblemField` em `lib/core/network/problem_detail.dart`. Diretórios de módulo em `snake_case` (`driver_search`, `driver_service_areas`).
- `AuthRepository` é dono de OAuth, sessão e PATCH/refresh do perfil. Constituição: Clean Architecture, `Result<E, T>`, módulos por feature, teste primeiro, UI de core (R10a/R10b), copy só em ARB, R40a, PRs fatiados (R16–R23), contrato e impl em PRs separados (R20), commit só com validação no aparelho (R27a).
- Busca já distingue 400 genérico (`placeNotResolved`) de 200 vazio. Área de atuação já mapeia 400 por recortes de `detail` (`districtRequiredMarker`, `tooManyAreasMarker`). Nenhum dos dois trata cidade sem município IBGE.

Contrato do back (breaking, mesmo release; branch `feat/ibge-postal-address-dependent` do `vanep-api-java`, fases 1–7 do change `ibge-postal-address`):

- **Casa:** GET `/address` 200/404; PUT upsert 200 com DTO postal (sem `googlePlaceId`); DELETE 204 idempotente; PUT 404 se `cityToken` desconhecido; PUT 400 de Bean Validation. PUT e DELETE não devolvem onboarding. `pendingSteps` é calculado no `GET /me` com `addressId == null`.
- **Catálogo:** `GET /api/cep/{cep}` (200 / 400 / 404 CEP ou sem `ibge_code` no catálogo / 429 / 503), `GET /api/states`, `GET /api/cities?uf=` (só municípios ativos; sem `uf` é 400). Os três exigem só autenticação, sem permissão extra.
- **Dependente:** `POST/PATCH /api/dependent` com `address` = `DependentAddressRequestDTO` (`cityToken`, `street`, `zipCode` de 8 dígitos obrigatórios; `number`/`complement`/`neighborhood` opcionais). `placeId` e `sessionToken` são ignorados e o Places nunca é chamado. No POST `address` é opcional, mas se vier exige os três. No PATCH, `address` presente **sobrescreve a mesma linha** (`address.id` igual), opcional omitido/`null` fica `null`; `address` parcial é **400**; `address: null` limpa (soft-delete da linha); `address` omitido não mexe. 404 `city.not_found` para `cityToken` desconhecido ou inativo; 409 `address.already_owned` se a linha é também de escola. `AddressResponseDTO` (dependente): `token`, `zipCode`, `street`, `number`, `complement`, `neighborhood`, `district` (nulo nesse caminho), `cityToken`, `cityName`, `stateUf`, `active`, `createdAt` — **sem** `countryIsoCode`.
- **Formato dos erros (verificado no código do back):** Bean Validation cai no `ResponseEntityExceptionHandler` do Spring — ProblemDetail padrão, `detail` genérico (“Invalid request content.”), **sem lista por campo**. Os 400/404 de localização e de CEP saem de `ProblemDetail.forStatusAndDetail(status, mensagem)` — **sem campo `code`**, só `detail` localizado. Os 404 de `dependent.not_found`, `city.not_found` e `school.not_found` são `ResponseStatusException` com `detail` localizado.

## Goals / Non-Goals

**Goals:**

- Repositório de endereço no `auth` + UF/município/CEP num módulo `ibge_locations`, orquestrados pelo cubit de dados pessoais que já existe, mesma tela para os três papéis.
- 404 no GET `/address` é `Ok(ausente)` no domínio, nunca falha de carga da tela.
- Body de escrita postal único (`cityToken` + `street` + `zipCode` + opcionais), usado pela casa e pelo dependente. DTO da resposta é o snapshot novo; `/me` só dá refresh depois do PUT ok.
- CEP só via `GET /api/cep/{cep}`; picker UF → município quando o CEP falha ou a pessoa preenche na mão.
- **Um** rascunho postal, **um** formulário e **um** picker, compartilhados pela casa e pelo dependente.
- Endereço do dependente no contrato postal, com PATCH de replace total e `null` que limpa.
- Limpar a casa é `DELETE /address` (204). Trocar de casa continua PUT, sem DELETE antes.
- Apagar o item Endereços do menu e a copy.
- Gênero em select único compartilhado; Prefiro não informar é `null`, não um valor novo no enum.
- Identidade visual nova em dados pessoais + endereço e dependentes, e só nelas.
- Busca e área de atuação mapeiam o 400 de cidade sem município IBGE para copy de “outra sugestão”.

**Non-Goals:**

- Banner ou skip de `PERSONAL_ADDRESS` em qualquer shell.
- Mudar o onboarding de `SERVICE_AREA` além do 400 de cidade IBGE.
- `POST /api/schools/resolve`, `schoolToken`, `shift`, delete de dependente, geocoding, lat/lng, mini-mapa, `/api/geo`, `GET /api/countries`.
- Place Details / ViaCEP no app.
- Recusar município no form por cobertura operacional.
- Mandar DELETE antes de um PUT que só altera a casa.
- Mexer em endereço de dependente quando a casa da conta some.
- Restilizar qualquer tela fora do escopo de identidade (perfil, shells, busca, áreas, home).

## Decisions

### D1 — Endereço no `auth`; IBGE em módulo próprio

O recurso da casa é `/api/user/me/address` e a única tela é `PersonalDataPage`. Módulo novo só para a casa forçaria import cruzado na presentation do `auth` (R02). GET/PUT/DELETE e 404-como-vazio não cabem no `AuthRepository` (não é falha de sessão).

CEP, UFs e municípios **não** são o recurso da casa. O dependente usa o mesmo catálogo (agora, não “depois”). Colocar `GET /api/states` dentro do `auth` misturaria OAuth com IBGE.

```
ibge_locations/
  domain/   BrazilianState, BrazilianCity, CepLookup, IbgeLocationsFailure / CepFailure,
            IbgeLocationsRepository, LookupCep, ListStates, ListCities
  data/     DTOs (página Spring em `content` / `totalElements` / `totalPages` /
            `number` / `size`), datasource, impl
  ibge_locations_container.dart

auth/
  domain/   PersonalAddress, PersonalAddressWrite, PersonalAddressFailure,
            PersonalAddressRepository, FindMyPersonalAddress,
            UpsertMyPersonalAddress, DeleteMyPersonalAddress
  data/     DTO postal, datasource remoto, impl
  presentation/
            PersonalDataCubit carrega perfil + casa, CEP, picker, PATCH/PUT/DELETE
```

`PersonalDataCubit` e `DependentFormCubit` consomem os use cases de `ibge_locations` **pelo contrato de domínio** (R02). `main.dart` registra `ibge_locations` depois do Dio autenticado do auth, no mesmo molde de `driver_search`.

Endpoints no `Environment` (todos em `authBaseUrl`; `dependentsEndpoint` já existe):

- `userPersonalAddressEndpoint` → `/api/user/me/address`
- `cepLookupEndpoint(cep)` → `/api/cep/{cep}` (só dígitos)
- `statesEndpoint` → `/api/states`
- `citiesEndpoint` → `/api/cities`

**Rejeitado:** `lib/modules/personaladdress/` novo. **Rejeitado:** métodos no `AuthRepository`. **Rejeitado:** IBGE dentro do `auth` (trava o dependente). **Rejeitado:** `lib/core/ibge_locations/` (o módulo já tem entidade e falha de domínio; o que é compartilhado de verdade é o rascunho e a UI — D12). **Rejeitado:** `GET /api/cities/{token}` nesta change — GET `/address` e o PUT 200 já trazem `cityName` / `cityToken` / `stateUf`.

### D2 — Um cubit dono dos dois drafts (R06a)

`PersonalDataState` ganha o snapshot da casa (`PersonalAddress?`) e o rascunho do endereço, mais o status do lookup de CEP, a falha de CEP, `isNeighborhoodLocked` e o estado do picker (UFs, município, busca, aberto). Widget não guarda flag paralelo de “salvo vs sujo”.

**Material de origem (branches 3/4):** o rascunho são oito campos soltos (`draftZipCode`, `draftCityToken`, `draftCityName`, `draftUf`, `draftStreet`, `draftNeighborhood`, `draftNumber`, `draftComplement`) com `isNeighborhoodLocked` e getters `isProfileDirty`, `isAddressDirty`, `isAddressSavable` (que já considera `cepFailureBlocksSave`), `isMunicipalityLocked`. **Na pilha nova** o estado nasce com **um** `PostalAddressDraft` de core (D12): as regras e os testes são portados dos campos soltos, com o mesmo comportamento.

Sujo:

| Fatia | Sujo quando |
|---|---|
| Perfil | nome / telefone / gênero diferem do snapshot (`null` de gênero conta: mudou de `FEMALE` para omitido é sujo) |
| Casa | o `PostalAddressDraft` difere do rascunho derivado do snapshot (snapshot ausente = rascunho em branco). A igualdade do rascunho já normaliza: `null` e string vazia são iguais nos opcionais, CEP compara só dígitos |

Casa gravável (`isAddressSavable`): está suja **e** o rascunho é completo (`cityToken` + rua + CEP de 8 dígitos) **e** o lookup não foi 404 de CEP inexistente (`CepFailure.notFound`). Número / complemento / bairro sozinhos não ligam o Salvar.

`canSave` com status ready e (perfil sujo **ou** casa gravável).

Trocar a UF no picker zera `cityToken` / `cityName` até um município novo (regra do rascunho). Sem `cityToken` a casa deixa de ser gravável.

Gênero: `updateGender(Gender?)`. Prefiro não informar é `null` (D11). O `copyWith` precisa de `clearDraftGender`, senão nunca dá para selecionar omitido.

### D3 — Carga: `/me` e `/address` em paralelo; só 404 é ausência

```
refreshUserProfile() ─┐
                      ├─ os dois Ok → ready (endereço pode ser null)
findMyAddress()     ─┘
                      ─ perfil Err → loadFailed (como hoje)
                      ─ endereço Err (não ausente) → loadFailed
                      ─ endereço Ok(null) vindo de 404 → ready, bloco vazio
```

Repositório da casa:

- HTTP 404 → `Ok(null)`
- demais falhas do Dio → `Err(PersonalAddressFailure…)`

Ausência não se infere de `pendingSteps`, e `pendingSteps` não se infere de 404.

Lookup de CEP e picker **não** rodam na carga. Com casa 200, hidratar o rascunho a partir do snapshot (`cityToken`, `cityName`, `stateUf`, `street`, `zipCode`, `neighborhood`, `number`, `complement`). `district*` ignorados na UI.

**Rejeitado:** tela ready com seção de endereço quebrada no 500.

### D4 — CEP é prefill; PUT é replace total; o mapa da API não vive no domínio

Lookup só com 8 dígitos no path. Debounce **400 ms** depois do 8º dígito. Strip do hífen **antes** de GET e de write. Não consultar com `70040-010` no path.

HTTP 200 (regra do rascunho, o que o cubit já faz):

- sempre aplica `cityToken` / `cityName` / `uf` e **trava** UF e município (o município do ViaCEP é 1:1 com o `cityToken`)
- **substitui** `street` / `neighborhood` (nulo vira vazio; não mescla com o rascunho); se `neighborhood` veio preenchido, **trava** o bairro, senão o campo fica aberto
- nunca preenche nem apaga número e complemento
- mudar o CEP (8 dígitos de novo) consulta de novo e substitui cidade/UF/rua/bairro; o travamento do bairro segue o lookup novo
- não emite write

404 (município fora do catálogo), 429 e 503: mensagem localizada distinta e **destrava** o picker; o CEP digitado fica; rua, bairro, UF e município do lookup anterior saem e o bairro fica aberto; número e complemento ficam. 404 de **CEP inexistente** faz o mesmo **e** bloqueia o Salvar até trocar o CEP (escolher UF/município não limpa a falha). 400 de formato: não deveria sair do app se o cubit só consulta com 8 dígitos; ainda mapeia para falha de formato.

O app MUST NOT chamar `viacep.com.br`.

Write da casa. `PersonalAddressWrite` (domínio do `auth`) só **prova** que o rascunho estava gravável: `personalAddressWriteFromDraft` devolve `null` se o rascunho não for completo **ou** tiver o CEP dado como inexistente. O mapa com as chaves da API (`cityToken`, `street`, `zipCode`, e `number` / `complement` / `neighborhood` **sempre presentes**, string ou JSON `null`) é montado **uma vez**, numa função top-level em `lib/core/network/` (`postalAddressToJson`), usada pelo datasource da casa e pelo do dependente. Chaves da API não entram no domínio (R01). Nas branches antigas o mapa está em `toJsonMap()` / `personalAddressWriteToJsonMap` dentro do write, com um builder; isso **não é portado**. O comportamento e os testes de body são os mesmos; muda só quem monta o mapa.

Body do PUT 200 é o DTO do GET. O cubit troca o snapshot por esse JSON e reseta o rascunho para ele. Sem GET extra de `/address`.

Picker sem esperar falha de CEP: a pessoa pode abrir UF/município com CEP vazio. Sempre `uf` nas cidades. UFs: `size=30`, `sort=name,asc` (27 cabem). Cidades: default `size=20`, `sort=name,asc`; search depois de 2 ou 3 caracteres, ou primeira página sem search (DF = Brasília). Não chamar `/api/cities` sem `uf`.

**Rejeitado:** mandar `placeId` “por compatibilidade”. **Rejeitado:** cidade texto livre. **Rejeitado:** ViaCEP no client para “já ir preenchendo”. **Rejeitado:** o mapa da API dentro de `PersonalAddressWrite` (repetiria as chaves no dependente e poria nome de API no domínio).

### D5 — Sequência do Salvar

```
save:
  se perfilSujo
        PATCH /me
        no Err → erros de campo / snack de erro; PARA (sem PUT)
        no Ok  → syncProfile(resultadoDoPatch)
  se casaGravavel
        PUT /address   (body postal completo)
        no Err → snack de erro de endereço; rascunhos ficam; sem snack de sucesso; PARA
        no Ok  → aplica o JSON do PUT como snapshot
        refreshUserProfile()
        no Ok  → syncProfile(atualizado)   // tira PERSONAL_ADDRESS
        no Err → casa está gravada; pendingSteps pode ficar velho até o próximo refresh;
                 snack de sucesso mesmo assim (os writes pedidos passaram)
  snack de sucesso só se todos os writes emitidos passaram
```

Refresh do `/me` só roda quando o PUT rodou e passou. PATCH sozinho já devolve `UserProfile`; essa resposta não sabe da casa.

Salvar MUST NOT emitir DELETE. Ficar sem casa é outra ação (D8).

**Rejeitado:** PUT depois PATCH. **Rejeitado:** snack de sucesso depois do PATCH com PUT ainda falho.

### D6 — Falhas enumeradas e localizadas (R10)

Mesmo molde das áreas: mapear status + `detail` (marcador de texto, porque o back não manda `code`) para um enum pequeno, depois ARB. Não renderizar a string do back no widget.

Casa (`PersonalAddressFailure`): `cityNotFound` (PUT 404), `validation` (PUT 400, **sem** mapa por campo — o back não devolve; as pendências por campo vêm de `PostalAddressDraft.issues`), `network`, `unexpected`.

CEP (`CepFailure`): `invalidFormat` (400), `notFound` (404 CEP), `cityNotInCatalog` (404 município), `rateLimited` (429), `unavailable` (503), `network`, `unexpected`. Distinguir os dois 404 pelo `detail` (marcador de “catálogo”). `notFound` bloqueia o Salvar até o CEP mudar (D2); os outros 404, o 429 e o 503 só destravam o picker.

IBGE (`IbgeLocationsFailure`): `ufMissing` (não emitir; defesa se 400), `ufNotFound` (404), `network`, `unexpected`.

Dependente: D14. Busca / área: D10.

Caps no client (espelho do Bean Validation, `PostalAddressLimits`): rua 255, número 16, complemento 128, bairro 128. CEP: só dígitos no domínio.

### D7 — UI de dados pessoais: cartão de endereço + tela de endereço, sem Places

**Material de origem (branch 4 + stash):**

- `PersonalDataPage` tem o cartão de dados pessoais e o `PersonalDataAddressCard`. Sem casa: ícone de casa + texto de vazio + botão “Cadastrar endereço”. Com casa: `PersonalAddressSummaryTile` (linha de resumo pelo formatter `personal_address_display`) + `PersonalAddressCardMenu` (menu ⋮ com **Editar** e **Limpar endereço**, este em `danger`). O rodapé Salvar da página liga só com o perfil sujo.
- Cadastrar/Editar abre `PersonalAddressFormPage` (tela própria, compartilhando o mesmo `PersonalDataCubit` por `BlocProvider.value`): `PersonalAddressForm` com CEP mascarado, UF (`PersonalAddressUfField`), município (abre `PersonalAddressCityPickerSheet`), rua, número, complemento, bairro, campos obrigatórios marcados, e Salvar próprio ligado a `isAddressSavable`. Sucesso fecha a página. Erro de endereço vai por `VanepFeedback.showError` com a string mapeada.
- Limpar: `showVanepConfirmDialog(isDestructive: true)` → `cubit.clearAddress()`.
- **Não** há `VanepPlaceAutocompleteField` nem `PlaceAutocompleteController` nessas telas.

**Na pilha nova:** o comportamento acima é o alvo e **não muda**. O que muda é (a) onde o form e o picker moram — `PersonalAddressForm` e `PersonalAddressCityPickerSheet` leem `PersonalDataCubit` direto e o dependente não pode importá-los; nascem como `VanepPostalAddressForm` e `VanepCityPickerSheet` em core, apresentacionais (D12), e as telas de `auth` só os hospedam; (b) o visual (D13). O `PersonalDataInlineField` e o `PersonalDataGenderDropdown`/`ProfileGenderChoice` locais deixam de existir (D11, D13). O formatter `personal_address_display` continua (o cartão precisa da linha de resumo); o do dependente é outro (D14).

**Rejeitado (o que eu tinha escrito antes de olhar o código):** formulário inline dentro da página de dados pessoais, sem cartão e sem tela própria. Contradiz a UI já implementada e validada.

### D8 — Limpar a casa é DELETE, não um PUT vazio e não o Salvar

O back expõe `DELETE /api/user/me/address` (Bearer, sem body). **204** se tinha endereço ou se já estava vazio. Sem JSON. **401** sem token. GET `/address` seguinte é 404; GET `/me` seguinte lista de novo `PERSONAL_ADDRESS`.

Alterar a casa continua `PUT`. O app MUST NOT deletar antes de um PUT. Dependente não entra neste recurso.

Contrato: `deleteMyAddress()` → `Result<PersonalAddressFailure, void>`. 204 é `Ok(null)` (sucesso vazio, igual `signOut`). Falhas: rede → `network`; outro status (exceto 401 do interceptor) → `unexpected`. DELETE não devolve 404 nem 400 neste contrato.

Cubit: ação própria (`clearAddress`), não um draft que espera o Salvar. No 204:

1. zera snapshot e rascunho de endereço
2. `refreshUserProfile()` para `PERSONAL_ADDRESS` voltar a `pendingSteps`
3. no Ok do refresh → `syncProfile`
4. no Err do refresh → a casa já não está no back; flag da sessão pode ficar velha (mesmo molde de R2, invertido)
5. snack de sucesso de limpeza só se o DELETE passou; Err → snack de erro, snapshot fica

Não chama GET `/address` depois do 204.

**Rejeitado:** PUT sem `cityToken` para “apagar”. **Rejeitado:** DELETE no fluxo do Salvar.

### D9 — Remover `ProfileMenuId.addresses` por completo

Apagar o valor do enum, a entrada do menu CLIENT, o case no-op do handler de menu, o ícone em `profile_menu_card`, chaves ARB `profileAddresses` e testes que esperam a linha. Não deixar stub desabilitado. `ProfileMenuId.dependents` fica como está.

**Origem:** já feito na branch 4 (enum, menu CLIENT, handler, `profile_menu_card`, ARB); é portado como está.

**Onde mora o handler.** A `ProfilePage` não existe mais: a main (PR #69) moveu o menu de conta para uma gaveta lateral e `handleProfileMenuSelection` foi de `auth/presentation/pages/profile_page.dart` para `auth/presentation/widgets/account_drawer.dart` (a gaveta é montada por `lib/shell/shell_account_drawer.dart`). É nesse arquivo que o case de `addresses` sai.

Papéis compartilham a `PersonalDataPage`; shells não mexem. Sem banner de `PERSONAL_ADDRESS`. Banner de `SERVICE_AREA` do motorista fica. A gaveta de conta só perde a linha; não é restilizada (D13).

### D10 — 400 de cidade sem município IBGE não é lista vazia

Busca hoje mapeia **qualquer** 400 para `placeNotResolved`. Área mapeia 400 por recortes de `detail`.

Acrescentar falha `cityUnmatched` nos dois módulos (`driver_search`, `driver_service_areas`). O back **não manda `code`**: mapear 400 quando o `detail` traz o marcador de “município brasileiro” (mesma técnica de `districtRequiredMarker`; o texto pt-BR é “Este nome de cidade não corresponde a um município brasileiro. Escolha outra sugestão.”). Marcadores dos outros 400 (bairro, máximo) têm precedência de teste próprio e não mudam. Copy ARB: escolher outra sugestão. 200 com `content` vazio continua empty state.

**Origem (stash), entregue na fase 4:** `cityUnmatched` nas duas falhas, reconhecido por `code` `location.city.unmatched` **ou** marcador de `detail` (funciona mesmo o back só mandando `detail`). O helper `isIbgeCityUnmatchedProblem` está **duplicado** em `driver_search` e `driver_service_areas`; a fase 4 o consolida numa função em `lib/core/network/` (R42) e usa os caminhos em `snake_case`.

Não implementar `POST /api/schools/resolve`. Quando esse client existir, reusa o mesmo mapeamento.

DF/SP em área de atuação ainda exigem distrito no pin (`requires_district` / `districtRequired`) — inalterado. Casa da conta e do dependente **não** usam `district`: RA vai em `neighborhood`.

### D11 — Gênero: select único compartilhado; omitir é `null` (não entra no enum)

**Origem.** Dados pessoais já tem o select (branches 3/4): `PersonalDataGenderDropdown` (um `DropdownButton<ProfileGenderChoice>` na `PersonalDataRow`), `updateGender(Gender?)` no cubit, `ProfilePatchRequestBuilder.setGender(Gender?)` e `PersonalDataGenderChips` já apagado. O dependente ainda usa `VanepGenderChips` + um botão “Não informar” à parte.

**Na pilha nova.**

- Enum continua `male` / `female` / `other`. Prefiro não informar **não** vira `UNSPECIFIED` no enum — o dono do fato é `null`, igual `Gender.fromApi` já faz. `Gender.toApi(null)` já devolve JSON `null`. O back aceita `"gender": null` no PATCH da conta e do dependente (`JsonNullable<Gender>` nos dois).
- **Um** componente: `VanepGenderSelect` em `lib/core/ui/`, extraído do dropdown de `auth` (mesma aparência de campo, `vanepInputDecoration`, rótulo acima; as quatro opções; `onChanged(Gender?)`). Justifica extrair agora: o select passa a ter **dois** consumidores (dados pessoais e dependente) — R06. Não é um `VanepSelect` genérico: só o de gênero.
- `genderLabel` (core) passa a aceitar `Gender?` e devolve `profileGenderUnspecified` (“Prefiro não informar” / “Prefer not to say”) para `null`; `profileGenderLabel` de `auth` some se sobrar sem uso (R43).
- Apagar `PersonalDataGenderDropdown`, `ProfileGenderChoice` (e `genderFromProfileGenderChoice`), `VanepGenderChips` e a chave `dependentFieldGenderClear`.
- Dependente: create com gênero omitido não manda a chave; update de gênero informado para omitido manda `"gender": null`.

**Rejeitado:** quarto valor no enum (segunda fonte para o mesmo “ausente” do API). **Rejeitado:** manter chips no dependente. **Rejeitado:** `VanepSelect` genérico agora (um só uso concreto).

### D12 — Rascunho, formulário e picker postais: extrair para `lib/core/`, movendo o que já existe

Casa e dependente têm o mesmo formulário, as mesmas regras e o mesmo body. R02 proíbe um módulo importar value object ou widget de outro; R06a proíbe duas cópias das regras. O precedente do repo é `lib/core/` (`Gender`, `IsoCalendarDate`, `places/`). O código de origem **já existe** (branches 3, 4 e stash): a pilha nova o **move e adapta** para core, não reescreve do zero.

**`PostalAddressDraft`** (`lib/core/domain/postal_address_draft.dart`, Dart puro, equatable) recebe as regras que nas branches antigas estão espalhadas em `PersonalDataState` / `PersonalDataCubit` / `PersonalAddressWrite`: CEP (só dígitos), `cityToken`, `cityName`, `uf`, `street`, `neighborhood`, `number`, `complement`, e o que o último lookup decidiu (`isCityUnlocked`, de onde sai o getter `isCityLocked` = tem `cityToken` e não foi destravada; `isNeighborhoodLocked`; `isZipCodeUnknown`). O texto é guardado **como digitado**: aparar ao guardar comeria o espaço de “Rua Sete” enquanto a pessoa digita. Só o CEP é normalizado ao guardar (só dígitos, até 8). Vazio é `''`, não `null`. `sameContentAs` compara o conteúdo já normalizado (texto aparado, opcional vazio = ausente, CEP só dígitos) e é o que decide se a casa está suja. Regras, testáveis sem Flutter e **uma vez só**:

- `isBlank`, `isComplete` (`cityToken` + rua + CEP de 8 dígitos), `isSavable` (completo e CEP não inexistente), `issues` (`cityRequired`, `streetRequired`, `zipCodeInvalid`), `sameContentAs`;
- `withCepLookup({cityToken, cityName, uf, street?, neighborhood?})` — trava cidade, **substitui** rua/bairro, trava o bairro só se veio; `withCepUnavailable()` destrava e limpa o que veio do lookup; `withCepUnknown()` faz o mesmo e marca o CEP como inexistente até o CEP mudar;
- `withUf(uf)` zera o município e destrava a cidade; `withCity(token, name, uf)`; `unlockCity()`; `withZipCode` (limpa o bloqueio de CEP inexistente e **destrava a cidade quando o CEP fica com menos de 8 dígitos**, sem apagar dados); setters de texto que respeitam `PostalAddressLimits` (255 / 16 / 128 / 128) e truncam. `withUf` e `withCity` **não** limpam o bloqueio de CEP inexistente. O rascunho de uma casa gravada (`PostalAddressDraft.fromParts`) nasce com a cidade travada e o bairro destravado.

Não referencia `PersonalAddress`, `DependentAddress`, `CepLookup`, `CepFailure` nem tipo de módulo: recebe primitivos. Cada módulo converte a sua entidade e o seu resultado de lookup na sua borda.

**UI** (`lib/core/ui/`): `VanepPostalAddressForm` (de `PersonalAddressForm` + `PersonalAddressUfField`) e `VanepCityPickerSheet` (de `PersonalAddressCityPickerSheet`). São **apresentacionais**: recebem valores, controllers, o estado do picker e callbacks; **não** conhecem cubit nem módulo. O estado do rascunho, do lookup e do picker é do cubit do consumidor (R06a); a página envolve o sheet num `BlocBuilder` e passa as listas. A máscara `00000-000` vai num input formatter em `lib/core/formatters/`. O marcador de campo obrigatório (`isRequired`, `VanepFieldLabel`) que o stash acrescenta a `VanepTextField` é reaplicado **sobre a versão da main** (que reescreveu o widget), não copiado por cima.

**Trade-off assumido.** A consulta de CEP com debounce, o status do lookup e o carregamento das listas do picker (~30 linhas de cubit) ficam repetidos em `PersonalDataCubit` e `DependentFormCubit`. As **regras** não se repetem: estão no rascunho. Extrair a orquestração pediria tipos do `ibge_locations` em `lib/core/` (`core` não importa módulo) ou um import de presentation entre módulos (R02). Se aparecer um terceiro consumidor (escola), reavalia-se mover o `ibge_locations` para core.

**Rejeitado:** cada módulo com seu rascunho (duas cópias de completude, caps, travas e prefill). **Rejeitado:** `PostalAddressCubit` em `ibge_locations/presentation` importado pelos dois (R02). **Rejeitado:** o dependente importando o form de `auth` (R02). **Rejeitado:** reescrever o form em core do zero (já existe e está validado).

### D13 — Identidade visual nova, só em dados pessoais + endereço e dependentes

A main aplicou a identidade em auth e, ao alterar `VanepTextField` e `VanepPrimaryButton` **em core**, ela já vale para toda tela que usa esses dois widgets. A decisão desta change é **não ir além disso**: só as telas do escopo (`personal-flow-identity`) ganham fundo, chrome e estrutura novos; o resto do app não recebe restyle aqui.

Tokens (sem cor solta): `action` (ação, foco, links, badge de padrão), `card` (fundo), `inputBorder` / `cardBorder`, `placeholder`, `fieldLabel` / `fieldValue`, `loginTitle` / `cardTitle` / `cardSubtitle`. `brand` (ciano) sai como cor de ação nessas telas (hoje o botão “Cadastrar endereço” e o botão do picker usam `brand`). `VanepFeedback` e `showVanepConfirmDialog` seguem como estão (o diálogo destrutivo já usa `danger`).

**Chrome promovido para core.** Os dependentes precisam dos mesmos blocos que auth usa e não podem importá-los de `auth` (R02). Movimentação pura (`git mv` + rename), sem mudar aparência:

| Hoje (`auth/presentation/widgets/auth_page_chrome.dart`) | Depois (`lib/core/ui/vanep_page_chrome.dart`) |
|---|---|
| `AuthAppBar` | `VanepAppBar` |
| `AuthPageHeader` | `VanepPageHeader` |
| `AuthIconBadge` | `VanepIconBadge` |
| `AuthBottomBar` | `VanepBottomBar` |
| `AuthOutlinedPanel` | `VanepOutlinedPanel` |
| `AuthFieldRow`, `authFieldRowMinWidth` | `VanepFieldRow`, `vanepFieldRowMinWidth` |
| `withSpacing` | `withSpacing` |

Telas do escopo:

- **Dados pessoais** — fundo `card`, `VanepAppBar`; os campos passam a `VanepTextField` (nome e telefone editáveis; e-mail, documento e nascimento somente leitura) no lugar do sublinhado inline; gênero no `VanepGenderSelect`; `CooldownBadge` abaixo do campo com tokens novos; `PendingEmailBanner` mantém `warningSurface`; cartão de endereço num `VanepOutlinedPanel` (ações em `action`, “Limpar endereço” em `danger`); Salvar do perfil no `VanepBottomBar`.
- **Tela de endereço da conta** — `VanepAppBar`, `VanepPostalAddressForm`, Salvar no `VanepBottomBar`.
- **Lista de dependentes** — `VanepAppBar`; cada dependente num `VanepOutlinedPanel`, o padrão com `highlighted: true` e badge de padrão em tom de ação (`action` a 8% + texto `action`); “definir como padrão” em `action`; “adicionar” no `VanepBottomBar`. Estados de carga/erro/vazio no mesmo esqueleto.
- **Formulário de dependente** — `VanepAppBar`, `VanepTextField` para nome, data de nascimento (campo somente leitura que abre o date picker, no lugar do `OutlinedButton`), `VanepGenderSelect`, `VanepPostalAddressForm` inline, Salvar no `VanepBottomBar`.
- **`EmailChangeSheet`** — já usa `VanepTextField` / `VanepPrimaryButton`; só revisar tokens (`action`, nada de `brand`).

`VanepScreenBackground` e `VanepGlassCard` não são usados nessas telas. Os dois widgets **deixaram de existir**: a main (PR #69) apagou os dois junto com o tema escuro, e nenhuma tela do app os usa mais.

**Rejeitado:** trocar o tema do app inteiro nesta change (decisão do produto: replicação depois — a main já fez essa replicação no PR #69, num kit próprio: `VanepCard`, `VanepMenuCard`, `VanepHomeTopBar`, `VanepSkeleton`). **Rejeitado:** restilizar o menu de conta para “combinar” com a página nova. **Rejeitado:** manter `PersonalDataInlineField` (sublinhado inline é a identidade antiga). **Rejeitado:** duplicar o chrome dentro de `dependents`.

Os dois kits convivem e partem dos mesmos tokens claros (`card`, `action`, `textPrimary`, `cardBorder`, `inputBorder`, `placeholder`), que a main manteve. Unificar `VanepPageChrome` com o kit da main não é escopo desta change.

### D14 — Dependente: endereço postal ponta a ponta

**Domínio (`dependents`).**

- `DependentAddress` (entidade abstrata) troca `district` por `zipCode`, `neighborhood`, `cityToken`; mantém `token`, `street`, `number`, `complement`, `cityName`, `stateUf`.
- `DependentDraft.address` passa a ser um `PostalAddressDraft` (nunca nulo; em branco = sem endereço). `DependentAddressDraft` é **apagado**. `DependentDraft.fromDependent` converte a `DependentAddress` em rascunho.
- `buildDependentChangesForCreate`: `address` tocado só se o rascunho não é em branco. `buildDependentChangesForUpdate`: `address` tocado quando o rascunho difere do rascunho derivado do snapshot. `addressWasEdited` (amend de número/complemento) some.
- `validateDependentDraft` ganha as pendências de endereço: rascunho **não em branco e incompleto** → `PostalAddressIssue`s; em branco → nada. Bloqueia o save antes do request.

**Dados.**

- `DependentAddressDto` lê `zipCode`, `neighborhood`, `cityToken`; ignora `district`. 
- `dependentAddressToJson`: tocado + em branco → `null` explícito; tocado + preenchido → `postalAddressToJson(draft)` (D4). Nunca `placeId` / `sessionToken`.
- Falhas: novo `DependentCityNotFoundFailure`. O 404 do POST é sempre cidade. No PATCH o 404 é ambíguo (`dependent.not_found` vs `city.not_found`, ambos `ResponseStatusException` com `detail` localizado, sem `code`): distingue-se por marcador de “cidade” no `detail` (mesma técnica de `districtRequiredMarker`); sem o marcador, continua `DependentNotFoundFailure`. `dependentFieldsByApiName['placeId']` sai. 400: `dependentFailureLabel` nunca renderiza o `detail` do back (é o texto genérico do Spring) — usa a copy localizada. 409 → `unexpected`.

**Apresentação.**

- `DependentFormCubit` ganha `LookupCep`, `ListStates`, `ListCities`; o wiring de CEP/picker é o de D12. `choosePlace`, `changeAddressNumber`, `changeAddressComplement` e `removeAddress` saem; entram os updaters postais e `clearAddress` (rascunho volta a em branco). Estado ganha status do lookup, `CepFailure?`, picker e as pendências de endereço. O lookup de CEP segue a mesma semântica da conta (D4): trava cidade, substitui rua/bairro, destrava o picker na falha e bloqueia o Salvar em CEP inexistente — vem do `PostalAddressDraft`.
- `DependentAddressField` (Places + resumo) é apagado; o form usa `VanepPostalAddressForm` direto. O form deixa de resolver `PlaceAutocompleteController` e de descartá-lo.
- `dependentAddressLabel` passa a “rua, nº · complemento · bairro · Cidade - UF · CEP”. Sem endereço, a copy de “sem endereço”.
- Copy Places do dependente sai do ARB (`dependentFieldAddressSearchHint`, entre outras); `dependentFieldGenderClear` sai (D11).

**Por que esta fase atravessa camadas (exceção declarada a R19).** Trocar `DependentAddressDraft` por `PostalAddressDraft` e `DependentAddress` de forma é uma substituição de tipo: cada camada quebra a compilação da seguinte, então não existe fatia por camada que compile e passe `make test` (R25). O contrato do repositório **não** muda (`DependentRepository` continua recebendo `DependentChanges`), então R20 não é violado; só value objects, DTO, body e cubit trocam. É a única fase que mistura camadas. Mesmo assim ela só entra no ar com o back implantado (R21: até lá, datasource com mock).

**Rejeitado:** manter o modo amend “só número” (o back devolve 400 em `address` parcial). **Rejeitado:** deixar Places e postal coexistirem no formulário (o back ignora `placeId`; o app não deve mandá-lo). **Rejeitado:** camadas de dependente em fases separadas com adaptadores temporários (código morto entre PRs, R43).

## Risks / Trade-offs

**R1 — PATCH ok, PUT falha → verdade partida.** Nome gravado, casa não, `PERSONAL_ADDRESS` ainda pendente.  
*Mitigação:* rascunho de endereço fica, snack de erro, sem sucesso. A pessoa corrige o form e salva de novo sem redigitar o nome.

**R2 — Refresh do `/me` falha depois do PUT 200.** Casa está no back; `pendingSteps` da sessão pode continuar listando `PERSONAL_ADDRESS`.  
*Mitigação:* snack de sucesso mesmo assim. Pull-to-refresh na aba Perfil chama `refreshSessionProfile`.

**R3 — PUT replace total apaga opcional omitido.** Esquecer `neighborhood` no JSON zera o bairro gravado. Vale para a casa **e** para o dependente.  
*Mitigação:* `postalAddressToJson` é a única função que monta o body e sempre manda os três opcionais. Teste de DTO trava as chaves nos dois módulos.

**R4 — CEP 429 por usuário.** Digitação sem debounce estoura o limite.  
*Mitigação:* só consulta com 8 dígitos; debounce 400 ms; 429 abre o picker em vez de martelar de novo.

**R5 — Dois 404 de CEP.** “CEP não encontrado” vs “cidade fora do catálogo” pedem copy diferente e o mesmo fallback (picker).  
*Mitigação:* mapear pelo `detail`; teste de fixture para os dois.

**R6 — Remoção do menu é visível só no CLIENT, mas o enum é global.** Apagar pela metade deixa `switch` exaustivo quebrado.  
*Mitigação:* a fase de UI apaga enum, menu, switches, ARB e testes no mesmo conjunto.

**R7 — Refresh do `/me` falha depois do DELETE 204.** Casa já não está no back; a sessão pode continuar **sem** `PERSONAL_ADDRESS`.  
*Mitigação:* bloco já vazio. Snack de sucesso do DELETE. Pull-to-refresh alinha a flag.

**R8 — App antigo com `placeId` quebra neste release** (casa **e** dependente).  
*Mitigação:* store release coordenado com o deploy da API. O app novo nunca manda `placeId` nesses PUT/POST/PATCH. A fase de dependente só mergeia com a API no ar.

**R9 — 400 de cidade IBGE na busca lido como empty.** Motorista some da UI sem ter sido pesquisado de verdade.  
*Mitigação:* fase própria; teste de repositório distingue 400 unmatched de 200 vazio.

**R10 — PATCH `"gender": null`.** O cubit manda a chave com `null` quando a pessoa escolhe Prefiro não informar.  
*Mitigação:* teste de `ProfilePatchRequest` trava a chave com `null`; teste do body de dependente idem.

**R11 — Marcadores de `detail` são texto localizado.** CEP (“catálogo”), cidade sem município (“município brasileiro”) e 404 de cidade do dependente (“cidade”) dependem do texto pt-BR do back; mudar a mensagem quebra o mapeamento. É o mesmo risco que `districtRequiredMarker` já corre.  
*Mitigação:* marcadores como constantes nomeadas no repositório, um teste de fixture por marcador. Pedir ao back um campo `code` estável resolve de vez e não muda esta change.

**R12 — Mover o chrome de auth para core.** A movimentação é obrigatória (R02); o rename `Auth*` → `Vanep*` é escolha de nome (R39: `AuthAppBar` dentro de `lib/core/ui/` e usado por dependentes engana). Toca 4 páginas de auth (`account_type_page`, `email_code_verification_page`, `password_reset_page`, `signup_page`) e nenhum teste (nada em `test/` referencia essas classes).  
*Mitigação:* movimentação pura, feita na fase 4, sem mudar aparência nem comportamento. A prova é `make test` verde sem editar nenhum teste e as 4 páginas mudando só import e nome de classe.

**R13 — “O resto do app fica como está” mas `VanepTextField` / `VanepPrimaryButton` já mudaram na main.** Telas fora do escopo que usam esses dois widgets já aparecem com o azul novo.  
*Mitigação:* declarado na spec. Esta change não adiciona restyle; a replicação futura ao app todo completa o resto.

**R14 — Duas cópias de ~30 linhas de wiring de CEP/picker (D12).**  
*Mitigação:* regras num só lugar (o rascunho); duplicação só de plumbing. Reavaliar com um terceiro consumidor.

**R15 — A fase 5 mistura camadas.**  
*Mitigação:* exceção justificada em D14; segue sob R20 (contrato de repositório inalterado) e R21 (só mergeia com a API no ar).

**R16 — A pilha refaz código já implementado e validado.** A pilha nova troca os oito campos soltos por `PostalAddressDraft`, tira o mapa da API de dentro de `PersonalAddressWrite` e move form/picker/dropdown para core.  
*Mitigação:* os testes das branches antigas são portados junto com o código e têm de passar **sem mudar de intenção** (só imports, nomes e tipos). As branches antigas ficam como referência (`old/…`) até você aprovar apagá-las, para comparar comportamento com `git diff`. Se um teste precisar mudar de comportamento, é decisão a discutir, não ajuste.

**R17 — A UI e o 400 de cidade estão só no `stash@{0}`.** Ele foi criado sobre a ponta da 5 (main antiga) e um `stash pop` errado já conflitou uma vez. Usa caminhos antigos (`driversearch`, `driverserviceareas`), reescreve `vanep_text_field.dart` (que a main reescreveu) e carrega edições obsoletas de `openspec/`.  
*Mitigação:* **sem `stash pop`**: os arquivos são lidos de lá (`git show stash@{0}:<path>`) e portados para a pilha nova; `openspec/*` e `vanep_text_field.dart` ficam de fora (reaplicar só `isRequired` / `VanepFieldLabel` sobre a versão da main). O stash fica intacto até você validar e mandar descartar.

## Migration Plan

Nada de geografia persistida no aparelho. Rollout é a ordem das fases + o mesmo release da API. Cada fase é branch/PR próprio e reverte sozinha, exceto que a fase 5 só mergeia depois da API com o contrato postal do dependente.

Rollback da UI de dados pessoais devolve a tela ao Salvar só de perfil; a casa no back, se já gravou no contrato postal, permanece. Rollback da fase 5 devolve o dependente ao contrato Places, que o back novo **não aceita mais** — só faz sentido reverter junto com a API.

Esta change **não** depende de usar `lib/core/places/` na tela de dados pessoais nem no dependente. Places continua necessário para busca e áreas.

##### Reorganização da pilha (git)

A pilha antiga é anterior ao N-177 e ao snake_case, e as fases novas não coincidem com as fronteiras das branches antigas (a branch 4, por exemplo, mistura cubit e UI). Em vez de propagar a main por 5 merges e depois refatorar, a recomendação é **refazer a pilha a partir da main**, portando código e testes:

1. Commitar esta spec em `spec/personal-address` (que já contém a main desde `bba38b0`).
2. Renomear as 5 branches antigas para `old/<nome>` (ficam como referência; nada é apagado).
3. Criar a pilha nova com os nomes de fase, a partir de `spec/personal-address`, e portar por fase os arquivos das branches antigas e do stash (`git checkout old/<branch> -- <paths>` / `git show stash@{0}:<path>`), já adaptados ao desenho novo.
4. Só depois de você validar a pilha nova: descartar `old/*` e o stash, se quiser.

Nada disso é feito sem a sua aprovação (R27a). A alternativa é propagar a main pela pilha existente (1→2→3→4→5) e refatorar em cima; funciona, mas gera conflitos em ARB/l10n em cada degrau e deixa fronteiras de fase erradas.

### Entrega fatiada (R16–R23)

Cinco fases. Uma camada por PR (R19) na 1–4; contrato e impl separados (R20). Teto de 10 arquivos **não** corta fase de camada.

| Fase | Conteúdo | Depende de | Paralelo com |
|----|----------|------------|---------------|
| 1 | Domínio: `ibge_locations` + casa + `PostalAddressDraft` (core) — sem HTTP | — | — |
| 2 | Dados: `ibge_locations` + casa, `postalAddressToJson`, `Environment` completo, DI | 1 | — |
| 3 | Cubit de dados pessoais: carga, CEP, picker, save (PATCH→PUT), gênero `null`, DELETE | 2 | — |
| 4 | UI: kit em core (chrome, select de gênero, form postal, picker) + dados pessoais e endereço na identidade nova + menu Endereços + 400 de cidade | 3 | — |
| 5 | Dependentes: endereço postal ponta a ponta + select de gênero + identidade nova | 2, 4 + **API do dependente no ar** | — |

Notas:

- **Fase 1** ganha o rascunho compartilhado no lugar dos campos soltos (D12). **Fase 3** junta o que eram o cubit de carga, o de save e o DELETE, e já nasce sobre o rascunho.
- **Fase 4** é toda de apresentação (o kit de core é UI). O 400 de cidade (`driver_search`, `driver_service_areas`) entra aqui só por ser pequeno e não ter fase própria; é o corte natural se a fase estourar.
- **Fase 5** é a única que mistura camadas (D14). Como a 4 já entrega o kit e a identidade, a 5 só o consome.
- R20: contrato (fase 1) e impl (fase 2) continuam separados. R27a: parar depois de `make lint` / `make test` para validação no aparelho antes do commit.

 Open Questions

- A aparência do `VanepGenderSelect` (dropdown ancorado no campo vs. bottom sheet de opções) fica para a validação em aparelho da fase 4 (R27a). Não muda contrato nem fases.
- Se o back passar a mandar um `code` estável nos 400/404 de localização e de CEP, os marcadores de `detail` (R11) viram troca de uma linha por repositório. Não bloqueia nada.
