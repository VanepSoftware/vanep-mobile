## Context

A motivação, a tabela de dependências do back e o escopo estão no `proposal.md`.

Estado atual de `lib/modules/dependents/`:

- `DependentsCubit` é fornecido uma única vez em `lib/app.dart` e carregado pelo `ClientShell` quando a aba Dependentes abre. Ele é dono da lista e da ação de dependente padrão.
- `DependentFormCubit` (344 linhas) controla uma tela só, de criação e edição, com nome, nascimento, gênero e endereço. A metade de endereço controla a `DependentAddressFormPage` por meio de `VanepPostalAddressForm`, `LookupCep`, `ListStates` e `ListCities`.
- `DependentChanges` + `dependentChangesToJson` são o único lugar que monta o body de `POST`/`PATCH`, e mandam só os campos tocados. `DependentDraft` e `validateDependentDraft` são donos das regras dos campos: nome obrigatório e nascimento válido e não no futuro.
- `Dependent` não tem `school` nem `document`. Nada lê `shift`, que o back remove no PR 3.

Fatos do back em que este design se apoia (vanep-api-java, branch `feat/service-request-proposal-school-days`):

- `DependentResponseDTO` devolve `school: {token, name}` e `document`. `DependentUpdateDTO` aceita `schoolToken` e `document` como `JsonNullable`.
- `document` agora é validado como CPF (`@Cpf`, com ou sem máscara, 400 `dependent.document.invalid`) e guardado só com dígitos; `null` no `PATCH` apaga. Um CPF já usado por outro dependente ativo dá 409 com o `detail` "Já existe um dependente cadastrado com este documento.".
- `DELETE /api/dependent/{token}` vai devolver 422 `dependent.open_negotiation` quando o dependente estiver num pedido de orçamento aberto. Está na spec do back; o código vem com as solicitações.
- `GET`/`PUT /api/dependent/{token}/school-days` recebem e devolvem `[{weekday: "MONDAY", schoolShift: "MORNING"}]`, com `SchoolShift` = `MORNING | AFTERNOON | NIGHT | FULLTIME`. O body do `PUT` é `{"days": [...]}`.
- `POST /api/schools/resolve` (`isAuthenticated()`) recebe `{placeId, sessionToken}`. Aceita lugares do tipo `school`, `primary_school`, `secondary_school` ou `educational_institution` e devolve um `SchoolResponseDTO` (201 quando cria a escola, 200 quando ela já existe). O cliente não tem a permissão `list_schools`, então não existe busca no catálogo: o Places é o catálogo.
- `GET /api/clients/me/contract-readiness?dependentTokens=…` devolve `{ready, missing: [{subject, dependentToken?, field}]}`; `dependentToken` só vem nas entradas `DEPENDENT`. `dependentTokens` é opcional e um token repetido é checado uma vez. Já está implementado na branch do PR 3 do back, ainda sem commit.

## Goals / Non-Goals

**Goals:**

- Um dono para cada fato: o cubit da lista é dono dos dependentes e da prontidão, o cubit do detalhe é dono da grade semanal, e cada editor é dono só do próprio rascunho (R06a).
- Cada editor funciona igual como tela avulsa e como passo do wizard, sem uma segunda implementação (R06).
- Toda fase pode ir para produção sozinha. O detalhe funciona antes de o endpoint de prontidão existir, tratando a prontidão como "indisponível".

**Non-Goals:**

- Trava por contrato (artboards 5 e 7). Nada no app sabe ainda o estado de contrato de um dependente.
- Mapa de verdade, geocodificação ou coordenadas.
- Cache ou suporte offline além do que a lista já faz.

## Decisions

### D1. O cubit da lista é dono dos dependentes e da prontidão; os editores devolvem resultados

`DependentsCubit` (que já vive no escopo do app) ganha:

- `readinessByToken: Map<String, Set<ContractReadinessField>>?`. `null` significa indisponível.
- `replaceDependent(Dependent)`, `addDependent(Dependent)`, `removeDependent(token)` e `refreshReadiness()`.

A tela de detalhe seleciona o dependente dela no `DependentsCubit` pelo token (`BlocSelector`) e não guarda cópia. Cada editor fecha devolvendo o valor salvo: `Navigator.pop<Dependent>` para dados pessoais, escola e embarque, e `pop<SchoolWeek>` para a grade. Quem abriu entrega o valor ao dono e chama `refreshReadiness()`.

*Alternativa considerada:* um cubit de detalhe que busca de novo `GET /api/dependent/{token}`. Rejeitada. Seria uma segunda cópia do mesmo dependente, que se desencontra da lista, e a lista já tem o payload completo.

### D2. `DependentDetailCubit` é dono só da grade semanal

A grade é um sub-recurso que a lista não carrega. O cubit do detalhe carrega a grade uma vez (`FindSchoolDays`) e a troca pelo que o editor da grade devolver. Os estados dele são carregando, carregado(`SchoolWeek`) e falhou. Uma carga que falhou mostra, na linha Dias e turnos, a ação de tentar de novo no lugar da barra. O resto do detalhe é desenhado a partir do `DependentsCubit`.

### D3. Dividir o `DependentFormCubit` em um cubit por editor, reaproveitando os value objects do domínio

| Editor | Cubit | Salva por |
|---|---|---|
| Dados pessoais | `DependentPersonalDataCubit` | `CreateDependent` / `UpdateDependent` com `DependentChanges` |
| Embarque | `DependentPickupCubit` (a metade de endereço do `DependentFormCubit` de hoje, movida) | `UpdateDependent` com `DependentChanges` tocando `address` |
| Escola | `DependentSchoolCubit` | `ResolveSchool` (módulo schools) e depois `UpdateDependent` tocando `school` |
| Dias e turnos | `DependentSchoolDaysCubit` | `ReplaceSchoolDays` |

`DependentField` ganha `document` e `school`. `DependentDraft` ganha `document` e `schoolToken`. `validateDependentDraft` ganha a regra do CPF, que chama o `isValidCpf` compartilhado (D7). `dependentChangesToJson` continua sendo o único lugar que monta o body. `DependentFormCubit`, `DependentFormState`, `DependentFormPage`, `DependentAddressFormPage` e `DependentCard` são apagados quando os substitutos entram (R43).

*Alternativa considerada:* manter um cubit de formulário só, com uma flag de "seção". Rejeitada. Cada editor tem o próprio salvar e a própria regra de habilitar o botão, então um cubit só carregaria quatro fatias de estado sem relação entre si.

### D4. `SchoolWeek` guarda as regras da grade no domínio

`SchoolShift` fica em `lib/core/domain/school_shift.dart`, ao lado do `Gender`, porque o fluxo de pedido de orçamento também vai precisar dele. `Weekday` é um enum de domínio, começando na segunda, em `dependents/domain/value_objects/`. `SchoolWeek` é um `Equatable` imutável construído sobre `Map<Weekday, SchoolShift>`, com:

- `turnOn(day)`, que aplica a regra de turno padrão da spec: o dia ligado mais próximo antes, depois o mais próximo depois, depois `MORNING`;
- `turnOff(day)`, `changeShift(day, shift)`, `dayCount`, `isEmpty` e `days` (começando na segunda).

Os segmentos da barra (um por dia: nenhum, meio período ou integral) e a contagem anunciada pelo leitor de tela saem de uma única função de apresentação, `describeSchoolWeekBar(SchoolWeek)`, usada só pela linha do detalhe (R06a: uma única derivação para exibição). A linha não mostra resumo da semana em texto.

### D5. Prontidão e escolas são módulos próprios

- `lib/modules/contract_readiness/`: entidade `ContractReadiness` (`ready`, `gaps`), `ReadinessGap` (`subject`, `dependentToken?`, `field`), `ContractReadinessRepository.findReadiness(List<String> dependentTokens)` e o use case `FindContractReadiness`. O módulo de dependentes depende só desse contrato de domínio. O fluxo de proposta vai reaproveitar o módulo para os itens `CLIENT`.
- `lib/modules/schools/`: entidade `School` (`token`, `name`), `SchoolRepository.resolveSchool(placeId, sessionToken)` e o use case `ResolveSchool`.

Os quatro itens do checklist e a ordem dos passos no modo de completar saem de `ContractReadinessField` por uma única tabela na apresentação de dependentes (`dependentReadinessItems`). Ela é o único mapeamento de campo para rótulo, estado de feito e passo do wizard.

Codificação da query: `dependentTokens` vai como parâmetro repetido (`ListFormat.multi`). O Spring converte tanto a forma repetida quanto a separada por vírgula em `List<String>`, então as duas funcionam. O teste da camada de dados fixa a forma repetida.

*Alternativa considerada:* calcular a prontidão no app a partir do dependente e da grade. Rejeitada na proposta (decisão do usuário). Duplica a regra do back, e a lista precisaria de uma requisição de grade por dependente.

### D6. Busca no Places restrita a escolas

`PlaceAutocompleteDataSource.findSuggestions` ganha um `includedPrimaryTypes` opcional. O editor de Escola passa `['school', 'primary_school', 'secondary_school']`, e os outros chamadores não mudam. O `PlaceAutocompleteController` repassa o parâmetro. Depois de um resolve com sucesso, o editor chama `PlaceSearchSession.completeAfterHandover()`, como os fluxos de endereço fazem depois que o back usa o token da sessão.

### D7. Código compartilhado movido para `lib/core/`

- `isValidCpf`, `cpfCheckDigit` e `cpfDigitCount` saem de `auth/domain/value_objects/signup_form.dart` e vão para `lib/core/domain/cpf.dart`.
- `CpfInputFormatter` e `formatPartialCpf` saem de `auth/presentation/formatters/signup_input_formatters.dart` e vão para `lib/core/formatters/cpf_input_formatter.dart`.
- `auth` e `assistant` passam a importar do core. Nenhuma cópia fica para trás (R02, R06a).

### D8. Peças de UI

- **Linhas agrupadas:** `VanepMenuItem` ganha `trailingIcon` (chevron por padrão) e um widget `content` opcional embaixo do título (a barra da semana). O `warningSubtitle` já desenha o "Não informado" em âmbar.
- **Cabeçalho com legenda:** `VanepAppBar` ganha uma `caption` opcional embaixo do título (o primeiro nome do dependente em todo editor, "Dependente" no detalhe, "Passo n de N" no wizard) e `actions` opcionais (o menu ⋮ do detalhe). Título, legenda e ações são todos opcionais, e cada um só aparece quando é passado, então as 13 chamadas que já existem não mudam. O canvas usa o mesmo cabeçalho em propostas e contratos ("Proposta / Para o Pedro"), e é por isso que ele vai para o core.
- **`VanepSection`** (`lib/core/ui/`): título opcional em `VanepTypography.sectionTitle`, nota opcional apagada à direita ("5 dias"), link de ação opcional à direita ("Editar", "Ver as 12"), e o conteúdo embaixo. Só o conteúdo é obrigatório. É extraído do `ProfileMenuSectionView` (auth), que já faz "título opcional + card" e passa a usá-lo (R06, R06a). O canvas usa esse padrão em todas as telas.
- **`VanepMapPlaceholder`** (`lib/core/ui/`): um `CustomPainter` de ruas nas cores do design system, com 168 px de altura, `pinIcon`, `label` opcional e `actionLabel` opcional. A arte fica dentro de `Semantics(image: true, label: …)` com `ExcludeSemantics`, e o widget ignora toques, menos no chip, que é um botão que não faz nada. Ele tem um único `TODO` (R40a, caso 2): trocar por um mapa de verdade quando `address` e `school` tiverem coordenadas. O `TODO` cita as duas telas que usam o widget.
- **Estrutura dos editores:** cada editor é uma tela (cabeçalho com título e legenda, corpo rolável, `VanepBottomBar` com o botão principal) cujo corpo é um widget separado. O wizard reaproveita os corpos com uma barra inferior própria ("Continuar"/"Concluir" mais "Pular"). Só a barra inferior muda, então não existe uma segunda implementação de formulário.

### D9. O wizard é uma rota só

`DependentWizardCubit` guarda `steps: List<DependentWizardStep>`, o índice atual, o modo (`create` | `complete`) e o dependente criado ou editado. Os passos são calculados uma vez, ao abrir: os quatro no modo `create`, ou as lacunas de prontidão mapeadas por `dependentReadinessItems` no modo `complete`. O wizard é uma única rota que troca o corpo do passo, com um único `PopScope` decidindo para onde o voltar leva, como a spec pede. Quando termina no modo `create`, faz `pushReplacement` para o detalhe. Cada corpo de passo usa o mesmo cubit do editor avulso (D3). Quando um passo dá certo, o wizard avança em vez de fechar.

### D10. Erros

A taxonomia atual de `DependentFailure` continua. Um `DependentRejectedFailure(detail)` novo carrega o `detail` do `ProblemDetail` quando um 4xx não é atribuído a um campo, lido pelo `readProblemDetail` que já existe. É o caso do 409 de CPF repetido e do 422 de remoção com pedido aberto; hoje o repositório trata qualquer status fora de 400 e 404 como erro genérico. `SchoolFailure` (módulo schools) cobre `rejected(detail)`, `network` e `unexpected`. `ContractReadinessFailure` nunca é mostrado ao usuário: o cubit transforma qualquer falha em `readinessByToken = null`.

## Risks / Trade-offs

- [Endpoint de prontidão ainda sem commit no back] → Pela spec, falhas de prontidão são silenciosas, então o detalhe, os editores e o wizard funcionam sem ele. Só os marcadores âmbar, o card de checklist e o modo de completar ficam apagados enquanto o back não estiver rodando com ele. A fase 2 testa a camada de dados contra o contrato da spec.
- [Endpoint de school-days numa branch do back que não foi mergeada] → Os testes manuais das fases que mexem na grade precisam do back local em `feat/service-request-proposal-school-days` ou numa branch posterior.
- [O filtro de tipo do Places deixa escolas de fora] → Usar três tipos primários, o máximo que cobre escolas sem pegar universidades. O back aceita os mesmos três tipos (mais `educational_institution`) e ainda valida o lugar. Uma escola que não aparece não gera resultado, nunca um salvamento errado.
- [O mapa estático parece real] → O leitor de tela o anuncia como ilustrativo, e ele nunca mostra uma posição real. O `TODO` mantém a troca visível na revisão de código.
- [É possível editar um dependente com contrato] → O back também não impõe a trava (fase 5 de lá). Contratos ainda não nascem de propostas (fase 3 de lá), então hoje nenhum dependente real tem contrato. Revisitar quando a fase 5 do back entrar.
- [A regra de turno padrão surpreende o usuário] → O turno aparece na hora no seletor, e nada é salvo antes de "Salvar".

## Migration Plan

Só mobile, sem migração de dados. As telas antigas continuam ligadas até a fase que troca as entradas delas (fase 5), então todo build intermediário mantém um fluxo de dependentes funcionando. Rollback é reverter o PR da fase.

### Phased delivery (R16–R23)

| Fase | Conteúdo | Depende de | Em paralelo com |
|---|---|---|---|
| 1 | Core (`SchoolShift`, CPF movido, `VanepMapPlaceholder`, extensão do `VanepMenuItem`, legenda e ações no `VanepAppBar`, `VanepSection`, filtro de tipo no Places) e contratos e value objects de domínio (`Dependent` + escola/documento, `Weekday`, `SchoolWeek`, contrato `DependentSchoolDaysRepository`, falhas; domínio de `schools` e `contract_readiness`) | — | — |
| 2 | Dados dos três módulos (DTOs, datasources, implementações de repositório, endpoints no `Environment`), use cases e containers | Fase 1 mergeada; PR 3 do back para o QA manual | — |
| 3 | Cubits: mudanças no `DependentsCubit`, `DependentDetailCubit` e os quatro cubits de editor | Fase 2 mergeada | — |
| 4 | Lista, detalhe e as quatro telas de editor, `describeSchoolWeekBar`, `dependentReadinessItems`, l10n | Fase 3 mergeada | — |
| 5 | `DependentWizardCubit`, rota do wizard, modo de completar, troca das entradas, remoção do código antigo | Fase 4 mergeada | — |

Nesta change, o desenvolvedor aceitou PRs de cerca de 1000 linhas produtivas, em vez das 600 da R23. As fases 1 e 2 juntam, cada uma, duas camadas vizinhas num PR. A R20 continua valendo: toda interface entra uma fase antes da implementação dela.

## Open Questions

- Se a linha "Hoje · na escola desde…" volta para o detalhe quando o cliente tiver um endpoint de viagem. Isso não afeta esta change.
