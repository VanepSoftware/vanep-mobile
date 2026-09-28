## Purpose

Gênero como select único, com “Prefiro não informar”, nos dois lugares em que o app edita gênero: dados pessoais da conta e formulário de dependente. Dados pessoais já tem o select (`PersonalDataGenderDropdown` em `auth`, com `ProfileGenderChoice`); o dependente ainda usa chips (`VanepGenderChips` em `core`). Esta capability deixa um componente só, em core, nos dois.

## ADDED Requirements

### Requirement: Gênero é um select único e pode ser omitido

A tela de dados pessoais e o formulário de dependente MUST mostrar o gênero como um único controle de escolha (não chips), o mesmo componente de `lib/core/ui/` (`VanepGenderSelect`) nos dois. As opções MUST ser Masculino, Feminino, Outro e Prefiro não informar.

Prefiro não informar MUST ser ausência de valor (`null`), não um quarto membro do enum `Gender`. O app MUST NOT inventar um código de API (`UNSPECIFIED`, `NONE`, etc.) para essa escolha. O back já aceita JSON `null` em `gender` no `PATCH /api/user/me` e no `PATCH /api/dependent/{token}`.

Chips de gênero MUST NOT permanecer em nenhuma das duas telas, e `VanepGenderChips` MUST deixar de existir. O select local de `auth` (`PersonalDataGenderDropdown`, `ProfileGenderChoice`) MUST dar lugar ao componente de core, para não haver dois selects de gênero. O botão separado “Não informar” do formulário de dependente sai: a opção do select o substitui.

#### Scenario: Select no lugar dos chips em dados pessoais

- **WHEN** a pessoa abre dados pessoais
- **THEN** o gênero aparece como um select com as quatro opções
- **AND** não há chips de gênero na tela

#### Scenario: Select no lugar dos chips no dependente

- **WHEN** o cliente abre o formulário de dependente
- **THEN** o gênero aparece como o mesmo select com as quatro opções
- **AND** não há chips nem botão separado “Não informar”

#### Scenario: Valor omitido é uma opção visível

- **WHEN** o gênero atual é `null`
- **THEN** o select mostra “Prefiro não informar” selecionado
- **AND** não mostra “—” nem um campo vazio

### Requirement: Omitir o gênero grava null na conta

Em dados pessoais, o PATCH `/api/user/me` MUST enviar `"gender": null` quando a pessoa muda de um gênero informado para Prefiro não informar. Quando o perfil já vem com gênero `null` e a pessoa não muda o select, o PATCH MUST NOT incluir a chave `gender`.

#### Scenario: Prefiro não informar grava null

- **WHEN** o perfil tem gênero Feminino
- **AND** a pessoa escolhe Prefiro não informar e salva
- **THEN** o PATCH inclui `"gender": null`
- **AND** o draft e o snapshot passam a ser null

#### Scenario: Já omitido não dispara PATCH de gênero

- **WHEN** o perfil já vem com gênero null
- **AND** a pessoa não muda o select
- **THEN** o PATCH não inclui a chave `gender`

### Requirement: Omitir o gênero apaga o valor do dependente

No formulário de dependente, escolher Prefiro não informar num dependente que tinha gênero MUST enviar `"gender": null` no PATCH (o back apaga o valor com `null` explícito). No create, gênero omitido MUST NOT incluir a chave `gender`.

#### Scenario: Limpar o gênero do dependente

- **WHEN** o dependente tem gênero e o cliente escolhe Prefiro não informar e salva
- **THEN** o PATCH traz `"gender": null`

#### Scenario: Criar sem gênero

- **WHEN** o cliente cria o dependente e deixa o gênero em Prefiro não informar
- **THEN** o POST não tem a chave `gender`
