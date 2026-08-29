### Phased delivery (R16–R23)

| Phase | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 0 | **Outro repo (`vanep-api-java`).** Busca por um único `placeId` com ordenação por especificidade + `@Size(max = 10)` nas áreas | — | 1, 2, 3 |
| 1 | Shell do motorista e bottom nav só com ícone: adota o que já está no working tree, testa e commita | — | 0 |
| 2 | `lib/core/places/`: contrato de autocomplete, sessão, chave por plataforma, debounce | — | 0, 1 |
| 3 | Módulo `driverserviceareas`: domínio, dados, cubit, tela, entradas pelo onboarding e pelo perfil | Fase 2 mergeada | 0 |
| 4 | Módulo `driversearch`: domínio, dados, cubit | Fase 2 mergeada **e** fase 0 deployada | — |
| 5 | Tela de busca do cliente e resultado ordenado | Fase 4 mergeada | — |

> ⛔ **A fase 0 é em outro repositório e bloqueia só as fases 4 e 5.** O endpoint atual exige origem **e** destino e não ordena nada — nenhuma das duas coisas serve. As fases 1 a 3 não dependem dela e podem começar imediatamente.
>
> ⚠️ **R27a: nenhum commit sem sua aprovação.** Ao fim de cada fase, `make lint` e `make test` passando não bastam — eu paro e espero você testar no emulador ou aparelho.

## 0. Pré-requisito no backend (`vanep-api-java`)

> Não é executável neste repositório. Registrado aqui para o plano ficar completo; vira uma change própria em `vanep-api-java`.

- [ ] 0.1 Propor a change no `vanep-api-java` com estas três mudanças
- [ ] 0.2 `GET /api/drivers/search` aceita **um** `placeId` (+ `sessionToken` opcional) em vez de origem e destino
- [ ] 0.3 Ordenar o resultado pela posição do `district_id` do motorista na lista de ancestrais do ponto; área de cidade inteira ordena por último; motorista com várias áreas casando fica com o **melhor** rank
- [ ] 0.4 Teste de ordenação construindo os quatro níveis (`Conjunto J` → `QNL 5` → `Taguatinga` → cidade) e afirmando a ordem exata — sem isso a regressão passa despercebida com árvore rasa (R5 do design)
- [ ] 0.5 `@Size(max = 10)` em `DriverServiceAreaRequestDTO.areas`, com mensagem em `messages_pt_BR.properties`
- [ ] 0.6 Avisar aqui quando estiver deployado, para desbloquear as fases 4 e 5

## 1. Fase 1 — Shell do motorista e nav só com ícone (branch: `feat/1-driver-shell-icon-only-nav`)

> O trabalho já existe **sem commit** no working tree (`lib/app.dart`, `lib/core/ui/vanep_bottom_nav.dart`, `lib/shell/driver_shell.dart`, `lib/shell/driver_bottom_nav.dart`). Esta fase o adota, não o refaz — inclusive o `label` que foi movido para `Semantics`, que é o que mantém o leitor de tela funcionando sem texto visível.

- [x] 1.1 Ler o diff não commitado inteiro e listar o que ele muda; tratar como código novo a revisar, não como pronto (R6 do design)
- [x] 1.2 Teste de widget do `VanepBottomNav`: nenhum `Text` renderizado, ícone presente, e `Semantics.label` preservado em cada item
- [x] 1.3 Teste de widget do `VanepNavButton`: item selecionado usa `selectedIcon` e a superfície de seleção; não selecionado usa `icon`
- [x] 1.4 Teste do `AuthGate`: sessão com `UserType.driver` monta `DriverShell`; qualquer outro tipo monta `ClientShell`
- [x] 1.5 Corrigir o que os testes expuserem no código adotado
- [x] 1.6 Rodar `make lint` e `make test`
- [x] 1.7 **Regressão exposta pela separação dos shells:** a aba Perfil do `DriverShell` é `VanepComingSoon`, enquanto o `ClientShell` monta o `ProfilePage` real. Antes da fase 1 todo mundo caía no `ClientShell`, então até motorista via o perfil completo — separar os shells tirou a tela dele. Consertar no mesmo PR que criou a regressão
- [x] 1.8 Teste do `DriverShell`: a aba Perfil renderiza `ProfilePage`, não `VanepComingSoon`
- [x] 1.9 Montar o `ProfilePage` no `DriverShell` reusando o padrão do `ClientShell` (R06) — `ProfileSummaryCubit` + `assistantStatusLabel` + refresh ao abrir a aba
- [x] 1.10 Prover `ProfileSummaryCubit` também no ramo de motorista do `app.dart`; sem isso o `BlocBuilder` estoura em runtime
- [x] 1.11 Teste do `AuthGate` para o ramo motorista cobrindo o cubit novo
- [x] 1.12 Rodar `make lint` e `make test`
- [ ] 1.13 **Parar e aguardar sua validação no aparelho** (R27a); só então commitar e abrir PR

## 2. Fase 2 — `lib/core/places/` (branch: `feat/2-core-places-autocomplete`)

> Fica em `core` e não num módulo porque as fases 3 e 5 usam as duas (R02, D2 do design). Nenhuma tela nesta fase.

- [x] 2.1 Documentar `GOOGLE_PLACES_API_KEY_ANDROID` e `GOOGLE_PLACES_API_KEY_IOS` no `.env.example`, explicando por que são duas chaves e por que a de servidor nunca entra aqui (comentário permitido em config por R40a)
- [x] 2.2 Testes de `Environment`: devolve a chave Android no Android e a iOS no iOS; falha explícita quando a chave da plataforma corrente está ausente
- [x] 2.3 Estender `Environment` com o acessor por plataforma e o endpoint de autocomplete
- [x] 2.4 Testes do gerador de sessão: token estável durante uma busca, token novo após a entrega da seleção, tokens independentes entre duas caixas (D4)
- [x] 2.5 Implementar o ciclo de vida da sessão como objeto de domínio, sem Flutter
- [x] 2.6 Entidade `PlaceSuggestion` (`placeId`, texto principal, texto secundário) com igualdade por valor (R04)
- [x] 2.7 Testes do datasource com `mocktail`: resposta OK mapeia sugestões; lista vazia é estado vazio e **não** erro; `403` de chave rejeitada é falha distinta de rede; timeout é falha de rede
- [x] 2.8 Implementar o datasource HTTP contra `POST /v1/places:autocomplete` com `includedRegionCodes: ["br"]` e `sessionToken`, devolvendo `Result<PlaceAutocompleteFailure, List<PlaceSuggestion>>`
- [x] 2.9 Testes do debounce e do descarte de resposta fora de ordem (R3 do design)
- [x] 2.10 Implementar debounce e ignorar resposta mais antiga que a última requisição
- [x] 2.11 Registrar tudo no container de DI (R03)
- [x] 2.12 Rodar `make lint` e `make test`
- [ ] 2.13 **Parar e aguardar sua validação**; só então commitar e abrir PR

## 3. Fase 3 — Áreas de atuação do motorista (branch: `feat/3-driver-service-areas`)

> Se passar de 10 arquivos novos ou ~600 linhas (R23), quebrar em `3a` (domínio + dados) e `3b` (cubit + tela).

- [x] 3.1 Testes das entidades e do contrato: `ServiceArea` (token, nome, se cobre a cidade inteira) e `DriverServiceAreaRepository`
- [x] 3.2 Entidades, contrato de repositório e falhas do domínio
- [x] 3.3 Testes dos use cases `FindMyServiceAreas` e `ReplaceMyServiceAreas`
- [x] 3.4 Implementar os dois use cases
- [x] 3.5 Teste do DTO de request afirmando que o corpo carrega **somente** `placeId` e `sessionToken` por item — nenhum campo de cidade, estado, bairro ou rua (requisito da spec)
- [x] 3.6 DTOs (`freezed` + `json_annotation`) e `dart run build_runner build --delete-conflicting-outputs` (R15)
- [x] 3.7 Datasource e repositório contra `GET` e `PUT /api/drivers/me/service-areas`, traduzindo `400` de distrito obrigatório e de limite excedido em falhas de domínio distintas
- [x] 3.8 Testes de cubit com `bloc_test`: adicionar área, remover área, salvar com sucesso, salvar rejeitado pelo backend mantendo as edições na tela
- [x] 3.9 Teste de cubit do limite: com 10 áreas, adicionar fica indisponível (D6)
- [x] 3.10 Implementar o cubit com a constante do limite declarada uma vez no módulo
- [x] 3.11 Tela usando os widgets de `lib/core/ui/` (R10b) — buscar antes por padrão existente em `core/ui` e `core/design_system` (R10a); toda a copy em ARB (R10)
- [x] 3.12 Marcar a sugestão de nível cidade como menos precisa, **sem bloquear** o salvamento — a autoridade é o backend (D5)
- [x] 3.13 Teste de widget: mensagem pt-BR do backend aparece quando a cidade exige bairro, e a seleção continua na tela
- [ ] 3.14 Ler `onboarding.pendingSteps` do `GET /api/user/me` para oferecer a tela após o primeiro login; **nunca** inferir o passo consultando as áreas (D7)
- [ ] 3.15 Testes: passo pendente oferece a tela; recusar leva ao home do motorista com acesso completo; a tela abre pelo perfil a qualquer momento
- [x] 3.16 Entrada permanente pelo perfil do motorista
- [x] 3.17 Rodar `make lint` e `make test`
- [ ] 3.18 **Parar e aguardar sua validação**; só então commitar e abrir PR

## 4. Fase 4 — Domínio e dados da busca do cliente (branch: `feat/4-driver-search-domain`)

> ⛔ Depende da **fase 0 deployada**. Antes disso o endpoint recusa a requisição de um único `placeId`.

- [ ] 4.1 Confirmar que a fase 0 está no ar chamando o endpoint com um `placeId` só
- [x] 4.2 Testes da entidade `DriverSearchResult` e do contrato do repositório
- [x] 4.3 Entidade e contrato, **sem** nenhum campo de endereço residencial (requisito de privacidade da spec do backend)
- [x] 4.4 Testes do use case `SearchDriversByPlace`
- [x] 4.5 Implementar o use case
- [x] 4.6 DTOs + `build_runner` (R15)
- [x] 4.7 Datasource e repositório, traduzindo `400` de place não resolvido e `429` de rate limit em falhas distintas
- [x] 4.8 Teste afirmando que a app **preserva a ordem** devolvida pela API e não reordena localmente (R5 do design)
- [x] 4.9 Rodar `make lint` e `make test`
- [ ] 4.10 **Parar e aguardar sua validação**; só então commitar e abrir PR

## 5. Fase 5 — Tela de busca do cliente (branch: `feat/5-client-location-search`)

- [ ] 5.1 Testes de cubit: busca com resultados, nenhum motorista cobre o lugar, place não resolvido, rate limit — quatro estados distintos
- [ ] 5.2 Implementar o cubit
- [ ] 5.3 Tela com **uma** caixa de busca aceitando endereço ou escola, reusando o autocomplete da fase 2 e o `DriversSearchField` existente se ele servir; extrair para `core/ui` antes de duplicar (R6, R10a)
- [ ] 5.4 Lista de resultados reusando o `DriverCard` do módulo `drivers` (R06 — não criar um card paralelo)
- [ ] 5.5 Teste de widget: quatro motoristas em níveis diferentes aparecem exatamente na ordem devolvida pela API
- [ ] 5.6 Estados vazio, de erro e de rate limit distintos entre si, todos em ARB (R10)
- [ ] 5.7 Ligar a tela ao `ClientShell`
- [ ] 5.8 Rodar `make lint` e `make test`
- [ ] 5.9 **Parar e aguardar sua validação**; só então commitar e abrir PR

## 6. Encerramento

- [ ] 6.1 Conferir que as 3 specs desta change foram cobertas pelas fases entregues
- [ ] 6.2 Rodar `make coverage` e conferir o mínimo do projeto
- [ ] 6.3 Registrar na Q1 o que o relatório de billing mostrou depois do autocomplete real entrar no ar — procurar `Autocomplete Session Usage` a US$ 0; se aparecer só `Autocomplete Requests`, a sessão quebrou na fronteira entre chaves
- [ ] 6.4 Anotar no checklist de release que o SHA-1 do keystore de **release** precisa entrar na chave Android antes de publicar, senão o autocomplete morre em produção com `403` (R4 do design)
- [ ] 6.5 Sincronizar as specs para `openspec/specs/` e arquivar a change
