## Why

A conta já tem `GET`/`PUT`/`DELETE /api/user/me/address` e o passo `PERSONAL_ADDRESS` no `GET /api/user/me`, mas o app nunca mostra. O back **quebrou** o contrato antigo: a casa deixou de ser um pin do Google Places (`placeId`) e passou a ser **formulário postal brasileiro** com município do catálogo IBGE (`cityToken`). App antigo que manda só `placeId` no PUT quebra. API e app precisam ir no mesmo release.

Desde que essa change foi escrita, dois fatos novos:

- **O back aplicou o mesmo contrato ao dependente** (branch `feat/ibge-postal-address-dependent`, fase 7 do change `ibge-postal-address` do back). `address` em `POST/PATCH /api/dependent` deixou de ser Places e virou o formulário postal da casa. A main mobile tem o módulo de dependentes construído sobre Places (`placeId` + `sessionToken`, amend só de número) — esse contrato não existe mais no back.
- **A main trouxe uma identidade visual nova** (N-177, auth nativo): fundo branco, azul de ação, campos com rótulo acima. Ela vai para o app todo, mas não agora. Aqui ela entra só em dados pessoais + endereço e dependentes.

Como casa e dependente passam a ter o mesmo formulário, esta change cobre o endereço postal de ponta a ponta nos dois, com um só formulário compartilhado.

**Estado da entrega.** Já existe trabalho implementado em branches locais (5 fases empilhadas, com a UI da última num stash). Ele é **material de origem**: o plano foi reorganizado em **5 fases** e as fases existentes podem ser refeitas e refatoradas (ver `design.md`, “Estado atual do trabalho” e “Entrega fatiada”).

## What Changes

- **BREAKING — casa é formulário postal, não Places.** Fluxo alvo: CEP → form editável → salvar. Se o CEP falhar: UF → município do catálogo → form manual. Body do `PUT /api/user/me/address`: `cityToken`, `street`, `zipCode` (8 dígitos, sem hífen) obrigatórios; `number` / `complement` / `neighborhood` opcionais. O app MUST NOT mandar `placeId`. Autocomplete do Places **sai** desta tela.
- **BREAKING — endereço do dependente é o mesmo formulário postal.** `POST/PATCH /api/dependent` com `address` = `cityToken` + `street` + `zipCode` + opcionais. PATCH com `address` é replace total (sem amend parcial: o "corrigir só o número" da versão Places some); `address: null` limpa; omitir não mexe. A resposta agora traz `neighborhood`. O formulário de dependente perde o Places.
- **Um formulário postal compartilhado, extraído do que já existe.** Rascunho único `PostalAddressDraft` em `lib/core/domain/` (completude, caps, travas e prefill de CEP, troca de UF), `VanepPostalAddressForm` e `VanepCityPickerSheet` em `lib/core/ui/`. São movidos e adaptados a partir de `PersonalDataState`/cubit, `PersonalAddressForm` e `PersonalAddressCityPickerSheet`, hoje presos ao `PersonalDataCubit`. Dados pessoais e dependente passam a usar os mesmos.
- **Cidade só do catálogo.** Token IBGE via `GET /api/cep/{cep}` ou picker (`GET /api/states`, `GET /api/cities?uf=`). Cidade não é texto livre. O app MUST NOT chamar `viacep.com.br`. Sem o back não existe `cityToken`. CLIENT consulta o catálogo sem permissão extra.
- **CEP é atalho, não grava.** `GET /api/cep/{cep}` (path = 8 dígitos) preenche cidade + rua/bairro, **trava** UF e município (e o bairro, se veio) e **substitui** rua/bairro; 404 de município fora do catálogo / 429 / 503 **destravam** o picker; 404 de **CEP inexistente** bloqueia o Salvar até trocar o CEP. Debounce no campo. Rate limit 20/60s **por usuário**.
- **PUT é replace total.** Campo opcional omitido vira `null` e apaga o que estava salvo. Número e complemento sempre manuais. Snapshot do PUT 200 vira a casa carregada (sem `googlePlaceId`; `district*` nulos). Sem GET extra de `/address`. Refresh do `/me` depois do PUT ok para `PERSONAL_ADDRESS` sair de `pendingSteps`.
- **GET 404 = bloco vazio.** `GET /api/user/me` não embute a casa. 404 em `/address` é estado inicial, não erro de tela. Qualquer município IBGE pode salvar; “não operamos aí” é busca vazia **depois**, não 400 no form.
- **DELETE 204** (tinha casa ou já vazio). GET seguinte 404; `/me` volta a listar `PERSONAL_ADDRESS`. Alterar continua PUT, sem DELETE antes. O Salvar nunca emite DELETE.
- **Uma sequência de Salvar** (CLIENT, DRIVER, ASSISTANT): `PATCH /api/user/me` se nome/telefone/gênero mudou, depois `PUT /address` se o form postal está gravável. O endereço é editado numa **tela própria**, aberta por um cartão com resumo e menu Editar / Limpar endereço; há um Salvar em cada tela (perfil; endereço), os dois disparam a mesma sequência. Endereço nunca viaja no PATCH.
- **Remover o item morto "Endereços"** do menu de perfil (`ProfileMenuId.addresses`).
- **Gênero é um select único nos dois lugares** (dados pessoais e formulário de dependente), não chips. Quatro opções: Masculino, Feminino, Outro, **Prefiro não informar**. A última é `null` no domínio, no PATCH da conta (`"gender": null`) e no PATCH do dependente. Não é um quarto valor do enum. Dados pessoais já tem o select (local a `auth`); o dependente ainda usa chips. Um `VanepGenderSelect` em core substitui o dropdown local e os chips (`VanepGenderChips`), e o botão “Não informar” do dependente sai.
- **Identidade visual nova só no escopo.** Dados pessoais (com o cartão e a tela de endereço e o sheet de e-mail), lista e formulário de dependentes e o picker passam ao fundo branco, `VanepColors.action`, campos `VanepTextField` com rótulo acima, painéis com borda, Salvar na barra inferior. O chrome de página de auth (`AuthAppBar`, `AuthPageHeader`, `AuthBottomBar`, `AuthOutlinedPanel`, `AuthFieldRow`) é movido para `lib/core/ui/` como `Vanep*` para os dependentes poderem usá-lo (R02); a aparência de auth não muda. **O resto do app não é restilizado.**
- **Correção de premissas do back.** O 400 de Bean Validation do PUT da casa e do dependente é o ProblemDetail padrão do Spring, **sem `errors[]`**; o 400 `location.city.unmatched` vem só com `detail` localizado, **sem `code`**. O app valida a completude localmente (erro por campo) e reconhece o 400 de cidade por marcador de `detail`.
- **Colateral Places (busca e área de atuação):** se o nome de cidade do Google não casar com município IBGE, a API devolve **400**, não 200 com lista vazia. O app trata como “escolha outra sugestão”. Já implementado no stash; a fase 4 o entrega e consolida o helper duplicado.

## Capabilities

### New Capabilities

- `personal-address`: endereço residencial da conta — carga (404 = vazio), upsert postal, limpar por `DELETE` (204 mesmo se já vazio), Salvar único em dados pessoais (PATCH/PUT, nunca DELETE), refresh de `pendingSteps` depois do PUT e do DELETE, sem item separado de endereços no menu, sem Places nesta tela.
- `postal-address-form`: o que é um endereço postal válido no app — cidade só por `cityToken`, CEP como prefill, picker UF/município, rascunho compartilhado com completude e caps, body de escrita único, formulário e picker únicos em `lib/core/ui/`. Compartilhado por `personal-address` e `dependent-postal-address`.
- `dependent-postal-address`: endereço do dependente no contrato postal — opcional (em branco = sem endereço), replace total no PATCH, `null` limpa, exibição a partir da resposta, falhas localizadas, release coordenado com a API. **Supera** `dependent-address` da change `client-dependents`.
- `gender-select`: select único com “Prefiro não informar” = `null`, em dados pessoais e no dependente.
- `personal-flow-identity`: identidade visual nova aplicada só em dados pessoais + endereço e dependentes; tokens, componentes movidos para core, fora do escopo o resto do app.
- `places-ibge-city-match`: busca de motorista e área de atuação tratam o 400 de cidade sem município IBGE como rejeição da sugestão, não como “não há motoristas” / lista vazia.

### Modified Capabilities

- `client-dependents` / `dependent-address` (change `client-dependents`, ainda ativa em `openspec/changes/`): o requisito de endereço por Places (`placeId` + `sessionToken`, amend de número/complemento sem `placeId`) e a fase 5 de tasks dessa change ficam **superados** por `dependent-postal-address`. O select de gênero também altera o formulário descrito lá. Não há `openspec/specs/` a alterar (o repo ainda não tem specs arquivadas); a fase 5 desta change atualiza a change `client-dependents` para apontar para esta.

## Impact

**Módulos.** Recurso `/api/user/me/address` e a tela `PersonalDataPage` ficam em `lib/modules/auth/` (repositório novo de endereço, não cresce o `AuthRepository`). CEP, UFs e municípios são outro recurso (`/api/cep`, `/api/states`, `/api/cities`) — módulo `lib/modules/ibge_locations/`, contrato de domínio que os cubits de dados pessoais e de dependente consomem. Rascunho postal, formulário e picker compartilhados em `lib/core/`. Places permanece em `lib/core/places/` só para busca e área de atuação. Diretórios em `snake_case` (R02a, já na main): `driver_search`, `driver_service_areas`.

**Código existente.** `PersonalDataCubit` / `PersonalDataState` / `PersonalDataPage` (carga dos dois recursos, CEP, picker, PATCH/PUT e DELETE, bloco de endereço, select de gênero, layout novo). `ProfilePatchRequest` passa a aceitar `gender: null`. `Environment` (endpoints). DI do auth e do `ibge_locations`. Menu de perfil, `ProfileMenuId`, ARB (`profileAddresses` some; copy nova). Módulo `dependents` inteiro no que toca endereço: `DependentAddress`, `DependentAddressDraft` (some, vira `PostalAddressDraft`), `DependentChanges`, `DependentDraft`, `dependent_request_body`, `DependentFailure`, `DependentFormCubit`, `DependentAddressField`, `DependentCard`, `DependentsPage`, `DependentFormPage`. `auth_page_chrome.dart` (movido). `genderLabel`. Falhas de `driver_search` e `driver_service_areas` (400 de cidade). Testes dessas superfícies.

**Não mexe.** Banner de áreas no `DriverShell`. Shells de cliente/assistente. Menu de perfil no que não seja a linha Endereços. Busca e áreas no que não seja o 400. Escola / `POST /api/schools/resolve` (fora desta change; escola continua por Places no back). `schoolToken`, `shift`, `isSelf`, delete de dependente. Geocoding, lat/lng, mini-mapa, `/api/geo`, `GET /api/countries`. Criar município no client. O `PATCH /me` continua sem campos de endereço. Nenhuma tela fora do escopo de identidade visual.

**Backend.** Breaking no ar neste release, em dois endpoints (`PUT /api/user/me/address` e `POST/PATCH /api/dependent`). Sem token → 401. Qualquer usuário autenticado (cliente ou motorista) consulta CEP/UF/município; sem permissão `list_cities` / `list_states`. Coordenar store release com o deploy da API. O contrato do dependente está na branch `feat/ibge-postal-address-dependent` do `vanep-api-java` e ainda não está na main dele.
