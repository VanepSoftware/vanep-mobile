## Purpose

Define como o app lê e escreve a solicitação de orçamento e a proposta nas visões do responsável e do motorista, como deriva de quem é a vez em cada negociação e como trata os erros do back, para que todas as telas da negociação partam da mesma fonte.

## ADDED Requirements

### Requirement: Cada parte usa a própria superfície

O app SHALL usar só as superfícies `/me` do back: `/api/clients/me/service-requests` e `/api/clients/me/proposals` para o responsável, e `/api/drivers/me/service-requests` e `/api/drivers/me/proposals` para o motorista. Os dados do responsável SHALL vir da visão do cliente, com o nome completo e a data de nascimento do dependente. Os dados do motorista SHALL vir da visão do motorista, que tem só o primeiro nome e a idade do dependente, o primeiro nome do responsável e o bairro de embarque.

#### Scenario: O motorista nunca vê o nome completo

- **WHEN** o motorista abre um pedido para "Lucas Souza"
- **THEN** o app mostra "Lucas" e a idade, e nenhum texto com "Souza"

### Requirement: Listas filtradas por status

A aba Em aberto do responsável SHALL pedir `status=OPEN,ANSWERED`. A aba Encerradas SHALL pedir `status=CONVERTED,DECLINED,EXPIRED,WITHDRAWN` e carregar as páginas seguintes ao rolar até o fim. A lista do motorista SHALL pedir só `status=OPEN,ANSWERED`.

#### Scenario: Encerradas com mais de uma página

- **WHEN** o responsável tem 25 negociações encerradas e rola até o fim da aba Encerradas
- **THEN** o app carrega a segunda página e mostra as 25

### Requirement: De quem é a vez

O app SHALL derivar a situação de cada negociação só a partir do `status` da solicitação e do `currentProposal.hasPendingAdjustment`, pela tabela abaixo. Nenhuma tela SHALL recalcular essa regra por conta própria.

| `status` | `hasPendingAdjustment` | Responsável | Motorista |
|---|---|---|---|
| `OPEN` | — | esperando o motorista (pedido enviado) | precisa responder (pedido novo) |
| `ANSWERED` | `false` | precisa responder (proposta) | esperando a família |
| `ANSWERED` | `true` | esperando o motorista (ajuste pedido) | precisa responder (ajuste solicitado) |
| `CONVERTED` | — | encerrada: aceita | — |
| `DECLINED` | — | encerrada: recusada pelo motorista | — |
| `WITHDRAWN` | — | encerrada: encerrada por você | — |
| `EXPIRED` | — | encerrada: expirada | — |

#### Scenario: O responsável pediu ajuste

- **WHEN** uma solicitação está `ANSWERED` e o resumo da proposta tem `hasPendingAdjustment = true`
- **THEN** o responsável vê a negociação esperando o motorista
- **AND** o motorista vê a negociação como "Ajuste solicitado", para responder

#### Scenario: Proposta vencida reabre o pedido

- **WHEN** a proposta vigente vence e o back devolve a solicitação como `OPEN` sem `currentProposal`
- **THEN** o responsável vê o pedido esperando o motorista, e não uma negociação encerrada

### Requirement: A conversa vem do pedido

Cada solicitação SHALL trazer o `conversationToken` da conversa do par, nas duas visões, nas listas e no detalhe. "Conversar" em qualquer tela da negociação SHALL abrir essa conversa sem nenhuma chamada para abri-la. A conversa SHALL ser a mesma para todas as solicitações do par, inclusive as encerradas. Sem `conversationToken`, a tela SHALL NOT mostrar "Conversar".

#### Scenario: Segundo pedido ao mesmo motorista

- **WHEN** o responsável cancela um pedido e pede de novo ao mesmo motorista
- **THEN** "Conversar" nos dois abre a mesma conversa, com as mensagens anteriores

### Requirement: Valores vêm do back

O valor de uma proposta SHALL ser mostrado como as parcelas que o back calcula: `installments` vezes `installmentAmount` ("R$ 300/mês · 12x"; com uma parcela só, "R$ 3.600 à vista"), e o total como `totalAmount`. A última parcela vem em `lastInstallmentAmount`, que leva o resto da divisão. As parcelas vencem todo mês no dia de vencimento, então o "/mês" diz quanto a família paga por mês e o "12x", por quantos meses. Os dois SHALL aparecer sempre juntos, para que duas propostas com números de parcelas diferentes não sejam comparadas só pela mensalidade. O app SHALL NOT calcular a parcela a partir do total nem o total a partir dos valores dos alunos, com uma única exceção: a prévia da tela de montar proposta, antes do envio, aplica a mesma regra do back (total dividido pelas parcelas, centavos truncados). O preço base do motorista na busca SHALL aparecer sem parcelas ("a partir de R$ 320").

#### Scenario: Total que não divide exato

- **WHEN** o back devolve `totalAmount = 1000.00`, `installments = 3` e `installmentAmount = 333.33`
- **THEN** o card mostra "R$ 333,33/mês · 3x"

### Requirement: Prazos

O prazo de um pedido sem proposta SHALL vir de `expiresAt`. O prazo de uma proposta SHALL vir de `currentProposal.validUntil` (ou do `validUntil` da proposta aberta). O início proposto SHALL vir de `currentProposal.startsOn`; o início pedido, de `desiredStartDate`.

#### Scenario: Início proposto diferente do pedido

- **WHEN** a família pediu início em 1º de fevereiro e a proposta começa em 15 de fevereiro
- **THEN** o card da proposta mostra "a partir de 15 fev"

### Requirement: Erros do back

O app SHALL tratar as respostas de erro da negociação assim:

| Resposta | Comportamento |
|---|---|
| 404 | mensagem de "não encontrado" e volta para a tela anterior |
| 409 | mostra o `detail` do back e recarrega a negociação, porque ela mudou do outro lado (proposta vencida, substituída, cadastro mudou, pedido já aberto) |
| 422 | mostra o `detail` do back e mantém o que a pessoa preencheu |
| 400 | mensagem de dado inválido e mantém o que a pessoa preencheu |
| sem resposta | mensagem de falta de conexão e "Tentar novamente" |

#### Scenario: Aceite de uma versão substituída

- **WHEN** o responsável aceita a versão 1 e o back responde 409 porque a versão 2 chegou
- **THEN** o app mostra a mensagem do back e recarrega o detalhe, que passa a mostrar a versão 2

### Requirement: Sem push nesta fase

As listas, a Início e os detalhes SHALL recarregar ao abrir e ao puxar para atualizar. O app SHALL NOT depender de notificação para saber que algo mudou.

#### Scenario: Proposta chegou com a lista aberta

- **WHEN** o motorista manda uma proposta enquanto o responsável está com a lista aberta
- **THEN** a proposta aparece depois que o responsável puxa para atualizar
