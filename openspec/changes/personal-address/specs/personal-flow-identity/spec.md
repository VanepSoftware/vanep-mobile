## Purpose

A main trouxe uma identidade visual nova, aplicada primeiro ao fluxo nativo de autenticação: fundo branco, azul de ação, campos com rótulo acima e borda fina, botões de raio 10. Ela será replicada ao app inteiro, mas não agora. Esta capability a aplica **só** em dados pessoais (com o bloco de endereço), na lista e no formulário de dependentes, e nos sheets que essas telas abrem. O resto do app fica como está.

## ADDED Requirements

### Requirement: A identidade nova vale só nas telas do escopo

O app SHALL aplicar a identidade nova de auth nestas telas e apenas nelas: `PersonalDataPage` (incluindo o cartão de endereço residencial e o sheet de troca de e-mail), a tela de endereço da conta (`PersonalAddressFormPage`), `DependentsPage`, `DependentFormPage` e o `VanepCityPickerSheet` que as telas de endereço abrem.

O app MUST NOT restilizar outras telas nesta change: gaveta de conta (`AccountDrawer`, que substituiu a `ProfilePage` no PR #69), shells de cliente/motorista/assistente, busca de motorista, áreas de atuação, home. Essas telas já têm o visual do refactor da main; esta change não mexe nele. O visual dessas telas MUST NOT mudar por esta change. As edições de comportamento que ela faz nelas (remover a linha Endereços do menu, tratar o 400 de cidade sem município IBGE na busca e na área) e a troca de import do chrome de auth movido para core não são restyle.

A única alteração no cadastro é o controle de gênero, que passa a ser o `VanepGenderSelect` (`gender-select`); o resto do cadastro não é tocado.

`VanepTextField` e `VanepPrimaryButton` foram alterados **pela main** direto em `lib/core/ui/` (azul de ação, campos com label acima); qualquer tela que já os usa herda isso sem esta change. Esta change MUST NOT fazer restyle adicional dessas telas.

#### Scenario: Telas do escopo usam a identidade nova

- **WHEN** a pessoa abre dados pessoais, a lista de dependentes ou o formulário de dependente
- **THEN** a tela tem fundo branco e barra superior branca
- **AND** os campos têm o rótulo acima e borda fina
- **AND** as ações principais são azul de ação

#### Scenario: Outras telas não mudam

- **WHEN** a pessoa abre o menu de perfil, a busca de motorista ou as áreas de atuação
- **THEN** o layout, as cores e os componentes dessas telas são os que eram antes desta change
- **AND** nenhum widget delas foi trocado por componente da identidade nova por esta change

### Requirement: Tokens e componentes da identidade

O app SHALL usar, nas telas do escopo, só os tokens do design system: `VanepColors.action` como cor de ação (botão primário, foco do campo, links, badge de padrão), `VanepColors.card` como fundo de tela, `VanepColors.inputBorder` / `VanepColors.cardBorder` para bordas, `VanepColors.placeholder` para dica, `VanepTypography.fieldLabel` / `fieldValue` para campo, `loginTitle` / `cardTitle` / `cardSubtitle` para texto. `VanepColors.brand` (ciano) MUST NOT ser usado como cor de ação nessas telas.

Campo editável MUST usar `VanepTextField`. Campo somente leitura (documento, data de nascimento, e-mail) MUST usar o mesmo componente em modo somente leitura / desabilitado, com o mesmo rótulo acima. O campo com sublinhado inline (`PersonalDataInlineField`) MUST deixar de existir. Ação primária MUST usar `VanepPrimaryButton`; ação secundária, `VanepSecondaryButton`.

O chrome de página que auth já usa (barra superior, cabeçalho, painel com borda, barra inferior com o botão, linha de campos, espaçamento) hoje mora em `lib/modules/auth/`. O app MUST movê-lo para `lib/core/ui/` (`VanepAppBar`, `VanepPageHeader`, `VanepIconBadge`, `VanepBottomBar`, `VanepOutlinedPanel`, `VanepFieldRow`, `withSpacing`), e as telas de auth MUST importá-lo de lá. A movimentação MUST NOT mudar a aparência nem o comportamento das telas de auth.

Copy só em ARB. Feedback (`VanepFeedback`) e diálogo de confirmação (`showVanepConfirmDialog`) seguem os componentes de core como estão; o diálogo destrutivo já usa `VanepColors.danger`.

#### Scenario: Campo somente leitura tem o mesmo rótulo

- **WHEN** dados pessoais mostra o documento e a data de nascimento
- **THEN** cada um aparece com o rótulo acima e o valor num campo desabilitado
- **AND** não há o estilo de valor solto do layout anterior

#### Scenario: Sem campo sublinhado

- **WHEN** a pessoa edita nome ou telefone
- **THEN** o campo é um `VanepTextField` com rótulo acima e borda
- **AND** não é um campo com sublinhado inline

#### Scenario: Movimentação do chrome não altera auth

- **WHEN** o chrome de página passa para `lib/core/ui/`
- **THEN** as telas de login, cadastro, verificação e reset renderizam como antes
- **AND** os testes existentes passam sem edição

### Requirement: Estrutura das telas do escopo

Dados pessoais SHALL ter barra superior sem título (`VanepAppBar`), corpo rolável que começa com um cabeçalho (`VanepPageHeader`, com título e subtítulo, como nas telas de auth) e segue com os campos da conta soltos sobre o fundo, sem moldura, e depois o cartão de endereço residencial (título, resumo e a ação de cadastrar ou o menu Editar / Limpar endereço), que é o único elemento da tela num painel com borda (`VanepOutlinedPanel`), e uma barra inferior (`VanepBottomBar`) com o Salvar do perfil. A tela de endereço da conta SHALL ter barra superior sem título, um cabeçalho no corpo (`VanepPageHeader`, com título e subtítulo, como nas telas de auth), o `VanepPostalAddressForm` e uma barra inferior com o Salvar do endereço. Lista de dependentes SHALL mostrar cada dependente num `VanepOutlinedPanel`, com o dependente padrão destacado (`highlighted`) e um badge de padrão em tom de ação; o botão de adicionar fica na barra inferior. O formulário de dependente SHALL seguir o mesmo esqueleto: barra superior, campos `VanepTextField`, formulário postal, barra inferior com o Salvar. Estados de carregamento e de erro com retry usam o mesmo esqueleto e os mesmos botões.

`VanepScreenBackground` e `VanepGlassCard` MUST NOT ser usados nessas telas. Os dois widgets deixaram de existir no app (apagados pela main no PR #69), então nenhuma tela pode usá-los.

#### Scenario: Dependente padrão destacado

- **WHEN** a lista mostra dois dependentes e um é o padrão
- **THEN** o padrão aparece com painel destacado e badge de padrão em tom de ação
- **AND** o outro aparece com painel comum

#### Scenario: Salvar na barra inferior

- **WHEN** a pessoa abre dados pessoais ou o formulário de dependente
- **THEN** o botão Salvar fica numa barra inferior fixa com borda superior
- **AND** o conteúdo rola por cima dela sem ser coberto
