## Purpose

Permite que CLIENT, DRIVER e ASSISTANT cadastrem, editem e removam o endereço residencial da conta logada como formulário postal brasileiro (município do catálogo IBGE + logradouro), independente dos campos de perfil e de qualquer endereço de dependente, escola ou área de atuação. Os campos, o CEP e o picker são os de `postal-address-form`; o gênero na mesma tela é o de `gender-select`; o visual é o de `personal-flow-identity`.

## ADDED Requirements

### Requirement: Endereço residencial da conta é um recurso separado do perfil

O app SHALL carregar, gravar e limpar o endereço residencial da conta por `GET`/`PUT`/`DELETE /api/user/me/address`. O app MUST NOT ler a casa no `GET /api/user/me` e MUST NOT gravá-la nem apagá-la no `PATCH /api/user/me`.

`GET /api/user/me` continua sendo a fonte de se o passo de onboarding `PERSONAL_ADDRESS` está pendente: `pendingSteps` contém esse passo quando a casa não existe, e não o contém quando a casa existe (outros passos, como `SERVICE_AREA`, podem permanecer). O app MUST NOT tratar outro recurso como este endereço — nem endereço aninhado de dependente, nem `/api/schools/resolve`.

Todas as chamadas a `/api/user/me/address` MUST enviar `Authorization: Bearer <access_token>`. Sem token o back responde 401; o interceptor de auth continua responsável por esse caso.

#### Scenario: Payload do perfil não traz a casa

- **WHEN** o app abre dados pessoais
- **THEN** ele pede `GET /api/user/me` e `GET /api/user/me/address` em duas chamadas
- **AND** não procura rua, cidade ou CEP no payload do perfil

#### Scenario: PATCH do perfil nunca carrega campos de endereço

- **WHEN** a pessoa muda nome, telefone ou gênero e salva
- **THEN** o body da requisição de perfil contém só esses campos de perfil
- **AND** não contém `placeId`, `cityToken`, rua, cidade nem CEP

### Requirement: Casa ausente é bloco vazio, não tela com erro

O app SHALL tratar HTTP 404 em `GET /api/user/me/address` como "nenhuma casa cadastrada" e MUST mostrar o bloco de endereço (o cartão) vazio e pronto para cadastrar.

O app MUST NOT apresentar esse 404 como erro de carga da tela de dados pessoais. Casa ausente MUST NOT ser inferida como passo de onboarding pendente; `pendingSteps` no `GET /api/user/me` continua sendo a única fonte desse fato.

#### Scenario: Primeira visita sem casa

- **WHEN** `GET /api/user/me/address` devolve 404
- **AND** `GET /api/user/me` passa
- **THEN** a tela de dados pessoais é usável
- **AND** o cartão de endereço está vazio, com a ação de cadastrar
- **AND** o app não mostra o estado de erro de carga do perfil

#### Scenario: Casa já cadastrada

- **WHEN** `GET /api/user/me/address` devolve 200 com o endereço gravado
- **THEN** o cartão de endereço mostra o endereço (rua, número, complemento, bairro quando houver, município, UF e CEP)
- **AND** editar abre a tela de endereço com os campos preenchidos a partir dele
- **AND** não mostra distrito do Google nem `googlePlaceId`

#### Scenario: 404 não é sinal de passo pendente

- **WHEN** `GET /api/user/me/address` devolve 404
- **AND** `pendingSteps` não contém `PERSONAL_ADDRESS`
- **THEN** o app ainda mostra o bloco de endereço vazio
- **AND** não inventa um passo de onboarding pendente a partir do 404

### Requirement: Gravar a casa manda formulário postal, não placeId

O app SHALL gravar a casa com `PUT /api/user/me/address` cujo body é o write postal de `postal-address-form` (`cityToken`, `street`, `zipCode` de 8 dígitos e os três opcionais sempre presentes).

O PUT é **replace total**. O app MUST enviar o body postal completo a partir do rascunho atual. Campo opcional em branco MUST ir como JSON `null` (apaga o valor salvo). O app MUST NOT omitir um opcional preenchido só porque não mudou. O app MUST NOT incluir `placeId`, `sessionToken`, `stateToken`, `cityName` nem `uf`.

Criar e atualizar são o mesmo PUT. PUT ok devolve **200** e o mesmo documento do GET (sem `googlePlaceId`; `districtName` e `districtToken` nulos; `cityName`, `cityToken`, `stateUf`, `countryIsoCode` preenchidos pelo back). O app MUST aplicar esse documento como a casa carregada e MUST NOT chamar GET `/address` de novo para confirmar. O app MUST NOT emitir DELETE antes de um PUT que só altera a casa.

HTTP 404 no PUT (`cityToken` desconhecido) MUST mostrar erro localizado de cidade não encontrada e manter os rascunhos. HTTP 400 de validação MUST mostrar uma falha de validação genérica localizada e manter os rascunhos; o back não devolve erro por campo, então as pendências por campo vêm só da completude local do rascunho. O 400 MUST NOT ser tratado como “não operamos nessa cidade”.

#### Scenario: Save postal completo

- **WHEN** a pessoa tem `cityToken`, rua e CEP de 8 dígitos e salva a casa
- **THEN** o body do PUT contém `cityToken`, `street` e `zipCode` sem hífen
- **AND** contém `number`, `complement` e `neighborhood` com o valor do rascunho ou `null` se em branco
- **AND** o body não contém `placeId`, `sessionToken`, `stateToken`, `cityName` nem `uf`

#### Scenario: Opcional apagado zera no back

- **WHEN** a casa gravada tem complemento
- **AND** a pessoa apaga o complemento e salva
- **THEN** o body envia `"complement": null`
- **AND** o snapshot aplicado depois do 200 não tem complemento

#### Scenario: Resposta do PUT vira a casa carregada

- **WHEN** o PUT devolve 200 com o documento de endereço
- **THEN** o bloco de endereço mostra esse documento
- **AND** o app não pede `GET /api/user/me/address` para atualizar

#### Scenario: cityToken desconhecido

- **WHEN** o PUT devolve 404 porque o `cityToken` não existe no catálogo
- **THEN** o app mostra um erro localizado de cidade não encontrada
- **AND** mantém os rascunhos
- **AND** não trata o 404 como casa ausente

#### Scenario: Validação recusada pelo back

- **WHEN** o PUT devolve 400 de validação
- **THEN** o app mostra a mensagem genérica localizada de validação
- **AND** mantém os rascunhos
- **AND** não mostra o `detail` que veio do back

### Requirement: Um Salvar grava perfil depois casa, e só avisa sucesso se todos os writes pedidos passaram

O endereço é editado numa **tela própria de endereço**, aberta pelo cartão de endereço da tela de dados pessoais. O controle Salvar existe nas duas telas — o Salvar do perfil na tela de dados pessoais e o Salvar do endereço na tela de endereço —, mas os dois disparam a **mesma sequência**, sobre os mesmos rascunhos do mesmo dono (o cubit de dados pessoais). Não há um segundo caminho de gravação.

O Salvar da tela de dados pessoais MUST ficar habilitado só com o perfil sujo. O Salvar da tela de endereço MUST ficar habilitado só com a casa gravável (rascunho completo e CEP não dado como inexistente).

Em qualquer dos dois Salvar o app MUST:

1. Se nome, telefone ou gênero mudou, `PATCH /api/user/me`. Se esse PATCH falhar, o app MUST NOT chamar PUT `/address`.
2. Se o rascunho postal mudou e está completo (`cityToken`, `street`, `zipCode` com 8 dígitos), `PUT /api/user/me/address` com o body postal completo.
3. Se esse PUT passou, aplicar o documento do PUT e depois dar refresh em `GET /api/user/me` para `PERSONAL_ADDRESS` poder sair de `pendingSteps`. PUT não devolve onboarding; PATCH não sabe que a casa gravou.

O Salvar MUST NOT emitir `DELETE /address`. Ficar sem casa é uma ação separada.

O app MUST mostrar o feedback de sucesso só quando todos os writes que ele de fato emitiu passaram. PATCH ok seguido de PUT falho MUST manter o perfil gravado, manter os rascunhos de endereço e mostrar o erro de endereço — não o feedback de sucesso.

Salvar MUST NOT ser oferecido para uma edição só de endereço incompleta (falta cidade, rua ou CEP de 8 dígitos) nem para CEP dado como inexistente (`postal-address-form`). Número, complemento ou bairro sozinhos MUST NOT ligar o Salvar da casa. Depois de um Salvar bem-sucedido a tela de endereço fecha.

CLIENT, DRIVER e ASSISTANT MUST usar esta mesma tela e esta mesma sequência.

#### Scenario: Perfil e casa mudaram

- **WHEN** a pessoa muda o nome e o form postal completo, depois salva
- **THEN** o app manda PATCH `/me` primeiro
- **AND** depois manda PUT `/address`
- **AND** mostra feedback de sucesso só depois dos dois passarem
- **AND** em seguida dá refresh em `GET /api/user/me`

#### Scenario: Só a casa mudou

- **WHEN** a pessoa muda só campos postais completos e salva
- **THEN** o app não faz PATCH `/me`
- **AND** faz PUT `/address`
- **AND** depois do PUT 200 dá refresh em `GET /api/user/me`

#### Scenario: PATCH falha

- **WHEN** o PATCH do perfil falha
- **THEN** o app não faz PUT `/address`
- **AND** não mostra feedback de sucesso

#### Scenario: PATCH passa e PUT falha

- **WHEN** o PATCH do perfil passa e o PUT do endereço falha
- **THEN** a tela mantém o perfil atualizado
- **AND** mantém os rascunhos de endereço
- **AND** mostra o erro de endereço
- **AND** não mostra feedback de sucesso
- **AND** não dá refresh no `/me` de onboarding (a casa não gravou)

#### Scenario: Salvar do endereço com o perfil também sujo

- **WHEN** o nome mudou e o form postal está completo
- **AND** a pessoa toca Salvar na tela de endereço
- **THEN** o app manda PATCH `/me` primeiro e depois PUT `/address`

#### Scenario: Casa incompleta não grava

- **WHEN** não há `cityToken` ou rua ou CEP de 8 dígitos
- **THEN** mudar só número, complemento ou bairro não habilita o Salvar da casa
- **AND** o app não faz PUT `/address`

#### Scenario: CEP inexistente não grava

- **WHEN** o último lookup de CEP deu 404 de CEP inexistente
- **THEN** o Salvar da casa permanece desabilitado mesmo com cidade, rua e CEP de 8 dígitos
- **AND** o app não faz PUT `/address`

#### Scenario: Salvar não apaga a casa

- **WHEN** a pessoa toca Salvar
- **THEN** o app não emite DELETE `/address`

### Requirement: Limpar a casa é DELETE, não PUT e não o Salvar

O app SHALL deixar a pessoa ficar sem endereço residencial por `DELETE /api/user/me/address` (Bearer, sem body), pela ação “Limpar endereço” no menu do cartão de endereço (ao lado de “Editar”), com confirmação destrutiva.

O DELETE MUST ser tratado como sucesso em HTTP **204**, tanto quando havia casa quanto quando já estava vazio. O app MUST NOT exigir JSON de resposta. O app MAY chamar DELETE mesmo sem casa no snapshot; a UI MUST oferecer o controle só quando existe casa gravada.

Depois de um 204 o app MUST:

1. Zerar o snapshot e os rascunhos de endereço (bloco vazio).
2. Dar refresh em `GET /api/user/me` para `PERSONAL_ADDRESS` poder voltar a `pendingSteps`. DELETE não devolve onboarding.
3. MUST NOT chamar GET `/address` de novo para confirmar o vazio.

O app MUST NOT usar DELETE para alterar a casa — alterar continua PUT, sem DELETE antes. O app MUST NOT tratar endereço de dependente como este recurso.

Falha de DELETE (rede ou inesperada) MUST manter o snapshot, mostrar erro localizado e MUST NOT mostrar sucesso. 401 continua a cargo do interceptor de auth.

#### Scenario: Pessoa remove a casa gravada

- **WHEN** existe casa no snapshot
- **AND** a pessoa confirma limpar o endereço
- **THEN** o app emite DELETE `/address` sem body
- **AND** no 204 zera o bloco de endereço
- **AND** dá refresh em `GET /api/user/me`
- **AND** não pede GET `/address` para confirmar

#### Scenario: DELETE é idempotente

- **WHEN** o back devolve 204 e já não havia casa
- **THEN** o app trata como sucesso
- **AND** o bloco de endereço fica vazio

#### Scenario: Sem casa gravada não há ação de limpar

- **WHEN** não existe casa no snapshot
- **THEN** o cartão mostra só a ação de cadastrar
- **AND** o menu com “Limpar endereço” não aparece

#### Scenario: Trocar de casa não passa por DELETE

- **WHEN** já existe casa gravada
- **AND** a pessoa altera o form postal e salva
- **THEN** o app faz PUT `/address`
- **AND** não faz DELETE antes do PUT

#### Scenario: Dependente não é afetado

- **WHEN** a pessoa limpa o endereço residencial da conta
- **THEN** o app não lê, não grava e não apaga endereço de dependente

#### Scenario: DELETE falha

- **WHEN** o DELETE falha por rede ou erro inesperado
- **THEN** o snapshot da casa permanece
- **AND** o app mostra um erro localizado
- **AND** não mostra feedback de sucesso
- **AND** não dá refresh no `/me` de onboarding

### Requirement: Onboarding de PERSONAL_ADDRESS é o bloco vazio, não banner no shell

Enquanto `pendingSteps` contiver `PERSONAL_ADDRESS`, o app MUST NOT adicionar banner novo de onboarding (nem controle de pular) nos shells de cliente, motorista ou assistente para esse passo.

O cartão de endereço vazio em dados pessoais é a UI do passo pendente. Depois de um PUT ok e do refresh seguinte de `GET /api/user/me`, `PERSONAL_ADDRESS` MUST sumir de `pendingSteps` quando o back tirar. Depois de um DELETE ok e do refresh seguinte de `GET /api/user/me`, `PERSONAL_ADDRESS` MUST voltar a `pendingSteps` quando o back colocar. O banner de `SERVICE_AREA` no shell do motorista MUST permanecer como está.

#### Scenario: Casa pendente, pessoa abre dados pessoais

- **WHEN** `pendingSteps` contém `PERSONAL_ADDRESS`
- **AND** a pessoa abre dados pessoais
- **THEN** ela vê o bloco de endereço vazio
- **AND** nenhum banner novo de shell foi introduzido para este passo

#### Scenario: Casa gravada limpa o passo via refresh do perfil

- **WHEN** o PUT `/address` passa
- **AND** o `GET /api/user/me` seguinte devolve `pendingSteps` sem `PERSONAL_ADDRESS`
- **THEN** o perfil da sessão não lista mais esse passo

#### Scenario: Casa apagada devolve o passo via refresh do perfil

- **WHEN** o DELETE `/address` passa
- **AND** o `GET /api/user/me` seguinte devolve `pendingSteps` com `PERSONAL_ADDRESS`
- **THEN** o perfil da sessão lista de novo esse passo
- **AND** a tela mostra o bloco de endereço vazio
- **AND** nenhum banner novo de shell foi introduzido para este passo

#### Scenario: Onboarding de área de atuação inalterado

- **WHEN** o `pendingSteps` de um motorista autenticado contém `SERVICE_AREA`
- **THEN** o shell do motorista ainda oferece o banner de áreas que já existe
- **AND** essa oferta é independente da casa

### Requirement: Menu de perfil não tem item separado de Endereços

O app MUST NOT mostrar entrada de menu de perfil para endereços. A casa da conta só é editada em dados pessoais.

#### Scenario: Menu de perfil do cliente

- **WHEN** um CLIENT abre o menu de perfil
- **THEN** a lista não tem linha Endereços

#### Scenario: Menus de motorista e assistente

- **WHEN** um DRIVER ou ASSISTANT abre o menu de perfil
- **THEN** a lista não tem linha Endereços

### Requirement: Endereço pessoal não usa Google Places

O formulário de endereço residencial MUST ser o formulário postal de `postal-address-form`. O app MUST NOT mostrar autocomplete do Google Places nessa tela, MUST NOT exigir chaves de Places para cadastrar a casa, e MUST NOT resolver a casa por Place Details.

Google Places continua só em busca de motorista, área de atuação e (quando o client existir) escola.

#### Scenario: Dados pessoais não pedem place

- **WHEN** a pessoa abre dados pessoais para cadastrar a casa
- **THEN** não há campo de autocomplete do Places no bloco de endereço
- **AND** o save da casa não envia `placeId`

#### Scenario: Places permanece nos outros fluxos

- **WHEN** a pessoa busca motorista ou edita área de atuação
- **THEN** esses fluxos continuam escolhendo lugar por autocomplete e enviando `placeId`
