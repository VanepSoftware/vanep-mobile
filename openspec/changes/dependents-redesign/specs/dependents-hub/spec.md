## Purpose

A lista de dependentes e o detalhe de cada dependente no app do cliente: o lugar onde o responsável vê todos os dependentes e o que falta em cada um, e de onde chega a um editor por assunto.

## ADDED Requirements

### Requirement: Lista de dependentes

A aba Dependentes SHALL abrir a lista de dependentes, carregada de `GET /api/dependent`. O cabeçalho SHALL mostrar o título "Dependentes", o subtítulo "Gerencie quem viaja na van" e o botão de adicionar. Cada dependente SHALL ser uma linha que mostra, nesta ordem:

- um avatar com a primeira letra do nome;
- o primeiro nome, seguido de `· Padrão` quando é o dependente padrão;
- embaixo do nome, uma de duas coisas:
  - a linha âmbar "Cadastro incompleto", quando a capability `dependent-readiness` informa que o dependente não está pronto. Nesse caso a linha SHALL NOT mostrar idade nem escola;
  - nos outros casos, um subtítulo com a idade em anos (só quando o nascimento é conhecido) e o nome da escola (só quando há escola), unidos por ` · `.

As linhas SHALL manter a ordem do back. Tocar numa linha SHALL abrir o detalhe daquele dependente. O botão de adicionar do cabeçalho e o botão "Adicionar dependente" embaixo da lista SHALL abrir o wizard de criação (`dependent-creation-wizard`).

#### Scenario: Linha com idade e escola

- **WHEN** a lista mostra um dependente "Pedro Oliveira", nascido há 11 anos, na escola "Colégio Delta"
- **THEN** a linha mostra "Pedro" e o subtítulo "11 anos · Colégio Delta"

#### Scenario: Dependente padrão

- **WHEN** a lista mostra a dependente padrão "Ana"
- **THEN** o título da linha é "Ana · Padrão"

#### Scenario: Dependente sem escola

- **WHEN** um dependente nascido há 4 anos não tem escola
- **THEN** o subtítulo mostra só "4 anos"

#### Scenario: Dependente incompleto

- **WHEN** a prontidão informa pelo menos um item faltando para um dependente
- **THEN** a linha dele mostra só o nome e, embaixo, a linha âmbar "Cadastro incompleto"
- **AND** a linha não mostra a idade nem a escola

#### Scenario: Adicionar pela lista

- **WHEN** o responsável toca no botão de adicionar do cabeçalho ou em "Adicionar dependente"
- **THEN** o wizard de criação abre no primeiro passo

### Requirement: Estados de carregamento, vazio e falha da lista

Enquanto a primeira carga está em andamento, a lista SHALL mostrar linhas em skeleton. Quando o cliente não tem dependentes, a lista SHALL mostrar um estado vazio que explica o que é um dependente, com o botão "Adicionar dependente". Quando a carga falha, a lista SHALL mostrar uma tela de erro com a ação de tentar de novo. Uma falha na consulta de prontidão SHALL NOT transformar a lista num erro: as linhas aparecem sem a linha "Cadastro incompleto".

#### Scenario: Ainda sem dependentes

- **WHEN** `GET /api/dependent` devolve uma lista vazia
- **THEN** aparecem o estado vazio e o botão "Adicionar dependente"

#### Scenario: Falha ao carregar a lista

- **WHEN** `GET /api/dependent` falha
- **THEN** aparece uma tela de erro com "Tentar novamente"
- **AND** tocar nela repete a requisição

#### Scenario: Falha na prontidão

- **WHEN** os dependentes carregam mas a consulta de prontidão falha
- **THEN** todas as linhas aparecem sem a linha "Cadastro incompleto"

### Requirement: Detalhe do dependente

O detalhe SHALL ter um cabeçalho com o botão de voltar, o primeiro nome do dependente com a legenda "Dependente", e um menu ⋮ quando ele tem alguma opção (hoje, só "Definir como padrão"). O corpo SHALL mostrar, nesta ordem:

1. um card de cabeçalho com o avatar, o nome completo e a idade (com "dependente padrão" no fim quando é o padrão);
2. o card "Cadastro incompleto" definido em `dependent-readiness`, só quando o dependente não está pronto;
3. o grupo **Escola e rotina** com as linhas Escola, Dias e turnos e Embarque;
4. o grupo **Van e contrato** com as linhas Van e Contrato;
5. o grupo **Cadastro** com a linha Dados pessoais;
6. o botão "Remover dependente".

Quando o dependente tem escola, a linha Escola SHALL mostrar o nome da escola embaixo do título, sem o endereço, que fica só no editor de Escola. Quando o dependente tem endereço, a linha Embarque SHALL mostrar embaixo do título um resumo com a rua com o número e o bairro, unidos por ` · `, sem complemento, cidade nem CEP. O nome da escola e o resumo do embarque SHALL ocupar uma linha só, cortados com reticências quando não cabem. A linha Dados pessoais SHALL mostrar só o título quando o dado existe. Quando o dado falta, SHALL mostrar o subtítulo âmbar "Não informado": Escola quando não há escola, Embarque quando não há endereço, Dados pessoais quando não há data de nascimento. A linha Dias e turnos SHALL mostrar a barra da semana definida abaixo, embaixo do título, quando a grade tem pelo menos um dia, e "Não informado" quando está vazia.

Tocar em Escola, Dias e turnos, Embarque ou Dados pessoais SHALL abrir o editor correspondente. Quando um editor salva, o detalhe SHALL mostrar o dado atualizado, e a lista SHALL estar atualizada quando o responsável voltar para ela.

#### Scenario: Dependente completo

- **WHEN** o detalhe abre para um dependente com nascimento, escola, endereço e grade preenchida
- **THEN** a linha Dados pessoais não mostra subtítulo
- **AND** a linha Escola mostra o nome da escola
- **AND** a linha Embarque mostra o endereço resumido
- **AND** Dias e turnos mostra o título com a barra da semana

#### Scenario: Embarque resumido

- **WHEN** o endereço do dependente é "QNL 5 Conjunto A", número 12, complemento "Casa", bairro "Taguatinga", em Brasília/DF
- **THEN** a linha Embarque mostra "QNL 5 Conjunto A, 12 · Taguatinga"

#### Scenario: Sem escola e sem grade

- **WHEN** o detalhe abre para um dependente sem escola e com a grade vazia
- **THEN** Escola e Dias e turnos mostram "Não informado" em âmbar

#### Scenario: O detalhe reflete uma edição

- **WHEN** o responsável salva uma escola nova no editor de Escola e volta
- **THEN** o detalhe não mostra mais "Não informado" em Escola e mostra o nome da escola nova
- **AND** a linha da lista mostra o nome da escola nova

### Requirement: Barra da semana no detalhe

Embaixo do título "Dias e turnos", a linha SHALL mostrar uma barra de sete segmentos iguais, começando na segunda, cada um com a inicial do dia embaixo (S, T, Q, Q, S, S, D). A linha SHALL NOT mostrar um resumo da semana em texto. Um dia sem aula SHALL ficar neutro. Um dia com `MORNING`, `AFTERNOON` ou `NIGHT` SHALL usar a cor de meio período. Um dia `FULLTIME` SHALL usar a cor de integral, que é mais escura que a de meio período, para as duas se diferenciarem pela claridade e não só pelo tom.

A barra SHALL ficar escondida do leitor de tela. A linha SHALL ser anunciada como "Dias e turnos" seguido do número de dias com aula ("5 dias", "1 dia").

Enquanto a grade carrega, a barra SHALL aparecer em skeleton. Se a grade não carregar, a linha SHALL mostrar uma ação de tentar de novo no lugar da barra. Tocar nela SHALL carregar a grade de novo.

#### Scenario: Dias úteis com um dia integral

- **WHEN** a grade é de segunda a sexta `MORNING`, menos quinta `FULLTIME`
- **THEN** a barra tem segmentos de meio período na segunda, terça, quarta e sexta, um segmento de integral na quinta, e segmentos neutros no sábado e no domingo
- **AND** nenhum resumo em texto aparece embaixo do título

#### Scenario: Leitor de tela

- **WHEN** um leitor de tela foca a linha de uma grade de cinco dias
- **THEN** ele anuncia "Dias e turnos, 5 dias"

#### Scenario: Falha ao carregar a grade

- **WHEN** `GET /api/dependent/{token}/school-days` falha no detalhe
- **THEN** a linha mostra a ação de tentar de novo no lugar da barra

### Requirement: Dependente padrão pelo detalhe

Quando o cliente tem dois ou mais dependentes e o dependente aberto não é o padrão, o menu ⋮ SHALL oferecer "Definir como padrão". Escolher essa opção SHALL enviar `PATCH /api/dependent/{token}` com `isDefault: true`. Com sucesso, o detalhe e a lista SHALL mostrar o novo padrão, e o padrão anterior SHALL deixar de mostrar `· Padrão`. Quando o cliente tem um dependente só, ou o dependente aberto já é o padrão, a opção SHALL NOT aparecer e, sem nenhuma opção, o cabeçalho SHALL NOT mostrar o menu ⋮.

#### Scenario: Escolher um novo padrão

- **WHEN** o responsável escolhe "Definir como padrão" no "Pedro" enquanto a "Ana" é a padrão
- **THEN** o app envia `isDefault: true` para o Pedro
- **AND** a lista mostra "Pedro · Padrão" e "Ana" sem o marcador

#### Scenario: Um dependente só

- **WHEN** o cliente tem um único dependente
- **THEN** o cabeçalho do detalhe não mostra o menu ⋮

#### Scenario: Dependente que já é o padrão

- **WHEN** o detalhe abre para o dependente padrão
- **THEN** o cabeçalho do detalhe não mostra o menu ⋮

### Requirement: Remover dependente

"Remover dependente" SHALL pedir confirmação num diálogo destrutivo que cita o nome do dependente. Com a confirmação, o app SHALL enviar `DELETE /api/dependent/{token}`. Com sucesso, SHALL voltar para a lista, que não mostra mais o dependente e mostra o padrão que o back promoveu, e SHALL mostrar uma mensagem de sucesso. Com falha, SHALL ficar no detalhe e mostrar a mensagem do back quando ela existir, ou uma genérica. Cancelar o diálogo SHALL NOT mudar nada.

#### Scenario: Remoção confirmada

- **WHEN** o responsável confirma a remoção do "Davi"
- **THEN** o app envia `DELETE /api/dependent/{token}` para o Davi
- **AND** a lista abre sem o Davi e mostra uma mensagem de sucesso

#### Scenario: A remoção falha

- **WHEN** a requisição `DELETE` falha
- **THEN** o detalhe continua aberto e aparece uma mensagem de erro

#### Scenario: Dependente com pedido de orçamento aberto

- **WHEN** o back responde HTTP 422 porque o dependente está num pedido de orçamento aberto
- **THEN** o detalhe continua aberto
- **AND** a mensagem mostrada é a que o back mandou

### Requirement: Linhas Van e Contrato sem destino

As linhas Van e Contrato SHALL aparecer no grupo Van e contrato com ícone e título, sem subtítulo. Tocar nelas SHALL NOT navegar nem mostrar mensagem, até as telas de van e de contrato do cliente existirem.

#### Scenario: Tocar numa linha sem destino

- **WHEN** o responsável toca em Van ou Contrato
- **THEN** o detalhe continua na tela e nada mais acontece
