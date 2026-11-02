## Purpose

Dá ao motorista, na aba Propostas, a lista das negociações abertas, o pedido de orçamento com o que ele precisa para dar o preço e o pedido de ajuste da família, com as ações de recusar e de responder.

## ADDED Requirements

### Requirement: Aba Propostas

A aba Propostas do motorista SHALL trocar o "Em breve" pela tela "Propostas", com o controle "Negociações" / "Contratos". "Negociações" SHALL mostrar o número de negociações abertas. "Contratos" SHALL abrir "Em breve".

#### Scenario: Abrir a aba

- **WHEN** o motorista toca em Propostas na barra de baixo
- **THEN** a lista de negociações aparece

### Requirement: Lista de negociações

A lista SHALL mostrar "Pendentes" (pedido novo e ajuste solicitado) e "Aguardando resposta" (proposta enviada), conforme a regra de vez da `negotiation-data`. Cada item SHALL mostrar "<primeiro nome do responsável> · <filhos>", a escola e o turno, o bairro de embarque e os dias com o início, e:

- pedido novo: "Pedido novo" e "Expira em n dias" pelo `expiresAt`;
- ajuste solicitado: "Ajuste solicitado", sem o valor sugerido;
- aguardando: o valor em parcelas e "Expira em n dias" pela validade da proposta.

"Família <sobrenome>", "~n min da rota", vagas e origem do cliente SHALL NOT aparecer.

#### Scenario: Pedido para dois irmãos

- **WHEN** Maria pediu orçamento para Theo e Alice
- **THEN** o item mostra "Maria · Theo e Alice"

### Requirement: Pedido de orçamento

O pedido SHALL mostrar o responsável (primeiro nome), quando o pedido chegou e "Conversar", os alunos (primeiro nome e idade, escola e turno), o trajeto (bairro de embarque e escola), o aviso "Endereço completo após o aceite", os dias e trechos pedidos, o início desejado e a mensagem da família. O rodapé SHALL ter "Recusar" e "Montar proposta". Ocupação, acréscimo na rota e comissão SHALL NOT aparecer.

#### Scenario: Abrir um pedido novo

- **WHEN** o motorista toca num pedido novo
- **THEN** o pedido aparece com "Recusar" e "Montar proposta"

### Requirement: Recusar o pedido

"Recusar" SHALL pedir confirmação com um motivo opcional (até 500 caracteres) e recusar o pedido. No sucesso, a negociação SHALL sair da lista.

#### Scenario: Recusa sem motivo

- **WHEN** o motorista confirma a recusa sem escrever motivo
- **THEN** o pedido é recusado e some da lista

### Requirement: Ajuste solicitado

A tela do ajuste SHALL mostrar "Conversar", o pedido de ajuste, a versão atual (versão, valor, dias, embarque e validade), "Ver proposta completa" e o histórico, com a linha "Uma nova versão substitui a anterior.". O rodapé SHALL ter "Recusar" (recusa o pedido) e "Nova versão" (abre o montar proposta preenchido com a versão atual). "Manter atual" e "você receberia" SHALL NOT aparecer.

O pedido de ajuste SHALL ser um card com borda azul que começa com "AJUSTE SOLICITADO · <ASSUNTO>" e, à direita, quando foi enviado ("hoje, 9h40", "ontem, 18h05" ou "30/09, 7h00"). No meio, o valor da versão vigente ("Versão n") SHALL aparecer à esquerda e o valor sugerido ("Sugerido"), em azul, à direita, com uma seta entre os dois, quando o assunto é valor, parcelas ou período. Nos dias e horários e em "Outro", só "Sugerido" aparece. Sem valor sugerido, o meio SHALL NOT aparecer. A mensagem SHALL aparecer num bloco cinza no fim. Os rótulos "Assunto" e "Enviado em" SHALL NOT aparecer.

#### Scenario: Valor sugerido comparado

- **WHEN** a parcela da versão 1 é R$ 340 e a família sugere R$ 290
- **THEN** o card mostra "AJUSTE SOLICITADO · VALOR", "Versão 1: R$ 340" e "Sugerido: R$ 290"

#### Scenario: Responder com nova versão

- **WHEN** o motorista toca em "Nova versão"
- **THEN** o montar proposta abre com os valores da versão atual

### Requirement: Proposta para leitura

"Ver proposta completa" e o toque num item "Aguardando resposta" SHALL abrir a proposta só para leitura, com os mesmos dados que o responsável vê no detalhe, os alunos pelo primeiro nome e sem ações além de "Conversar".

#### Scenario: Proposta enviada

- **WHEN** o motorista abre uma proposta que espera a família
- **THEN** a proposta aparece sem botões de ação
