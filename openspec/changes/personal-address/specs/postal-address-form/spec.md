## Purpose

Formulário postal brasileiro compartilhado: CEP como atalho de prefill (que trava o município), município sempre do catálogo IBGE (`cityToken`), picker de UF e município como fallback, rascunho com regras de completude e o mesmo body de escrita. Usado pelo endereço residencial da conta (`personal-address`) e pelo endereço do dependente (`dependent-postal-address`). Quem consome decide **quando** e **como** grava; este contrato decide **o que** é um endereço postal válido no app e **como** o CEP e o picker interagem.

## ADDED Requirements

### Requirement: Cidade só vem de token do catálogo IBGE

O app MUST NOT deixar a pessoa digitar o nome da cidade como texto livre no save. `cityToken` MUST vir do lookup de CEP ou do picker de município.

O picker SHALL listar UFs em `GET /api/states` (página única cabe; o app MAY cachear) e municípios em `GET /api/cities?uf={UF}&search={texto}&page=&size=`. `uf` MUST ser enviado (2 letras). O app MUST NOT chamar `GET /api/cities` sem `uf`. UF inexistente (404) MUST mostrar erro localizado. Sem `uf` o back responde 400; o app não emite essa chamada. O back lista só municípios ativos.

`search` é opcional; o back faz contains no nome sem acento. Em UFs grandes o app MUST buscar depois de 2 ou 3 caracteres ou paginar. O app MUST NOT criar município. O app MUST NOT mandar `stateToken` em nenhum write de endereço — só `cityToken`.

Identidade pública da cidade é o `token` da lista (é o `cityToken`). `ibge_code` não vem na API.

No Distrito Federal o único município IBGE é Brasília. Taguatinga, Gama, Ceilândia, Asa Norte e demais RAs MUST ir em `neighborhood` (texto), não como cidade e não como `district` do Google.

Qualquer município do catálogo IBGE MUST poder ser salvo. O form MUST NOT recusar cidade com erro de “não operamos aí”.

Todas as chamadas a `/api/cep/{cep}`, `/api/states` e `/api/cities` MUST enviar `Authorization: Bearer <access_token>`. O app MUST NOT exigir permissões extras (`list_cities`, `list_states` ou equivalente); um CLIENT autenticado consulta os três.

#### Scenario: Município escolhido no picker

- **WHEN** a pessoa escolhe a UF DF e depois o município Brasília
- **THEN** o rascunho guarda o `token` desse município como `cityToken`
- **AND** o save posterior manda esse `cityToken` e não manda `stateToken`

#### Scenario: Lista de municípios sempre com UF

- **WHEN** a pessoa abre o picker de município
- **THEN** toda chamada a `/api/cities` inclui `uf`
- **AND** o app não dispara `/api/cities` sem UF

#### Scenario: Trocar a UF zera o município

- **WHEN** o picker está destravado e o rascunho tem `cityToken` de um município de SP
- **AND** a pessoa troca a UF para DF
- **THEN** `cityToken` e o nome do município saem do rascunho
- **AND** o rascunho deixa de ser completo até um município novo ser escolhido

#### Scenario: RA do DF não é município

- **WHEN** a pessoa mora em Taguatinga, DF
- **THEN** a cidade gravada é Brasília
- **AND** Taguatinga vai no bairro (`neighborhood`)

#### Scenario: Município fora da área operacional ainda salva

- **WHEN** a pessoa escolhe um município IBGE onde o produto ainda não opera e salva com rua e CEP válidos
- **THEN** o app emite o write
- **AND** não bloqueia o form com erro de cobertura

#### Scenario: Cliente consulta o catálogo sem permissão extra

- **WHEN** um CLIENT autenticado abre o picker
- **THEN** o app lista UFs e municípios sem pedir permissão além do Bearer

### Requirement: CEP preenche o form, trava a cidade e não persiste

O app SHALL oferecer um campo CEP com máscara `00000-000`. Quando houver 8 dígitos, o app MUST consultar `GET /api/cep/{cep}` com o path só de dígitos (`70040-010` no path é 400). A consulta MUST ser debounceada (400 ms depois do 8º dígito). O lookup MUST NOT gravar nada.

**HTTP 200.** Preenche `cityToken`, `cityName` e `uf`, e **substitui** `street` e `neighborhood` pelo que veio (nulo vira vazio; não mescla com o que já estava no rascunho). UF e município MUST ficar **travados**: o município do ViaCEP é 1:1 com o `cityToken`, então a pessoa MUST NOT trocá-los pelo picker enquanto o 200 valer. Como ficam travados, o formulário MUST mostrá-los num **card só de leitura** logo abaixo do CEP, não como campos desabilitados (ver “O formulário postal é um só componente em core”). Se o 200 trouxe `neighborhood`, o bairro MUST ficar travado e aparecer dentro do card; se veio sem bairro, o campo MUST permanecer aberto. CEP, rua, número e complemento permanecem editáveis. Número e complemento MUST NOT ser preenchidos nem apagados pelo lookup. Cidade MUST NOT virar texto livre. Se a pessoa mudar o CEP (8 dígitos de novo), o app MUST consultar de novo e substituir cidade, UF, rua e bairro; o travamento do bairro segue o lookup novo.

**404 (município fora do catálogo ou sem `ibge_code`), 429 e 503.** O app MUST mostrar uma mensagem localizada distinta e MUST **destravar** o picker (`GET /api/states` e `GET /api/cities?uf=`). O CEP digitado MUST permanecer (o write exige 8 dígitos). Rua, bairro, UF e município do lookup anterior MUST ser limpos e o bairro MUST ficar aberto. Número e complemento permanecem. Isso é o fallback manual, não um modo especial.

**404 “CEP não existe” (`CepFailure.notFound`).** Além do que vale para os outros 404, o app MUST **bloquear o Salvar** do endereço até a pessoa trocar o CEP. Escolher UF, município ou rua na mão MUST NOT habilitar o write nem apagar essa falha. Os outros 404, o 429 e o 503 continuam graváveis pelo fallback manual.

O picker só existe no **fallback manual**, isto é, depois de uma falha de serviço do lookup (404 de município fora do catálogo, 429, 503, rede ou erro inesperado). Antes de haver um CEP de 8 dígitos consultado, o formulário não mostra UF, município nem bairro: a cidade só vem do lookup, e o write exige o CEP. Depois de um 200, UF e município ficam travados até a pessoa editar o CEP para menos de 8 dígitos (o formulário volta a mostrar só o CEP, sem apagar o que já estava) ou até outro lookup.

Enquanto o lookup está pendente, do 8º dígito até a resposta (debounce incluído), o campo CEP MUST mostrar um indicador de carregando e o formulário MUST NOT mostrar a localização (o card ou UF e município), mesmo que o rascunho já tivesse cidade de um CEP anterior. O campo CEP continua editável, e rua, número e complemento continuam visíveis. O lookup MUST continuar **substituindo** a rua e o bairro pelo que veio: o que a pessoa digitou na rua antes do CEP resolver é sobrescrito.

O app MUST NOT chamar `viacep.com.br` nem qualquer lookup de CEP fora desta API. Sem o back não existe `cityToken`.

| Status | Tratamento |
|---|---|
| 400 | CEP em formato inválido; não consulta de novo sem 8 dígitos |
| 404 | CEP desconhecido (ViaCEP: esse CEP não existe); destrava o picker; mensagem de CEP não encontrado; MUST NOT gravar até trocar o CEP |
| 404 | município do CEP fora do catálogo; destrava o picker; mensagem de cidade fora do catálogo; grava pelo fallback |
| 429 | rate limit por usuário (20/60 s); destrava o picker; mensagem para esperar; grava pelo fallback |
| 503 | ViaCEP fora / timeout; destrava o picker; mensagem para tentar de novo ou preencher na mão; grava pelo fallback |

O back não manda `code` nesses erros, só `detail` localizado; os dois 404 se distinguem pelo `detail` (marcador de “catálogo”, que também casa a mensagem em inglês, “catalog”), no mesmo molde dos marcadores que o app já usa em área de atuação.

#### Scenario: CEP encontrado preenche o form e trava UF e município

- **WHEN** a pessoa digita um CEP de 8 dígitos e o GET devolve 200
- **THEN** cidade, UF, `cityToken`, rua e bairro (quando vierem) entram no form
- **AND** o município e a UF aparecem no card do CEP, sem campo editável
- **AND** o bairro fica travado, dentro do card, quando o lookup trouxe `neighborhood`
- **AND** o app ainda não emite write
- **AND** a pessoa pode editar rua, número, complemento e CEP antes de salvar

#### Scenario: CEP genérico sem rua nem bairro

- **WHEN** o GET de CEP devolve 200 com `street` e `neighborhood` nulos
- **THEN** cidade e `cityToken` entram no form e o card mostra só município e UF
- **AND** rua e bairro são substituídos por vazio para a pessoa preencher
- **AND** o bairro aparece como campo editável
- **AND** número e complemento que a pessoa já tinha digitado permanecem

#### Scenario: Trocar o CEP substitui cidade e logradouro

- **WHEN** a pessoa já tinha um CEP com 200 e digita outro CEP de 8 dígitos que também devolve 200
- **THEN** cidade, UF, `cityToken`, rua e bairro passam a ser os do lookup novo
- **AND** o app não mantém rua nem bairro do CEP anterior
- **AND** o bairro fica travado só se o lookup novo trouxe `neighborhood`

#### Scenario: Editar o CEP esconde o resultado anterior

- **WHEN** a pessoa tem UF e município travados por um CEP com 200, ou por uma casa gravada
- **AND** apaga um dígito do CEP
- **THEN** o card some e o formulário deixa de mostrar a localização
- **AND** cidade, rua e bairro que já estavam continuam no rascunho
- **AND** ao completar 8 dígitos o app consulta de novo e mostra o card outra vez se o lookup devolver 200

#### Scenario: CEP com hífen não vai no path

- **WHEN** o campo mostra `70040-010`
- **THEN** o path da consulta é `/api/cep/70040010`

#### Scenario: CEP incompleto não consulta

- **WHEN** o campo tem 7 dígitos
- **THEN** o app não chama `/api/cep`

#### Scenario: Falha do lookup abre o fallback manual

- **WHEN** o GET de CEP devolve 404 (município fora do catálogo), 429 ou 503
- **THEN** o app mostra um erro localizado distinto para cidade fora do catálogo, limite ou indisponível
- **AND** o formulário passa ao fallback manual: UF e município escolhíveis, e o picker abre
- **AND** o CEP digitado permanece no form
- **AND** rua, bairro, UF e município do lookup anterior saem e o bairro fica aberto
- **AND** número e complemento permanecem
- **AND** o Salvar continua possível assim que o rascunho estiver completo

#### Scenario: CEP inexistente bloqueia o Salvar

- **WHEN** o GET de CEP devolve 404 porque o ViaCEP disse que o CEP não existe
- **THEN** o app mostra o erro de CEP não encontrado
- **AND** o Salvar permanece bloqueado mesmo com `cityToken`, rua e CEP de 8 dígitos
- **AND** o formulário não mostra localização (card, UF, município nem bairro)
- **AND** o app não emite write

#### Scenario: App nunca consulta ViaCEP direto

- **WHEN** a pessoa preenche ou salva um endereço postal
- **THEN** nenhuma requisição sai para `viacep.com.br`

### Requirement: Rascunho postal tem um dono e regras de completude

O app SHALL representar o endereço em edição por um único valor de domínio compartilhado, `PostalAddressDraft`, em `lib/core/domain/`. Contém CEP (só dígitos), `cityToken`, nome do município e UF (só para exibição — a identidade é o token), rua, bairro, número e complemento, mais o que o último lookup de CEP decidiu: cidade travada, bairro travado e CEP inexistente. O texto é guardado como a pessoa digitou; só o CEP é normalizado ao guardar (só dígitos, até 8). A comparação de conteúdo — que decide se o endereço está sujo — normaliza: opcionais em branco e ausentes são iguais, o CEP compara só dígitos e o texto é aparado.

O rascunho é **completo** quando tem `cityToken`, rua não vazia e CEP com exatamente 8 dígitos. Está **gravável** quando é completo e o CEP não foi dado como inexistente. Número, complemento e bairro sozinhos MUST NOT tornar um rascunho completo. O rascunho é **em branco** quando todos os campos de endereço estão vazios. Limites do cliente, espelho do Bean Validation do back: rua 255, número 16, complemento 128, bairro 128.

Rascunho não completo expõe o que falta (`cityRequired`, `streetRequired`, `zipCodeInvalid`) para o consumidor mostrar erro por campo; o app MUST NOT depender de erro por campo vindo do back (ver abaixo).

O write postal MUST ter `cityToken`, `street` e `zipCode` (8 dígitos, sem hífen) e MUST enviar `number`, `complement` e `neighborhood` sempre presentes: o valor do rascunho ou JSON `null` se em branco. O write MUST NOT incluir `placeId`, `sessionToken`, `stateToken`, `cityName` nem `uf`. O back ignora extras; o app não os manda.

O back não devolve erro por campo em 400 de Bean Validation (é o ProblemDetail padrão, com `detail` genérico). O app MUST tratar esse 400 como falha de validação genérica e localizada, e MUST NOT renderizar o `detail` do back na tela.

#### Scenario: Rascunho completo

- **WHEN** o rascunho tem `cityToken`, rua e CEP de 8 dígitos
- **THEN** ele é completo
- **AND** número, complemento e bairro são opcionais

#### Scenario: Só opcionais não completam

- **WHEN** o rascunho tem número, complemento e bairro mas não tem `cityToken`, rua nem CEP
- **THEN** ele não é completo

#### Scenario: Completo mas com CEP inexistente não é gravável

- **WHEN** o rascunho é completo e o último lookup deu 404 de CEP inexistente
- **THEN** ele não é gravável até o CEP mudar

#### Scenario: Hífen do CEP não vai no write

- **WHEN** o campo CEP mostra `70040-010`
- **THEN** o `zipCode` do write é `70040010`

#### Scenario: Opcional em branco vai como null

- **WHEN** o rascunho não tem complemento
- **THEN** o write envia `"complement": null`
- **AND** o write nunca omite a chave de um opcional

#### Scenario: Rascunho incompleto mostra o que falta

- **WHEN** o rascunho tem rua mas não tem CEP de 8 dígitos nem `cityToken`
- **THEN** as pendências são `zipCodeInvalid` e `cityRequired`

#### Scenario: 400 do back não vaza para a tela

- **WHEN** um write postal devolve 400 de validação
- **THEN** o app mostra a mensagem localizada genérica de validação
- **AND** não mostra o `detail` que veio do back

### Requirement: O formulário postal é um só componente em core

O app SHALL montar o endereço postal com um único formulário apresentacional em `lib/core/ui/` (`VanepPostalAddressForm`) e um único sheet de escolha de UF e município (`VanepCityPickerSheet`), usados pela tela de endereço da conta e pelo formulário de dependente. Nenhum dos dois módulos MUST reimplementar esses campos.

O formulário MUST mostrar os campos por **modo**, decidido pelo rascunho e por um indicador de lookup pendente que o consumidor passa:

| Modo | Quando | O que aparece |
|---|---|---|
| Aguardando o CEP | CEP com menos de 8 dígitos, ou lookup pendente | CEP (com indicador de carregando se pendente), rua, número e complemento |
| CEP inexistente | `isZipCodeUnknown` | CEP com a mensagem de erro, rua, número e complemento; o Salvar fica bloqueado |
| Resolvido | cidade travada pelo lookup, ou casa gravada | CEP, **card do CEP**, bairro (só se o CEP não o trouxe, ou se a casa gravada não tem bairro), rua, número e complemento |
| Manual | CEP de 8 dígitos, lookup terminado e cidade não travada (falha de serviço) | CEP, UF e município, bairro, rua, número e complemento |

O **card do CEP** (`VanepCepAddressCard`) é só de leitura: um ícone de endereço e uma única linha de texto, “Bairro, Município – UF” (o bairro só quando o CEP o trouxe; sem ele, “Município – UF”). Não tem título, campo nem toque, e não usa o nome do ViaCEP (quem consulta é o back). Linha longa quebra em vez de estourar.

Ordem dos campos: CEP, depois a localização (o card, ou UF e município lado a lado no modo manual), depois bairro, rua e número e complemento (lado a lado). Na mesma linha do modo manual, a UF é uma lista suspensa (as UFs de `GET /api/states`) e o município é um campo somente leitura que abre um sheet de busca de municípios da UF escolhida (não é campo de texto). Os campos obrigatórios (CEP, rua e, no modo manual, UF e município) são marcados como obrigatórios no rótulo. Quando a UF não é selecionável (formulário desabilitado), o valor aparece como texto na cor do design system, nunca como `DropdownButton` desabilitado: o Flutter pinta esse valor com o `disabledColor` do tema escuro do app, branco a 38%, invisível sobre o campo branco. Copy só em ARB. O formulário não conhece cubit nem módulo: recebe valores e callbacks; o estado do rascunho, do lookup e do picker é do cubit do consumidor (R06a). Onde o formulário mora é do consumidor: a conta o hospeda numa tela própria de endereço; o dependente o hospeda inline no formulário de dependente.

O formulário MUST NOT conter autocomplete do Google Places.

#### Scenario: Mesmos campos nos dois lugares

- **WHEN** a pessoa abre o endereço em dados pessoais e depois o endereço do dependente
- **THEN** os dois mostram os mesmos campos, na mesma ordem e com a mesma copy

#### Scenario: Município escolhido por sheet

- **WHEN** a pessoa escolhe a UF e toca o campo de município com o picker destravado
- **THEN** abre o sheet de busca de municípios da UF escolhida
- **AND** ao escolher um município o sheet fecha e o seletor mostra o nome e a UF

#### Scenario: Antes do lookup só falta a localização

- **WHEN** o formulário abre sem CEP, ou o CEP tem menos de 8 dígitos
- **THEN** aparecem o CEP, a rua, o número e o complemento, todos editáveis
- **AND** não há card, UF, município nem bairro

#### Scenario: Casa gravada com bairro abre com o bairro travado

- **WHEN** a pessoa abre para editar uma casa gravada que tem bairro
- **THEN** o card mostra “Bairro, Município – UF”
- **AND** não há campo de bairro para editar

#### Scenario: Casa gravada sem bairro deixa o campo aberto

- **WHEN** a pessoa abre para editar uma casa gravada sem bairro
- **THEN** o card mostra só “Município – UF”
- **AND** o campo de bairro aparece editável

#### Scenario: Mudar o CEP de uma casa gravada segue o lookup novo

- **WHEN** a pessoa edita o CEP de uma casa gravada e o lookup devolve 200 sem bairro
- **THEN** o bairro antigo sai e o campo de bairro aparece editável

#### Scenario: O lookup sobrescreve a rua digitada antes

- **WHEN** a pessoa digita uma rua antes de o CEP resolver
- **AND** o lookup devolve 200 com outra rua
- **THEN** a rua do lookup substitui a digitada

#### Scenario: Indicador de carregando enquanto consulta

- **WHEN** o 8º dígito é digitado
- **THEN** o campo CEP mostra um indicador de carregando até a resposta do lookup
- **AND** o formulário não mostra o card nem UF e município, mesmo com a cidade de um CEP anterior no rascunho
- **AND** rua, número e complemento continuam visíveis
- **AND** o campo CEP continua editável

#### Scenario: CEP resolvido mostra o card

- **WHEN** o último lookup de CEP devolveu 200
- **THEN** o card do CEP mostra “Município – UF”, precedido de “Bairro, ” se o CEP o trouxe, numa linha só e com ícone de endereço
- **AND** não há campo de UF nem de município para editar
- **AND** rua, número e complemento ficam abaixo, editáveis
- **AND** o bairro aparece como campo editável só quando o CEP não o trouxe

#### Scenario: CEP inexistente não mostra localização

- **WHEN** o lookup devolveu 404 porque o CEP não existe
- **THEN** o campo CEP mostra a mensagem de erro
- **AND** não há card, UF, município nem bairro
- **AND** o Salvar continua bloqueado

#### Scenario: Falha de serviço mostra o fallback manual

- **WHEN** o lookup falhou por 429, 503, rede, erro inesperado ou município fora do catálogo
- **THEN** o formulário mostra UF e município escolhíveis, bairro, rua, número e complemento

#### Scenario: UF travada legível

- **WHEN** o formulário está desabilitado (por exemplo, salvando) e a UF tem valor
- **THEN** a UF aparece como texto na cor do design system
- **AND** não usa a cor de desabilitado do tema

#### Scenario: Sem Places

- **WHEN** o formulário postal é renderizado
- **THEN** não há campo de autocomplete do Places
