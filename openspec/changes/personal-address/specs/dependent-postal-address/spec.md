## Purpose

O back refatorou o endereço do dependente: `address` em `POST/PATCH /api/dependent` deixou de ser Places (`placeId` + `sessionToken`) e passou a ser o mesmo formulário postal IBGE da casa da conta (`cityToken`, `street`, `zipCode`, opcionais). Esta capability descreve o endereço do dependente no app com esse contrato. Ela **supera** a capability `dependent-address` da change `client-dependents` (Places), que descrevia o contrato anterior. Escola continua por Places e fica fora.

Os campos, o CEP, o picker e as regras de completude são os de `postal-address-form`; aqui ficam só o que é específico do dependente.

## ADDED Requirements

### Requirement: O endereço do dependente é formulário postal, não Places

O app SHALL coletar o endereço do dependente com o formulário postal compartilhado (`postal-address-form`) e MUST enviá-lo em `address` de `POST /api/dependent` e `PATCH /api/dependent/{token}` como objeto com `cityToken`, `street`, `zipCode` (8 dígitos, sem hífen) e `number`, `complement`, `neighborhood` sempre presentes (valor ou `null`).

O app MUST NOT enviar `placeId` nem `sessionToken` no `address` do dependente. O back os ignora e nunca chama o Places nesse caminho. O formulário de dependente MUST NOT ter `VanepPlaceAutocompleteField` nem `PlaceAutocompleteController`. `lib/core/places/` continua existindo para busca de motorista e área de atuação.

O CEP, o picker de município e as regras de completude do rascunho são os de `postal-address-form`. O CLIENT MUST poder usar `/api/cep`, `/api/states` e `/api/cities` sem permissão extra.

#### Scenario: Dependente criado com endereço postal

- **WHEN** o cliente cria um dependente com nome, `cityToken`, rua e CEP de 8 dígitos
- **THEN** o body do POST traz `address` com `cityToken`, `street`, `zipCode`, `number`, `complement` e `neighborhood`
- **AND** `address` não contém `placeId` nem `sessionToken`

#### Scenario: Formulário de dependente sem Places

- **WHEN** o cliente abre o formulário de dependente
- **THEN** o endereço é o formulário postal
- **AND** não há campo de autocomplete do Places

### Requirement: O endereço é editado numa tela própria, aberta por um cartão

O formulário de dependente SHALL mostrar o endereço num cartão (`VanepAddressCard`, o mesmo componente do cartão de endereço residencial da conta), e não como campos soltos. Sem endereço, o cartão mostra o texto “sem endereço” e a ação de cadastrar. Com endereço, mostra o resumo (rua, número e complemento; bairro, município/UF e CEP) e um menu com Editar e Limpar endereço. Cadastrar e Editar abrem uma tela própria (`DependentAddressFormPage`) com o `VanepPostalAddressForm` e o `VanepCityPickerSheet`, no mesmo esqueleto da tela de endereço da conta.

O botão da tela de endereço é **Confirmar endereço** e MUST NOT emitir request: ele só valida o rascunho e devolve a pessoa ao formulário de dependente, e quem grava é o Salvar do dependente, com um único POST/PATCH. Rascunho incompleto MUST mostrar o que falta na própria tela e MUST NOT fechá-la. CEP inexistente e lookup pendente MUST desabilitar o botão. Sair da tela sem confirmar (voltar) MUST descartar as edições e restaurar o endereço que a tela recebeu ao abrir, cancelando um lookup pendente.

Limpar endereço no menu MUST tirar o endereço do rascunho sem request nem diálogo de confirmação, porque só o Salvar do dependente grava; o Salvar então envia `"address": null` se o dependente já tinha endereço. O cartão MUST mostrar a falha de cidade não encontrada (404) e o rascunho incompleto que impediria o Salvar, como texto de erro localizado.

#### Scenario: Cadastrar o endereço pelo cartão

- **WHEN** o dependente não tem endereço e o cliente toca em Cadastrar endereço
- **THEN** abre a tela de endereço, com o título de cadastro
- **AND** ao preencher o CEP e tocar em Confirmar endereço a tela fecha e o cartão mostra o resumo
- **AND** nenhum request de dependente foi emitido

#### Scenario: Editar o endereço pelo menu

- **WHEN** o dependente tem endereço e o cliente escolhe Editar endereço no menu do cartão
- **THEN** a tela abre com o endereço preenchido e o título de edição

#### Scenario: Voltar sem confirmar descarta

- **WHEN** o cliente altera o número na tela de endereço e volta sem confirmar
- **THEN** o rascunho volta ao endereço que a tela recebeu
- **AND** o cartão mostra o resumo de antes

#### Scenario: Endereço incompleto não confirma

- **WHEN** o cliente preencheu só a rua e toca em Confirmar endereço
- **THEN** a tela mostra o que falta e continua aberta

#### Scenario: Limpar pelo cartão

- **WHEN** o dependente tem endereço e o cliente escolhe Limpar endereço e salva
- **THEN** o cartão volta ao estado sem endereço
- **AND** o PATCH traz `"address": null`

#### Scenario: Cidade rejeitada pelo back aparece no cartão

- **WHEN** o POST ou PATCH devolve 404 de cidade
- **THEN** o cartão mostra o erro de cidade não encontrada
- **AND** ao tocar em Editar a tela abre no fallback manual, com o município a escolher

### Requirement: Endereço é opcional; em branco significa sem endereço

O app SHALL permitir salvar o dependente sem endereço, porque só `name` é obrigatório. Um rascunho de endereço **em branco** significa “sem endereço”. Um rascunho **parcialmente preenchido** e incompleto MUST bloquear o save com erro localizado por campo (cidade, rua, CEP) e MUST NOT enviar request. O back recusa `address` sem `cityToken`, `street` ou `zipCode` com 400; o app não deixa chegar lá.

No create, endereço em branco MUST omitir a chave `address` do body.

#### Scenario: Dependente sem endereço

- **WHEN** o cliente salva só com o nome
- **THEN** o body não tem a chave `address`

#### Scenario: Endereço incompleto bloqueia o save

- **WHEN** o cliente preencheu a rua mas não escolheu município nem CEP e salva
- **THEN** o app mostra erro localizado nos campos que faltam
- **AND** não envia request

### Requirement: Editar o endereço reenvia o formulário completo

Num `PATCH /api/dependent/{token}`, `address` presente é **substituição completa** do endereço do dependente, no mesmo molde de `PUT /api/user/me/address`: o back sobrescreve a linha existente (mesmo `address.id`) e opcional omitido ou `null` vira `null` armazenado. Não há amend parcial: `address` sem `cityToken`, `street` ou `zipCode` é 400, mesmo quando o dependente já tem endereço.

O app SHALL remontar o formulário a partir do `address` da resposta de leitura, que devolve `cityToken`, `street`, `zipCode`, `number`, `complement` e `neighborhood`. Quando o endereço mudou, o app MUST enviar o objeto postal completo, mesmo que só o número tenha mudado. Quando não mudou, MUST omitir a chave `address` (omitir deixa o armazenado intacto). Quando a pessoa removeu o endereço, MUST enviar `"address": null` (o back faz soft-delete da linha).

O app MUST NOT mandar só `number` / `complement` (o modo de amend da versão Places deixou de existir).

#### Scenario: Corrigir só o número reenvia tudo

- **WHEN** o dependente tem endereço e o cliente muda só o número e salva
- **THEN** o body traz `address` completo com o número novo e os demais campos como estavam
- **AND** não traz um `address` só com `number`

#### Scenario: Endereço não mudou

- **WHEN** o cliente muda só o nome e salva
- **THEN** o body traz `name` e não traz `address`

#### Scenario: Remover o endereço

- **WHEN** o dependente tem endereço e o cliente o remove e salva
- **THEN** o body traz `"address": null`

#### Scenario: Trocar a cidade

- **WHEN** o cliente escolhe outro município e salva
- **THEN** o body traz `address` completo com o `cityToken` novo

### Requirement: O endereço é exibido como o back devolveu

O app SHALL mostrar o endereço do dependente a partir do `address` da resposta (`AddressResponseDTO`): rua, número, complemento, `neighborhood`, cidade, UF e CEP. O app MUST NOT usar `district` (é `null` nesse caminho) nem reconstruir o endereço a partir de texto de sugestão. Dependente sem endereço MUST aparecer como “sem endereço”, não como endereço vazio.

#### Scenario: Endereço gravado aparece completo

- **WHEN** o back devolve o dependente com `address` (rua, número, bairro, cidade, UF, CEP)
- **THEN** o cartão e o formulário mostram esses valores
- **AND** não mostram distrito

#### Scenario: Dependente sem endereço

- **WHEN** o dependente devolvido tem `address` nulo
- **THEN** o app mostra o estado localizado de “sem endereço”

### Requirement: Falhas do endereço do dependente são localizadas

O app SHALL mapear as falhas de escrita do dependente que envolvem `address`:

| Resposta | Tratamento |
|---|---|
| 404 de cidade (`cityToken` desconhecido ou inativo; `detail` de “Cidade não encontrada”) | erro localizado no seletor de município; mantém os rascunhos |
| 404 de dependente | falha de dependente não encontrado, como hoje |
| 400 de validação | falha de validação genérica localizada; o `detail` do back não vai para a tela |
| 409 (linha de endereço já é de outra posse) | falha inesperada localizada; o app não compartilha endereço com escola, então não é fluxo esperado |
| sem resposta | falha de rede |

O back não manda `code` no 404; o app distingue cidade de dependente pelo `detail`, com marcador (mesmo molde de `districtRequiredMarker` em área de atuação). No `POST` só cidade pode dar 404.

#### Scenario: Município desconhecido no PATCH

- **WHEN** o PATCH devolve 404 com `detail` de cidade não encontrada
- **THEN** o app mostra o erro no seletor de município
- **AND** mantém nome, data, gênero e o resto do endereço

#### Scenario: Município desconhecido no POST

- **WHEN** o POST devolve 404
- **THEN** o app trata como cidade não encontrada

#### Scenario: Dependente removido em outro aparelho

- **WHEN** o PATCH devolve 404 com `detail` de dependente não encontrado
- **THEN** o app mostra a falha de dependente não encontrado
- **AND** não a atribui à cidade

### Requirement: O contrato novo vai no mesmo release da API

O `address` postal do dependente é breaking no back (`placeId` deixa de ser aceito como contrato). App antigo que manda só `placeId` no dependente recebe 400. O app novo MUST NOT mandar `placeId`. A entrega desta capability MUST NOT ser mergeada antes de a API com o contrato postal estar no ar (R21: até lá, mock/stub do datasource).

#### Scenario: Release coordenado

- **WHEN** o app com esta capability é publicado
- **THEN** a API com `DependentAddressRequestDTO` postal já está implantada
