## Purpose

Mostra ao responsável quais dados ainda faltam a um dependente para ele entrar num contrato, conforme a checagem de prontidão contratual do back, para que o app nunca reimplemente essa regra.

## ADDED Requirements

### Requirement: A prontidão é lida do back

O app SHALL obter a prontidão por `GET /api/clients/me/contract-readiness` com os tokens dos dependentes exibidos. SHALL enviar uma requisição para todos os dependentes da lista, e uma requisição para o dependente aberto no detalhe. SHALL usar só as entradas com `subject` `DEPENDENT`. Entradas com `subject` `CLIENT` SHALL ser ignoradas pelas telas de dependentes. Um dependente está pronto quando nenhuma entrada `DEPENDENT` traz o token dele.

Quando o cliente não tem dependentes, o app SHALL NOT enviar a requisição.

#### Scenario: Uma requisição para a lista inteira

- **WHEN** a lista carrega três dependentes
- **THEN** o app envia uma única requisição de prontidão com os três tokens

#### Scenario: Itens do cliente são ignorados

- **WHEN** a resposta tem só `{subject: CLIENT, field: PHONE}`
- **THEN** todos os dependentes são tratados como prontos

#### Scenario: Sem dependentes

- **WHEN** a lista de dependentes está vazia
- **THEN** nenhuma requisição de prontidão é enviada

### Requirement: Checklist de prontidão no detalhe

Quando o dependente aberto não está pronto, o detalhe SHALL mostrar um card "Cadastro incompleto" com:

- a legenda "Cadastro incompleto" e um contador "<feitos> de 4";
- o título "Complete o cadastro para pedir orçamento";
- quatro itens, nesta ordem: Data de nascimento (`BIRTH_DATE`), Embarque (`ADDRESS`), Escola (`SCHOOL`), Dias e turnos (`SCHOOL_DAYS`). Um item está feito quando nenhuma entrada `DEPENDENT` deste dependente traz o campo dele. Item feito mostra um check verde e texto apagado. Item faltando mostra um círculo vazio e texto em negrito;
- um botão "Completar cadastro" que abre o wizard de criação no modo de completar (`dependent-creation-wizard`).

Quando o dependente está pronto, ou quando não foi possível ler a prontidão, o card SHALL NOT aparecer.

#### Scenario: Dois itens faltando

- **WHEN** a prontidão informa `SCHOOL` e `SCHOOL_DAYS` para o dependente aberto
- **THEN** o card mostra "2 de 4"
- **AND** Data de nascimento e Embarque aparecem marcados, e Escola e Dias e turnos não

#### Scenario: Dependente pronto

- **WHEN** a prontidão não informa nada para o dependente aberto
- **THEN** o card "Cadastro incompleto" não aparece

#### Scenario: Prontidão indisponível

- **WHEN** a requisição de prontidão falha
- **THEN** o detalhe aparece sem o card e sem mensagem de erro

### Requirement: A prontidão é atualizada depois de uma edição

Depois que qualquer editor ou o wizard salva uma mudança num dependente, o app SHALL consultar a prontidão de novo antes de mostrar o detalhe ou a lista.

#### Scenario: O último item que faltava foi preenchido

- **WHEN** o responsável salva a grade de um dependente cujo único item faltando era `SCHOOL_DAYS`
- **THEN** o detalhe não mostra mais o card "Cadastro incompleto"
- **AND** a linha da lista não mostra mais "Cadastro incompleto"
