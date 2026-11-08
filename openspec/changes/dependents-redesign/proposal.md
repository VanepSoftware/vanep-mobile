## Why

Hoje a área de dependentes é uma lista de cartões e um formulário único e comprido (nome, nascimento, gênero, endereço). Ela não comporta o que um contrato vai precisar. A change do back `service-request-proposal` (vanep-api-java, PR 3) adiciona uma grade escolar semanal por dependente e uma checagem de prontidão contratual (nascimento, escola, endereço, grade escolar). O dependente também já aceita `schoolToken` e `document`. O app não tem tela para nada disso, então nenhum dependente cadastrado pelo app consegue ficar pronto para um pedido de orçamento.

O redesenho no canvas "Vanep — Início, Vans e Propostas" (página Responsável → Dependentes, artboards 1–9) troca o formulário único por um detalhe central e um editor por assunto. Esta change reconstrói o módulo em volta dele.

## What Changes

- **Lista nova (artboard 1).** Cabeçalho "Dependentes" com o subtítulo "Gerencie quem viaja na van". Uma linha por dependente com a inicial no avatar, o nome, `· Padrão` no dependente padrão e um subtítulo com a idade e o nome da escola. Um dependente que não está pronto para contrato mostra só o nome e uma linha âmbar "Cadastro incompleto" no lugar do subtítulo. O botão `+` do cabeçalho e o botão "Adicionar dependente" embaixo da lista abrem o wizard de criação.
- **Detalhe central novo (artboards 2 e 3).** Um card de cabeçalho (inicial, nome completo, idade, marcador de padrão), um card "Cadastro incompleto" com o checklist do que falta (`n de 4`) e o botão "Completar cadastro". Depois, três grupos: **Escola e rotina** (Escola, Dias e turnos com uma barra de sete dias embaixo do título, Embarque), **Van e contrato** (Van, Contrato) e **Cadastro** (Dados pessoais). Um item que falta mostra "Não informado" em âmbar. O detalhe também oferece "Definir como padrão" e "Remover dependente".
- **Um editor por assunto, cada um com o próprio "Salvar":**
  - **Escola (artboard 4):** busca por nome no Google Places, restrita a escolas. O lugar escolhido vira uma escola da Vanep por `POST /api/schools/resolve`, e o `schoolToken` dela é salvo.
  - **Dias e turnos (artboard 6):** sete linhas, começando na segunda, cada uma com um switch de liga/desliga e um seletor de turno (Manhã, Tarde, Noite, Integral). Lê e substitui a grade por `GET` e `PUT /api/dependent/{token}/school-days`.
  - **Embarque (artboard 8):** o formulário de endereço postal IBGE que já existe, para o endereço do dependente, embaixo de um mapa estático de mentira.
  - **Dados pessoais (artboard 9):** nome, nascimento, gênero e CPF opcional (`document`).
- **Wizard de criação.** "Adicionar dependente" passa por Dados pessoais → Escola → Dias e turnos → Embarque. O dependente é criado no primeiro passo. Todos os passos seguintes podem ser pulados, e o wizard termina no detalhe do dependente novo. "Completar cadastro" reaproveita o wizard só com os passos que faltam.
- **Prontidão vinda do back.** Os sinais de "Cadastro incompleto" vêm de `GET /api/clients/me/contract-readiness`, usando só as entradas `DEPENDENT`. O app não reimplementa a regra.
- **Remover dependente.** Por `DELETE /api/dependent/{token}`, depois de um diálogo de confirmação.
- **As linhas Van e Contrato não levam a lugar nenhum.** Elas aparecem e não fazem nada ao tocar, porque o cliente ainda não tem telas de van e de contrato.
- **Mapa estático de mentira.** Escola e Embarque mostram um mapa decorativo, sem interação, com um pino e um chip "Ajustar no mapa" que não faz nada. O back não guarda coordenadas, então nada nele é real. O mapa leva um `TODO` que cita o pré-requisito no back.
- **A validação de CPF vira código compartilhado.** `isValidCpf` e `CpfInputFormatter` saem do `auth` e vão para `lib/core/`, do mesmo jeito que o `Gender` foi antes.
- **BREAKING (interno):** `DependentFormPage`, `DependentAddressFormPage`, `DependentCard` e `DependentFormCubit` são substituídos pelo detalhe e pelos editores e são apagados. A entrada do menu do perfil e a aba Dependentes abrem a lista nova.

## Capabilities

### New Capabilities

- `dependents-hub`: a lista de dependentes e o detalhe do dependente. Cobre as linhas, os marcadores de dado faltando, a barra da semana, o dependente padrão, a remoção e as linhas sem destino.
- `dependent-school`: escolher a escola do dependente buscando escolas e salvando a escola resolvida.
- `dependent-school-days`: ver e substituir a grade escolar semanal do dependente, com um turno por dia.
- `dependent-personal-data`: editar nome, nascimento, gênero e CPF opcional do dependente.
- `dependent-pickup`: editar o endereço de embarque do dependente com o formulário postal compartilhado e o mapa estático.
- `dependent-creation-wizard`: criar um dependente em passos seguidos e puláveis, e completar os passos que faltam num dependente que já existe.
- `dependent-readiness`: mostrar quais itens de prontidão contratual faltam a um dependente, conforme o back informa.

### Modified Capabilities

Nenhuma. `openspec/specs/` ainda está vazio. Esta change substitui a parte de tela da change `client-dependents`, que não foi arquivada (lista, formulário único, escolha do padrão). As regras de endereço de `dependent-postal-address` (change `personal-address`) continuam como estão e são reaproveitadas por `dependent-pickup`.

## Impact

**Módulo `lib/modules/dependents/`:** a entidade `Dependent` ganha `school` (token e nome) e `document`. O módulo ganha um value object da grade, use cases da grade e da remoção, um cubit de detalhe, um cubit por editor, um cubit do wizard, e telas e widgets novos. O formulário, o card e a tela de endereço antigos são apagados.

**Módulos novos:** `lib/modules/schools/` (transforma uma escola do Places numa escola da Vanep) e `lib/modules/contract_readiness/` (lê a prontidão de um conjunto de dependentes; o fluxo de pedido de orçamento vai reaproveitar depois).

**`lib/core/`:**
- `SchoolShift` em `core/domain`;
- validação e máscara de CPF, vindas do `auth`;
- o widget do mapa estático em `core/ui`;
- `VanepMenuCard`/`VanepMenuItem` com ícone à direita configurável e conteúdo extra embaixo do título (para a barra da semana);
- `VanepAppBar` com legenda opcional e ações opcionais;
- um `VanepSection` novo (título, nota e link de ação opcionais em cima de um conteúdo), extraído do menu do perfil.

Os dois últimos são os padrões de cabeçalho e de seção que as outras telas do canvas (propostas, contratos, vans) também usam.

**`Environment`:** `schoolResolveEndpoint`, `contractReadinessEndpoint`, e o caminho de school-days montado a partir de `dependentsEndpoint`.

**Localização:** todos os textos novos em `app_pt.arb` e `app_en.arb`.

**Dependências do back (vanep-api-java):**

| Necessidade | Situação no back | Efeito aqui |
|---|---|---|
| `GET`/`PUT /api/dependent/{token}/school-days`, sem `shift` | PR 3 da `service-request-proposal`, em andamento | O teste manual de Dias e turnos precisa do back local nessa branch |
| `GET /api/clients/me/contract-readiness` | Implementado na branch do PR 3 da `service-request-proposal`, ainda sem commit | Sem ele, os sinais de prontidão simplesmente não aparecem; o QA manual da prontidão usa o back local nessa branch |
| `POST /api/schools/resolve`, `schoolToken` e `school` no dependente | Já na `main`; a branch do PR 3 passa a aceitar também `primary_school` e `secondary_school` | O filtro do Places e a validação do back usam os mesmos tipos |
| `document` validado como CPF, guardado só com dígitos, CPF repetido em outro dependente → 409 | Branch do PR 3, ainda sem commit | O app valida o CPF antes de enviar e mostra a mensagem do back no 409 |
| Remoção bloqueada com pedido de orçamento aberto (422 `dependent.open_negotiation`) | Na spec do back, ainda sem código (vem com as solicitações) | O app mostra a mensagem do back no 422 |
| Trava por contrato em escola, grade e remoção ("guardas no dependente contratado") | Fora da `service-request-proposal`; listada lá como fase 5 | Os artboards 5 e 7 e a regra de trava ficam **fora desta change** |
| Coordenadas em `address` e `school` | Não planejado | O mapa continua um placeholder estático com `TODO` |

**Fora de escopo:**
- os artboards 5 e 7 (Escola e Dias e turnos só leitura quando há contrato);
- "Solicitar alteração" (aditivo, fase 8 do back);
- a linha "Hoje · na escola desde…" no detalhe (o cliente não tem endpoint de viagem);
- as telas de van e de contrato atrás das linhas sem destino;
- um mapa interativo de verdade.
