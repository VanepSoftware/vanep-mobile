## Purpose

Fonte dos alunos do motorista: o aluno não vinculado vem da API; os alunos com família, o convite e a junção ficam atrás de um contrato de domínio, hoje fictício.

## ADDED Requirements

### Requirement: Listar os alunos não vinculados

O app SHALL ler `GET /api/drivers/me/unlinked-passengers` e mapear cada item em `UnlinkedPassenger`: token, nome, escola (token e nome), turno escolar, endereço, observações e slots (dia, trecho, turno, horário).

#### Scenario: Lista com um aluno

- **WHEN** o back devolve um aluno com slots `MONDAY OUTBOUND MORNING 06:40` e `MONDAY RETURN AFTERNOON 12:10`
- **THEN** o repositório devolve um `UnlinkedPassenger` com os dois slots

#### Scenario: Falha de rede

- **WHEN** a requisição não tem resposta
- **THEN** o repositório devolve `UnlinkedPassengerFailure.network`

### Requirement: Cadastrar o aluno não vinculado

O app SHALL enviar `POST /api/drivers/me/unlinked-passengers` com `name`, `schoolToken`, `schoolShift`, `address` (`cityToken`, `street`, `zipCode` com 8 dígitos, `number`, `complement` e `neighborhood`), `notes` e `slots` (`weekday`, `leg`, `shift`, `pickupTime` "HH:mm"). Campos opcionais vazios SHALL ir como `null`.

#### Scenario: Cadastro aceito

- **WHEN** o back responde 201
- **THEN** o repositório devolve o `UnlinkedPassenger` criado

#### Scenario: Validação do back

- **WHEN** o back responde 400 ou 422 com `detail`
- **THEN** o repositório devolve `UnlinkedPassengerFailure.validation` com a mensagem

### Requirement: Alunos com família, convite e junção atrás de um contrato

O domínio SHALL expor um `StudentFamilyRepository` com `listStudentsWithFamily`, `listFamilyLinks`, `inviteFamily`, `confirmMatch`, `dismissMatch` e `findParentsGroupLink`. Enquanto o back não existir, a implementação SHALL ser um datasource fictício em memória, marcado com `TODO(VAN-57)`, em que convidar, juntar e "não é" mudam o estado devolvido nas leituras seguintes da mesma sessão.

#### Scenario: Convidar muda o estado

- **WHEN** o motorista convida a família do aluno A
- **THEN** a próxima leitura de `listFamilyLinks` devolve A como `invited` com a data de agora

#### Scenario: Juntar tira o aluno da lista sem família

- **WHEN** o motorista confirma a junção do aluno A
- **THEN** A deixa de ter vínculo pendente e passa a aparecer em `listStudentsWithFamily`
