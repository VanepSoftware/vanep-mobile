## Purpose

Permite ao responsável criar um dependente e editar os dados pessoais dele (nome, nascimento, gênero e CPF opcional) numa única tela, com um botão de salvar próprio.

## ADDED Requirements

### Requirement: Formulário de dados pessoais

O editor de Dados pessoais SHALL ter um cabeçalho com o botão de voltar, o título "Dados pessoais" e o primeiro nome do dependente como legenda (sem legenda durante a criação). SHALL mostrar, nesta ordem:

- **Nome**, obrigatório, com no máximo 255 caracteres;
- **Data de nascimento**, digitada como `dd/mm/aaaa` com um ícone de calendário, opcional, sem ser no futuro;
- **Sexo**, um select com Feminino (`FEMALE`), Masculino (`MALE`), Outro (`OTHER`) e Prefiro não informar (sem valor);
- **CPF (opcional)**, com máscara `000.000.000-00`, opcional, e quando preenchido SHALL passar na checagem dos dígitos verificadores.

As mensagens de validação SHALL aparecer embaixo do campo depois que o responsável sai dele ou tenta salvar.

#### Scenario: Nome em branco

- **WHEN** o responsável apaga o nome e toca em "Salvar"
- **THEN** o campo de nome mostra a mensagem de campo obrigatório e nada é enviado

#### Scenario: CPF inválido

- **WHEN** o responsável digita "111.111.111-11" e toca em "Salvar"
- **THEN** o campo de CPF mostra a mensagem de CPF inválido e nada é enviado

#### Scenario: Nascimento no futuro

- **WHEN** o responsável digita uma data de nascimento depois de hoje
- **THEN** o campo de nascimento mostra a mensagem de data inválida

### Requirement: Salvar os dados pessoais

Na edição, "Salvar" SHALL enviar `PATCH /api/dependent/{token}` só com os campos que mudaram: `name`, `birthDate` (ISO `yyyy-mm-dd`, ou `null` quando foi apagada), `gender` (ou `null` para Prefiro não informar), `document` (os 11 dígitos do CPF, sem máscara, ou `null` quando foi apagado). "Salvar" SHALL ficar desabilitado enquanto nada mudou. Na criação, o mesmo formulário SHALL enviar `POST /api/dependent` com os campos preenchidos. Com sucesso, o editor SHALL devolver o dependente salvo para quem abriu. Com falha, SHALL continuar aberto com o que foi digitado e mostrar a mensagem do back, ou uma genérica quando não há.

#### Scenario: Mudar só o nome

- **WHEN** o responsável muda o nome para "Ana Clara Oliveira" e salva
- **THEN** o body do `PATCH` é `{"name": "Ana Clara Oliveira"}`

#### Scenario: Apagar o CPF

- **WHEN** o responsável apaga um CPF que estava salvo e salva
- **THEN** o body do `PATCH` tem `"document": null`

#### Scenario: CPF já usado por outro dependente

- **WHEN** o back responde HTTP 409 porque o CPF já pertence a outro dependente
- **THEN** o editor continua aberto com o que foi digitado
- **AND** mostra a mensagem do back, "Já existe um dependente cadastrado com este documento."

#### Scenario: Gênero não informado

- **WHEN** o responsável escolhe Prefiro não informar numa dependente salva como Feminino
- **THEN** o body do `PATCH` tem `"gender": null`
