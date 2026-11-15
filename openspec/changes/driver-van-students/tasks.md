Issue no Genwork: **VAN-57**. Branches no formato `VAN-57/<fase>-<nome>`, empilhadas a partir de `VAN-57/spec-driver-van-students`. A tabela de fases fica em `design.md` (Entrega fatiada). Toda fase termina com `make lint` e `make test` verdes e espera o teste manual no aparelho, e a aprovação explícita, antes de qualquer commit (R27a).

## 1. Fase 1 — Grade de horários no core (`VAN-57/1-schedule-core`)

- [ ] 1.1 Mover `route_leg.dart`, `clock_time.dart`, `operation_shift.dart` (com `deriveOperationShift`), `api_name.dart`, `legs_summary.dart` e a entidade `ScheduleSlot` de `negotiations/domain` para `lib/core/domain/schedule/`, e trocar os imports, sem cópia
- [ ] 1.2 Apagar `driver_van_central/domain/value_objects/operation_shift.dart` e usar o do core no DTO, na entidade e nos rótulos da occupancy; conferir com `grep -rn "enum OperationShift" lib` (uma definição só)
- [ ] 1.3 Mover os testes que já existem desses value objects para `test/core/domain/schedule/` e conferir que passam sem mudança
- [ ] 1.4 Rodar `make lint` e `make test`
- [ ] 1.5 Abrir o PR

## 2. Fase 2 — `VanepScheduleEditor` (`VAN-57/2-schedule-editor`)

- [ ] 2.1 Testes de widget primeiro para o `VanepScheduleEditor`: trecho não permitido desativado; ligar e desligar; um botão de horário por trecho ligado; "Aplicar a todos os dias" só com mais de um dia; semântica do botão de horário. Depois extraí-lo do `proposal_composer_page.dart` para `core/ui/` até os testes passarem
- [ ] 2.2 Trocar a grade e a tabela de horários do composer pelo editor; os testes do composer que já existem continuam verdes
- [ ] 2.3 Rodar `make lint` e `make test`
- [ ] 2.4 Abrir o PR

## 3. Fase 3 — Domínio (`VAN-57/3-van-students-domain`)

- [ ] 3.1 Entidades abstratas `UnlinkedPassenger`, `StudentWithFamily`, `FamilyMatch`; value objects `FamilyLink` (`notInvited`, `invited(sentAt)`, `familyJoined(match)`), `StudentFamilyFilter` e `VanStudentRow`
- [ ] 3.2 Testes primeiro para `buildVanStudentRows` (filtro de família, turnos ligados, busca sem acento, ordem por nome), `countByFamilyFilter`, `shiftsOf` e `firstPendingMatch`; depois implementar até passarem
- [ ] 3.3 Testes primeiro para o `UnlinkedPassengerDraft`: cada regra do D8 e os slots com o `deriveOperationShift`; depois implementar até passarem
- [ ] 3.4 `UnlinkedPassengerFailure` e os contratos `UnlinkedPassengerRepository` e `StudentFamilyRepository`, só os contratos
- [ ] 3.5 Rodar `make lint` e `make test`
- [ ] 3.6 Abrir o PR

## 4. Fase 4 — Dados (`VAN-57/4-van-students-data`)

- [ ] 4.1 Testes primeiro para os DTOs com o JSON de resposta do back e o corpo do `POST`; depois criar os DTOs e rodar o `build_runner`
- [ ] 4.2 Testes primeiro para o datasource e o repositório real: caminho e método; 400/422/404/sem resposta → falhas do D9. Depois adicionar `driverUnlinkedPassengersEndpoint` ao `Environment` e implementar
- [ ] 4.3 Testes primeiro para o `FakeStudentFamilyDataSource` (convidar, juntar, "não é", ligação pela ordem); depois implementar com um `TODO(VAN-57)` apontando para o relatório do `design.md`
- [ ] 4.4 Use cases (`ListUnlinkedPassengers`, `CreateUnlinkedPassenger`, `ListStudentsWithFamily`, `ListFamilyLinks`, `InviteFamily`, `ConfirmFamilyMatch`, `DismissFamilyMatch`, `FindParentsGroupLink`) com testes; `driver_van_students_container.dart` registrado no `main.dart`
- [ ] 4.5 Rodar `make lint` e `make test`; conferir o `GET` e o `POST` contra o back local
- [ ] 4.6 Abrir o PR

## 5. Fase 5 — Tela Alunos (`VAN-57/5-van-students-page`)

- [ ] 5.1 Testes primeiro para o `VanStudentsCubit` (`bloc_test`): carga (as três fontes), falha, filtros, turnos (o último não desliga), busca, convidar, juntar, "não é", link do grupo, recarregar
- [ ] 5.2 Testes de widget primeiro para a página: progresso, card de junção, controle com contagens, chips, linhas da tabela D7, vazio, erro; depois implementar a página e os widgets
- [ ] 5.3 Ligar o item "Alunos" da `VanCentralMenus` (`onOpenStudents`) e a rota `openDriverVanStudents` no `app.dart`; textos em `app_pt.arb` e `app_en.arb`
- [ ] 5.4 Rodar `make lint` e `make test`
- [ ] 5.5 Abrir o PR

## 6. Fase 6 — Cadastro do aluno sem família (`VAN-57/6-unlinked-passenger-form`)

- [ ] 6.1 Testes primeiro para o `UnlinkedPassengerFormCubit`: campos, escola (busca e escolha), endereço pelo CEP, trechos e horários, aplicar a todos, validação no envio, sucesso, falha do back
- [ ] 6.2 Testes de widget primeiro para a página "Adicionar aluno"; depois implementar com `VanepScheduleEditor`, `VanepCepAddressCard` / `VanepPostalAddressForm` e a busca de escola
- [ ] 6.3 Ligar o "Adicionar aluno" da tela Alunos e o recarregar na volta; textos novos nos ARB
- [ ] 6.4 Rodar `make lint` e `make test`
- [ ] 6.5 Abrir o PR

## 7. Fase 7 — API real (`VAN-57/7-van-students-real-api`)

> Só começa com a change `driver-students-family` do vanep-api-java mergeada.

- [ ] 7.1 Testes primeiro para o DTO e o datasource de `GET /api/drivers/me/students` (`familyStatus`, `familyMatch`, `invitedAt`, `vehicleToken`, `?vehicleToken=`) e para `invite`, `invite-link`, `merge` e `family-match/dismiss`; depois implementar e trocar o `FakeStudentFamilyDataSource` no container
- [ ] 7.2 Apagar o `FakeStudentFamilyDataSource`, os testes dele e o `TODO(VAN-57)`; conferir com `grep -rn "TODO(VAN-57)" lib` (nada)
- [ ] 7.3 Adicionar `share_plus`; "Convidar", "Reenviar" e "Mandar link no grupo de pais" abrem a folha de compartilhamento com o `inviteUrl` (D6)
- [ ] 7.4 Lista e progresso filtrados pela van selecionada (`vehicleToken`); van opcional no cadastro do aluno, com a van selecionada como padrão
- [ ] 7.5 Rodar `make lint` e `make test`; conferir o fluxo completo contra o back local (cadastrar → convidar → aceitar como cliente → juntar)
- [ ] 7.6 Abrir o PR
