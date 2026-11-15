## Purpose

Permite ao responsável definir onde o dependente embarca na van (Embarque) pelo formulário postal compartilhado, embaixo de um mapa estático que ocupa o lugar de um mapa de verdade até o back guardar coordenadas.

## ADDED Requirements

### Requirement: Editor de embarque

O editor de Embarque SHALL ter um cabeçalho com o botão de voltar, o título "Embarque" e o primeiro nome do dependente como legenda. SHALL mostrar o mapa estático e, embaixo, o formulário postal compartilhado com CEP, Endereço, Número, Complemento (opcional), Bairro e a cidade. A busca de CEP, a validação, a resolução da cidade e o body da requisição do formulário SHALL seguir a capability `dependent-postal-address` da change `personal-address`, sem mudanças. "Salvar" SHALL enviar `PATCH /api/dependent/{token}` só com `address`. Com sucesso, o editor SHALL devolver o dependente atualizado para quem abriu. Com falha, SHALL continuar aberto com o que foi digitado e mostrar uma mensagem de erro.

#### Scenario: Salvar um endereço novo

- **WHEN** o responsável preenche o CEP 72155-506 e o número 12 e salva
- **THEN** o app envia `PATCH /api/dependent/{token}` com um body que tem só `address`
- **AND** o detalhe não mostra mais "Não informado" em Embarque

#### Scenario: Abrir com endereço

- **WHEN** o editor abre para um dependente que tem endereço
- **THEN** todos os campos vêm preenchidos com ele

### Requirement: Mapa estático

Os editores de Escola e de Embarque SHALL mostrar um mapa decorativo: uma ilustração fixa de ruas, com 168 pixels lógicos de altura e um pino no centro (ícone de escola na Escola, pino de localização no Embarque). Na Escola, um rótulo embaixo SHALL mostrar o nome da escola selecionada, ou nada quando nenhuma está selecionada. No Embarque, SHALL aparecer um chip "Ajustar no mapa".

O mapa SHALL NOT representar a posição real do endereço ou da escola. SHALL NOT reagir a gestos. O chip SHALL NOT fazer nada ao ser tocado. O leitor de tela SHALL anunciá-lo como uma imagem descrita como mapa ilustrativo.

#### Scenario: Tocar em "Ajustar no mapa"

- **WHEN** o responsável toca em "Ajustar no mapa"
- **THEN** nada acontece e o formulário mantém os valores

#### Scenario: O rótulo da escola acompanha a seleção

- **WHEN** o responsável seleciona "Escola Classe 08" no editor de Escola
- **THEN** o rótulo do mapa mostra "Escola Classe 08"
