## Purpose

Permite ao responsável definir a escola em que o dependente estuda, buscando escolas reais e salvando a escola da Vanep que o back resolve a partir do lugar escolhido.

## ADDED Requirements

### Requirement: Busca de escola

O editor de Escola SHALL ter um cabeçalho com o botão de voltar, o título "Escola" e o primeiro nome do dependente como legenda. SHALL mostrar um campo de busca, o mapa estático (definido em `dependent-pickup`) e uma lista de resultados. Digitar no campo SHALL buscar no autocomplete do Google Places limitado ao Brasil e a lugares do tipo escola, com o debounce e o tamanho mínimo que o app já usa. Cada resultado SHALL mostrar o texto principal do lugar como título e o texto secundário como legenda. A lista de resultados SHALL ser substituída a cada nova busca.

Quando o dependente já tem escola, o editor SHALL abrir com essa escola marcada como selecionada antes de qualquer busca, e o rótulo do mapa SHALL mostrar o nome dela. Quando a escola tem endereço, o item SHALL mostrar embaixo do nome a rua com o número, o bairro e a cidade/UF, unidos por ` · `. Sem endereço, o item SHALL mostrar só o nome.

#### Scenario: Buscar uma escola

- **WHEN** o responsável digita "Escola Classe"
- **THEN** a lista mostra sugestões de escolas com o nome e a região

#### Scenario: Abrir com escola já definida

- **WHEN** o editor abre para um dependente cuja escola é "Colégio Horizonte"
- **THEN** "Colégio Horizonte" aparece como o item selecionado

#### Scenario: Escola já definida com endereço

- **WHEN** a escola do dependente tem o endereço "SGAS 605, 1", bairro "Asa Sul", em Brasília/DF
- **THEN** o item selecionado mostra "SGAS 605, 1 · Asa Sul · Brasília/DF" embaixo do nome

#### Scenario: Places indisponível

- **WHEN** a requisição de autocomplete falha
- **THEN** o editor mostra uma mensagem na própria tela dizendo que a busca está indisponível
- **AND** o campo continua editável para o responsável tentar de novo

### Requirement: Selecionar e salvar a escola

Tocar num resultado SHALL marcá-lo como selecionado (check preenchido) e desmarcar qualquer outro. O rótulo do mapa SHALL mostrar o nome selecionado. "Salvar" SHALL ficar habilitado só quando a escola selecionada é diferente da escola atual do dependente.

Ao tocar em "Salvar", o app SHALL enviar `POST /api/schools/resolve` com o place id e o token da sessão atual do Places. Em seguida, SHALL enviar `PATCH /api/dependent/{token}` com o `token` da escola devolvida como `schoolToken`. Com sucesso, SHALL fechar o editor e devolver o dependente atualizado para quem abriu. Enquanto salva, o botão SHALL mostrar progresso e o editor SHALL NOT aceitar outro salvamento.

#### Scenario: Salvar uma escola nova

- **WHEN** o responsável seleciona "Escola Classe 10" e toca em "Salvar"
- **THEN** o app resolve o lugar, envia o token devolvido como `schoolToken` e volta para o detalhe
- **AND** a escola do dependente passa a ser "Escola Classe 10"

#### Scenario: Mesma escola selecionada

- **WHEN** o item selecionado é a escola atual do dependente
- **THEN** "Salvar" fica desabilitado

#### Scenario: O lugar não é uma escola

- **WHEN** `POST /api/schools/resolve` recusa o lugar com HTTP 4xx
- **THEN** o editor continua aberto e mostra a mensagem do back, ou uma genérica quando não há
- **AND** o dependente não muda

#### Scenario: A atualização falha depois do resolve

- **WHEN** o resolve dá certo mas `PATCH /api/dependent/{token}` falha
- **THEN** o editor continua aberto com a seleção mantida e mostra uma mensagem de erro
