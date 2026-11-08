## Purpose

Mostra ao responsável as negociações dele a partir da API, agrupadas pelo que ele precisa fazer, com o filtro por filho, as encerradas e o cancelamento de um pedido.

## ADDED Requirements

### Requirement: Em aberto agrupada pela vez

A aba Em aberto SHALL mostrar "Pendentes" com as negociações em que o responsável precisa responder e "Aguardando resposta" com as que esperam o motorista, conforme a regra de vez da `negotiation-data`. Uma seção sem itens SHALL NOT aparecer.

#### Scenario: Ajuste pedido fica aguardando

- **WHEN** o responsável pediu ajuste numa proposta
- **THEN** a negociação aparece em "Aguardando resposta", e não em "Pendentes"

### Requirement: Card de proposta pendente

O card SHALL mostrar:

- o nome do motorista e a nota (`driverRating`), quando houver. Sem nota, só o nome. O card SHALL NOT mostrar veículo nem "Nova na Vanep";
- "Para <filhos> · <escola>, <turno>". Com mais de um filho, os nomes juntos ("Ana e Pedro"); escolas diferentes aparecem separadas; o turno é o período da grade pedida, ou "turno varia" quando muda entre os dias;
- "<dias> · a partir de <início proposto>", com "Seg a sex" quando são os cinco dias úteis;
- o valor em parcelas e "Expira em n dias" pela validade da proposta;
- "Conversar" e "Ver proposta".

O card SHALL NOT mostrar "antes R$ X".

#### Scenario: Dois irmãos no mesmo pedido

- **WHEN** a proposta é para Ana e Pedro, os dois no Colégio Delta à tarde
- **THEN** o card mostra "Para Ana e Pedro · Colégio Delta, tarde"

#### Scenario: Motorista sem nota

- **WHEN** `driverRating` é `null`
- **THEN** o card mostra só o nome do motorista

### Requirement: Card de pedido aguardando

Para um pedido `OPEN`, o card SHALL mostrar o motorista, "Para <filhos> · enviado <quando>", as horas que faltam até `expiresAt`, "Cancelar pedido" e "Ver pedido". Para uma proposta com ajuste pedido, o card SHALL mostrar "Ajuste solicitado", a validade da versão atual e "Ver proposta".

#### Scenario: Pedido enviado ontem

- **WHEN** o pedido foi criado ontem e vence em 52 horas
- **THEN** o card mostra "Para o Pedro · enviado ontem" e "Faltam 52h"

### Requirement: Encerradas

A aba Encerradas SHALL mostrar o motorista, os filhos e o resultado, sem valor: "Aceita" (`CONVERTED`), "Recusada pelo motorista" (`DECLINED`), "Encerrada por você" (`WITHDRAWN`) e "Expirada" (`EXPIRED`). A aba SHALL carregar mais itens ao rolar até o fim.

#### Scenario: O responsável recusou a proposta

- **WHEN** o responsável recusou uma proposta e o back devolve a solicitação como `WITHDRAWN`
- **THEN** a encerrada mostra "Encerrada por você"

### Requirement: Contador e abas

O controle Em aberto / Encerradas SHALL mostrar a quantidade de cada aba no filtro atual. A linha "n de 5 solicitações abertas" SHALL contar as negociações `OPEN` e `ANSWERED` de todos os filhos e não muda com o filtro.

#### Scenario: Filtro aplicado

- **WHEN** o responsável filtra pelo Pedro, que tem 1 de 3 negociações abertas
- **THEN** a aba mostra 1 e a linha continua "3 de 5 solicitações abertas"

#### Scenario: Encerradas de um filho em várias páginas

- **WHEN** o responsável tem 30 encerradas e filtra pela Ana, que tem 2 delas, uma na segunda página
- **THEN** o app carrega as páginas de encerradas até o fim e a aba Encerradas mostra 2

### Requirement: Filtro por filho

Com mais de um dependente, a tela SHALL mostrar o botão "Todos os filhos" com a gaveta "Ver propostas de", uma opção por dependente com a idade e o resumo ("2 para responder · 1 aguardando", "Nenhuma em aberto"). Uma negociação SHALL aparecer no filtro de um filho quando qualquer item dela é daquele filho. Negociações de um dependente que foi removido SHALL aparecer só em "Todos os filhos". Com um dependente ou nenhum, o botão SHALL NOT aparecer.

#### Scenario: Pedido para dois irmãos

- **WHEN** um pedido é para Ana e Pedro e o responsável filtra pela Ana
- **THEN** o pedido aparece

### Requirement: Cancelar pedido

"Cancelar pedido" SHALL pedir confirmação e então retirar o pedido. No sucesso, ele SHALL sair de Em aberto e aparecer em Encerradas como "Encerrada por você", e a lista SHALL ser recarregada do back.

#### Scenario: Cancelamento confirmado

- **WHEN** o responsável confirma o cancelamento de um pedido `OPEN`
- **THEN** o pedido vai para Encerradas como "Encerrada por você"

### Requirement: Navegação a partir da lista

"Ver proposta" SHALL abrir o detalhe da proposta. "Ver pedido" SHALL abrir o detalhe no modo pedido. "Conversar" SHALL abrir a conversa com o motorista. A lupa e "Procurar van" do estado vazio SHALL abrir a busca de vans.

#### Scenario: Ver proposta

- **WHEN** o responsável toca em "Ver proposta"
- **THEN** o detalhe da proposta vigente daquela negociação abre
