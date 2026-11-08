## Context

- **Design:** frame "Vans · 3. Alunos da van (tela interna)" de `docs/design/vanep-motorista.html`. O canvas não tem frame para o cadastro do aluno; o cadastro segue os padrões de formulário que o app já usa (editor de dependente e "Montar proposta").
- **Back (vanep-api-java, change `contract-core`):**
  - `GET/POST /api/drivers/me/unlinked-passengers`. Também existem `GET/PATCH/DELETE /{token}` e `PUT /{token}/schedule`, que esta change não usa.
  - Resposta: `token`, `name`, `schoolToken`, `schoolName`, `schoolShift`, `address`, `notes`, `slots[] {weekday, leg, shift, pickupTime}`, `createdAt`, `updatedAt`.
  - Criação: `name`, `schoolToken`, `schoolShift`, `address {cityToken, street, zipCode, number, complement, neighborhood}`, `notes`, `slots`.
  - `GET /api/drivers/me/occupancy` devolve `students` e `studentsWithFamily` e já está no app (`FindDriverOccupancy`).
- **Limite do back:** o aluno não vinculado é do motorista, não de uma van. A lista é a mesma para qualquer van; o cabeçalho só identifica a van de onde a tela foi aberta.

## Goals / Non-Goals

**Goals:** a tela inteira do canvas, com dados reais onde o back já existe; o cadastro do aluno sem família; a troca para dados reais sem mexer na apresentação quando o back entregar o resto.

**Non-Goals:**
- editar ou excluir o aluno não vinculado (não está no canvas);
- detalhe do aluno;
- filtrar por van;
- compartilhamento de verdade do link de convite.

## Decisions

### D1. Módulo `driver_van_students`

O módulo novo segue a R02. Ele depende de:
- `FindDriverOccupancy`, do `driver_van_central`, montado no container, como o `VanCentralCubit` já faz com `FindMyServiceAreas`;
- `ResolveSchool`, do `schools`, e o `PlaceAutocompleteController`, do core, para a escola.

### D2. Grade de horários no core

`RouteLeg`, `ClockTime`, `ScheduleSlot`, `OperationShift`, `deriveOperationShift` e `api_name` vão para `lib/core/domain/schedule/`, como o `Weekday` foi na VAN-78. O `OperationShift` de `driver_van_central` é apagado e passa a vir do core (R06a). É só mover arquivos, sem mudar comportamento.

### D3. `VanepScheduleEditor` no core

A grade de trechos (`VanepWeekLegsGrid<RouteLeg>`) e a tabela de horários por dia (`ComposerSchedule`, `ComposerScheduleRow`, `ComposerTimeButton`, "Aplicar a todos os dias") saem do `driver_proposals` e viram `VanepScheduleEditor` em `core/ui/`.

O widget não tem estado. Ele recebe:
- `isAllowed(weekday, leg)`;
- `isSelected(weekday, leg)`;
- `timeOf(weekday, leg)`;
- os callbacks `onToggled`, `onTimePicked` e `onApplyToEveryDay`.

O composer passa a usá-lo com `isAllowed` limitado aos trechos pedidos. O cadastro do aluno usa com tudo permitido.

### D4. Dois repositórios: o real e o que ainda não tem back

- `UnlinkedPassengerRepository` (real): `listMine()` e `create(UnlinkedPassengerDraft)`.
- `StudentFamilyRepository` (fictício):
  - `listStudentsWithFamily()`;
  - `listFamilyLinks()`: o estado da família de cada aluno não vinculado, pelo token dele, que pode ser `notInvited`, `invited(sentAt)` ou `familyJoined(match)`;
  - `inviteFamily(token)`;
  - `confirmMatch(token)`;
  - `dismissMatch(token)`;
  - `findParentsGroupLink()`.

A implementação é o `FakeStudentFamilyDataSource`, com um único `TODO(VAN-57)` que aponta para o relatório abaixo. Ele guarda o estado em memória, para que convidar, juntar e "não é" mudem a tela na mesma sessão. Os tokens fictícios de família são ligados aos tokens reais dos não vinculados pela ordem da lista; sem não vinculados, não há sugestão.

### D5. Uma lista derivada, um dono

O `VanStudentsCubit` guarda:
- as respostas dos dois repositórios e o progresso;
- o filtro (`StudentFamilyFilter.all | withFamily | withoutFamily`);
- os turnos ligados;
- a busca;
- a ação em andamento.

A lista na tela, as contagens do controle, os turnos que aparecem e a sugestão de junção do topo vêm de funções puras do domínio (`buildVanStudentRows`, `countByFamilyFilter`, `shiftsOf`, `firstPendingMatch`). Nenhuma cópia fica em widget (R06a).

Regras:
- **Turno de um aluno:** os `OperationShift` dos slots dele. O aluno com família fictício traz os slots no mesmo formato.
- **Linha que passa pelo filtro de turno:** precisa ter pelo menos um turno ligado.
- **Busca:** por nome, sem diferenciar maiúscula, minúscula e acento.
- **Contagens do controle:** consideram o filtro de turno e a busca.
- **Progresso:** vem da `occupancy` (fonte da verdade do back), não da contagem da lista.

### D6. Convite e link sem compartilhamento real

Não existe link de convite no back. "Convidar", "Reenviar" e "Mandar link no grupo de pais" não abrem a folha de compartilhamento: chamam o repositório fictício e mostram a confirmação pelo `VanepFeedback`. O `share_plus` entra junto com o endpoint de convite, para não mandar a famílias reais um link que não funciona.

### D7. Subtítulo da linha

| Situação | Subtítulo | Ação |
|---|---|---|
| Sem família, não convidado | `<escola> · <turno> · <trechos>` | "Convidar" |
| Convite enviado | "Convite enviado hoje / há 1 dia / há n dias" | "Reenviar" |
| Família entrou | "Família entrou · confirmar" (cor de ação) | chevron; o toque abre a confirmação de junção |
| Com família | `<escola> · <turno> · <trechos>` | nenhuma |

Os trechos usam o `summarizeLegs` que já existe ("ida e volta", "só ida", "só volta"). Ele vai para o core junto com a grade.

### D8. Cadastro

- `UnlinkedPassengerDraft` (domínio) valida:
  - nome obrigatório, até 255;
  - escola obrigatória;
  - turno escolar obrigatório;
  - endereço pelas regras do `PostalAddressDraft`;
  - pelo menos um trecho;
  - todo trecho ligado com horário;
  - observações até 500.
- O turno de operação de cada slot vem de `deriveOperationShift(schoolShift, leg)`.
- A tela é uma página só, com seções na ordem do canvas do composer: Aluno (nome), Escola (busca do `schools` + turno), Embarque (`VanepCepAddressCard` / `VanepPostalAddressForm`), Dias e horários (`VanepScheduleEditor`) e Observações. O rodapé tem "Cadastrar aluno".
- Ao salvar, a página fecha e devolve o aluno criado, e a lista e o progresso recarregam.

### D9. Erros

`UnlinkedPassengerFailure`:
- `network`;
- `notFound`;
- `validation(fields)`, a partir do 400/422 com o `detail` do back;
- `unknown`.

Erro de carga: `VanepErrorView` com "Tentar de novo". Erro de ação: `VanepFeedback.showError`.

## Relatório de API que falta (para o vanep-api-java)

Especificado no vanep-api-java, change `driver-students-family`. Os contratos finais (nomes de campos, `familyStatus`, erros) estão nos specs de lá; a fase 7 abaixo segue o que estiver lá.

| # | Necessidade da tela | Proposta de endpoint |
|---|---|---|
| A1 | Alunos com família do motorista (contratos `ACTIVE`): nome, escola, turno escolar, slots, token do item | `GET /api/drivers/me/students?source=CONTRACT_ITEM`, ou expor o `RoutePassengerQueryService` sem data, por turno |
| A2 | Convidar a família de um aluno não vinculado e saber se o convite foi enviado (e quando) | `POST /api/drivers/me/unlinked-passengers/{token}/invite` → `{ inviteUrl, sentAt }`; `invitedAt` na resposta do aluno não vinculado |
| A3 | Link genérico do motorista para o grupo de pais | `GET /api/drivers/me/invite-link` → `{ url }` |
| A4 | Sugestão de junção: dependente cadastrado pela família que bate com o aluno não vinculado | `familyMatch { dependentToken, dependentName, age, clientName }` na resposta do aluno não vinculado, ou `GET .../{token}/family-match` |
| A5 | Juntar: o não vinculado vira o item de contrato do dependente e mantém a posição na rota | `POST .../{token}/merge { dependentToken }` |
| A6 | "Não é": descartar a sugestão | `POST .../{token}/family-match/dismiss` |
| A7 | Alunos por van, se a tela for por van | `vehicleToken` no aluno não vinculado e no item de contrato, ou filtro `?vehicleToken=` |

## Risks / Trade-offs

- **O mock não bate com o back que vier:** o contrato do `StudentFamilyRepository` fica pequeno e no domínio, e a apresentação não sabe que é fictício.
- **Lista igual para todas as vans:** o cabeçalho mostra a van, mas a lista é do motorista. Isso fica registrado no A7.
- **Mover os value objects mexe em muitos imports:** a fase 1 é só isso, com o `make test` verde antes de seguir.

## Migration Plan

Não há migração de dados. Quando o back entregar A1–A6, um datasource real troca o `FakeStudentFamilyDataSource` no container. O `TODO(VAN-57)` e o fake saem na mesma change.

### Entrega fatiada (R16–R23)

| Fase | Conteúdo | Depende de | Em paralelo com |
|----|----------|------------|---------------|
| 1 | Grade de horários no core (D2) e fim do `OperationShift` duplicado | — | — |
| 2 | `VanepScheduleEditor` no core e o composer usando ele (D3) | Fase 1 | Fase 3 |
| 3 | Domínio de `driver_van_students`: entidades, value objects, regras da lista, rascunho do cadastro, falhas e contratos | Fase 1 | Fase 2 |
| 4 | Dados: DTOs, datasource real, fake (`TODO(VAN-57)`), repositórios, use cases, container, endpoint | Fase 3 | — |
| 5 | Tela Alunos, item "Alunos" da Central e rota | Fase 4 | Fase 6 |
| 6 | Cadastro do aluno sem família e o "Adicionar aluno" | Fases 2 e 4 | Fase 5 |
| 7 | Troca do fake pela API real (`driver-students-family` no back): `GET /drivers/me/students`, convite com `share_plus`, link do grupo, juntar e descartar; filtro por van; van no cadastro; remoção do `FakeStudentFamilyDataSource` e do `TODO(VAN-57)` | Fases 5 e 6, e o back mergeado | — |

As branches seguem o formato `VAN-57/<fase>-<nome>`, empilhadas a partir de `VAN-57/spec-driver-van-students`. Cada fase leva os próprios testes (R25) e termina com `make lint` e `make test` verdes e com o teste manual no aparelho antes de qualquer commit (R27a).
