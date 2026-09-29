## Purpose

Garante que busca de motorista e área de atuação não tratem cidade do Google sem município IBGE correspondente como “não há motoristas” ou como sucesso vazio.

## ADDED Requirements

### Requirement: Cidade Google sem município IBGE é rejeição da sugestão

Quando um fluxo Places envia `placeId` e o back não casa o nome de cidade do Google com um município IBGE (exemplo: “Embu” vs “Embu das Artes”), a API devolve **400** com a mensagem de chave `location.city.unmatched` no `detail` (pt-BR: “Este nome de cidade não corresponde a um município brasileiro. Escolha outra sugestão.”). O back **não** manda um campo `code`: o `detail` localizado é a única marca, então o app o reconhece por marcador de texto, no mesmo molde de `districtRequiredMarker` / `tooManyAreasMarker` em área de atuação.

O app MUST mostrar um erro localizado pedindo que a pessoa escolha **outra sugestão** do autocomplete. O app MUST NOT mostrar estado vazio de “não há motoristas” / lista de áreas vazia por esse 400. Lista vazia **200** continua significando que a cidade IBGE casou e não há motorista (ou o replace de áreas passou sem itens, o que não se aplica a este 400).

Esta regra vale para `GET /api/drivers/search?placeId=` e `PUT /api/drivers/me/service-areas`. `POST /api/schools/resolve` segue o mesmo contrato no back; o client de escola oficial não faz parte desta change.

#### Scenario: Busca com cidade Google sem município IBGE

- **WHEN** a pessoa escolhe uma sugestão de Places cuja cidade não casa com o catálogo IBGE
- **AND** `GET /api/drivers/search` devolve 400 com o `detail` de cidade sem município
- **THEN** o app mostra mensagem localizada para escolher outra sugestão
- **AND** não mostra o estado vazio de busca sem motorista

#### Scenario: Área de atuação com cidade Google sem município IBGE

- **WHEN** o motorista salva uma área cujo `placeId` não casa com município IBGE
- **AND** `PUT /api/drivers/me/service-areas` devolve 400 com o `detail` de cidade sem município
- **THEN** o app mostra mensagem localizada para escolher outra sugestão
- **AND** não trata o pedido como lista vazia gravada

#### Scenario: Outros 400 não viram “outra sugestão”

- **WHEN** a busca ou a área devolve 400 com outro `detail` (bairro obrigatório, máximo de áreas, lugar não resolvido)
- **THEN** o app mantém o mapeamento que já tinha para esses casos
- **AND** não usa a copy de cidade sem município IBGE

#### Scenario: Lista vazia 200 continua sendo ausência de motorista

- **WHEN** a busca devolve 200 com lista vazia
- **THEN** o app mostra o estado vazio de “não há motoristas”
- **AND** não usa a copy de cidade sem município IBGE
