## Purpose

Mostra a negociação do par dentro da conversa entre o responsável e o motorista, junto das mensagens, para que as duas partes vejam o que foi pedido e oferecido sem sair do chat.

## ADDED Requirements

### Requirement: Linha do tempo da negociação

A conversa SHALL juntar, em ordem de data e com um separador por dia, as mensagens e os eventos da negociação mais recente da conversa, lida na lista de solicitações da parte que está vendo, filtrada pelo `conversationToken` da conversa: o pedido de orçamento, cada versão da proposta e cada pedido de ajuste. As versões substituídas SHALL aparecer apagadas com "Substituída", e a vigente com a bolinha azul, sem a palavra "Atual". Cada cartão SHALL ter um cabeçalho com ícone e título ("Pedido de orçamento", "Proposta · versão n", "Pedido de ajuste") e a hora no rodapé. Os cartões de quem está vendo SHALL ficar à direita, e os da outra parte, à esquerda. O app SHALL montar a linha do tempo a partir da solicitação e da cadeia de versões; nada disso é gravado no chat.

#### Scenario: Negociação com ajuste

- **WHEN** houve o pedido, a versão 1, um ajuste e a versão 2
- **THEN** a conversa mostra os quatro cartões nos dias certos, entre as mensagens
- **AND** a versão 1 aparece como "Substituída" e a 2 com a bolinha azul

### Requirement: Cartão do pedido

O cartão do pedido SHALL mostrar os filhos (o responsável vê nome e idade; o motorista, primeiro nome e idade), a escola e o turno, os dias com os trechos ("quarta só ida"), o início desejado e o bairro de embarque. A rua SHALL NOT aparecer para nenhuma das partes.

#### Scenario: Embarque no cartão

- **WHEN** o embarque é na QNL 5, Taguatinga
- **THEN** o cartão mostra "Embarque em Taguatinga"

### Requirement: Faixa e ações da proposta vigente

Com uma proposta aberta, a conversa SHALL mostrar abaixo do cabeçalho a faixa "Proposta vn · <parcelas> · expira em dd/mm" com "Ver". Para o responsável, o cartão da versão vigente SHALL ter "Ver proposta" e "Aceitar", e o botão de ajuste ao lado do campo de mensagem SHALL abrir "Pedir ajuste". Para o motorista com ajuste pedido, a faixa SHALL dizer "Ajuste solicitado" com "Responder", e o cartão do ajuste SHALL ter "Nova versão". "Manter atual" SHALL NOT aparecer.

#### Scenario: O responsável aceita pelo chat

- **WHEN** o responsável toca em "Aceitar" no cartão da versão vigente
- **THEN** o aceite segue o mesmo caminho do detalhe da proposta

### Requirement: Avisos

Depois do cartão do pedido, a conversa SHALL mostrar "Endereço e nome completo disponíveis após o aceite." para o motorista. O responsável SHALL NOT ver aviso de privacidade. Depois da versão vigente, SHALL mostrar "Acordos feitos na conversa só valem se incluídos em uma nova versão da proposta.".

#### Scenario: Aviso depois da proposta

- **WHEN** a conversa tem uma versão vigente
- **THEN** o aviso sobre acordos aparece logo depois dela

### Requirement: A conversa começa pelo pedido

A conversa entre o responsável e o motorista SHALL começar pelo pedido de orçamento. O perfil do motorista SHALL NOT ter "Conversar com o motorista"; o caminho para falar com um motorista novo é "Pedir orçamento". A caixa de entrada vazia do responsável SHALL dizer que a conversa com um motorista começa quando ele pede um orçamento. "Conversar" SHALL aparecer nas telas da negociação das duas partes: para o responsável, na lista, no detalhe e na Início; para o motorista, no pedido, no ajuste e na proposta só leitura.

#### Scenario: Perfil do motorista

- **WHEN** o responsável abre o perfil de um motorista
- **THEN** o perfil mostra "Pedir orçamento" e não mostra "Conversar com o motorista"

#### Scenario: O motorista responde pelo chat

- **WHEN** o motorista toca em "Conversar" num pedido novo
- **THEN** abre a conversa com o responsável, e ele pode mandar a primeira mensagem

### Requirement: Falha ao ler a negociação

Se a negociação da conversa não carregar, a conversa SHALL mostrar no lugar da faixa da proposta "Não foi possível carregar a negociação." com "Tentar novamente", e as mensagens SHALL continuar funcionando. Uma recarga que falha SHALL manter a faixa e os cartões que já estavam na tela.

#### Scenario: A negociação falha ao abrir

- **WHEN** a leitura da negociação falha ao abrir a conversa
- **THEN** a conversa mostra as mensagens com a faixa de falha, e "Tentar novamente" lê a negociação de novo

### Requirement: Conversa sem negociação

Uma conversa sem negociação achada (as abertas antes de o pedido abrir a conversa) SHALL funcionar como hoje, sem faixa e sem cartões.

#### Scenario: Conversa antiga

- **WHEN** o responsável abre uma conversa aberta pelo perfil, antes da mudança, com um motorista para quem nunca pediu orçamento
- **THEN** a conversa mostra só as mensagens
