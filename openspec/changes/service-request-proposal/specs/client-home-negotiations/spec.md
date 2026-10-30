## Purpose

Faz os itens de negociação da Início do responsável (proposta nova, pedido expirado e o card de negociações em andamento) virem da API, mantendo mock só o que o back ainda não tem.

## ADDED Requirements

### Requirement: Proposta nova em "Precisa de você"

Cada negociação em que o responsável precisa responder a uma proposta SHALL virar um item "Proposta nova" com o motorista, os filhos, os trechos ("ida e volta", "só ida", "só volta" ou "ida e volta em alguns dias"), o valor em parcelas e "Expira em n dias" pela validade. Tocar no item SHALL abrir o detalhe da proposta, e "Conversar" SHALL abrir a conversa com o motorista. Uma proposta com ajuste pedido SHALL NOT virar item.

#### Scenario: Proposta para os dois irmãos

- **WHEN** Carlos mandou 12x de R$ 650 para Ana e Pedro, ida e volta, válida por mais 6 dias
- **THEN** o item mostra "Carlos Souza", "Ana e Pedro · ida e volta", "12x de R$ 650" e "Expira em 6 dias"

### Requirement: Pedido expirado

Cada pedido `EXPIRED` atualizado nos últimos 7 dias SHALL virar o item "Pedido para <motorista> expirou", com a ação "Buscar vans", que abre a busca. Depois de 7 dias, o item SHALL sumir.

#### Scenario: Expirou há 8 dias

- **WHEN** um pedido expirou há 8 dias
- **THEN** ele não aparece em "Precisa de você"

### Requirement: Card de negociações sem van

Quando o responsável não tem van e tem negociações abertas, o card SHALL mostrar os nomes dos filhos que estão nessas negociações, "n negociações em andamento", "Ver propostas" (abre a lista) e "Buscar vans".

#### Scenario: Três negociações para dois filhos

- **WHEN** Ana e Pedro estão em três negociações abertas
- **THEN** o card mostra "Ana e Pedro ainda sem van" e "3 negociações em andamento"

### Requirement: Falha ao ler as negociações

Se a leitura das negociações falhar, a Início SHALL aparecer sem os itens de negociação e sem mensagem de erro. O resto da tela SHALL seguir o comportamento que já existe.

#### Scenario: API das negociações fora do ar

- **WHEN** a lista de negociações falha e o resto da Início carrega
- **THEN** a Início aparece sem "Proposta nova", sem "Pedido expirou" e sem o card de negociações

### Requirement: O que continua mock

Os itens de contrato para assinar, mensalidade, renovação, vistoria, avaliação e a rota do dia SHALL continuar vindo do cenário de exemplo (`CLIENT_HOME_SCENARIO`) e SHALL NOT vir mais do cenário os itens de proposta nova e pedido expirado, nem a contagem de negociações.

#### Scenario: Cenário "negotiating" ligado

- **WHEN** `CLIENT_HOME_SCENARIO=negotiating` e o responsável não tem negociações na API
- **THEN** a Início não mostra "Proposta nova" nem "Pedido expirou"
