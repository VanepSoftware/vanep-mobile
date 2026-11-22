Issue no Genwork: **VAN-86**. Branches no formato `VAN-86/<fase>-<nome>`, empilhadas a partir de `VAN-86/spec-driver-documents`. A tabela de fases está em `design.md` (Entrega fatiada). Toda fase termina com `make lint` e `make test` verdes. Depois, espera o teste manual no aparelho e a aprovação explícita, antes de qualquer commit (R27a).

## 1. Fase 1 — Contrato da captura (`VAN-86/1-document-capture-contract`)

- [x] 1.1 Testes primeiro para `isWithinDocumentUploadLimit`: 10 MB (10 × 1024 × 1024 bytes) passa e 10 MB + 1 byte não passa. Depois implementar; verificar com `make test`
- [x] 1.2 Criar `DocumentSource` (`scanner`, `gallery`, `pdfFile`), `PickedDocument` (equatable), `DocumentCaptureFailure` (`permissionDenied`, `tooLarge`, `unexpected`) e o contrato `DocumentCapture` em `lib/core/media/`, só o contrato; verificar com `flutter analyze --fatal-infos`
- [x] 1.3 Rodar `make lint` e `make test`
- [ ] 1.4 Abrir o PR

## 2. Fase 2 — Captura e envio de arquivo (`VAN-86/2-document-capture-impl`)

- [x] 2.1 Adicionar `cunning_document_scanner` ^3.1.0, `file_picker` (a mais recente compatível), `open_filex` ^5 e `path_provider`. Verificar que `flutter build ios --no-codesign` não recria um Podfile (SPM)
- [x] 2.2 Atualizar no `Info.plist` os textos de câmera e fotos citando documentos e adicionar `CFBundleLocalizations` com pt-BR. Verificar no simulador que o scanner abre em português
- [x] 2.3 Testes primeiro para o adaptador do scanner: cancelar → `Ok(null)`; resultado → `PickedDocument` com o PDF, `pageCount` e prévias copiadas para a pasta do app; `permission_denied` → `permissionDenied`. Depois implementar
- [x] 2.4 Testes primeiro para os adaptadores da galeria (reaproveitando o `ImagePickerPhotoPicker`) e do PDF (`FileType.custom`, `['pdf']`), incluindo o arquivo grande → `tooLarge`. Depois implementar e registrar `DocumentCapture` no `media_container.dart`
- [x] 2.5 Testes primeiro para o `FileUploader` (multipart `file`, repassa `onSendProgress`). Depois trocar o `PhotoUploader` por ele e ajustar os chamadores de foto; os testes de foto que já existem continuam verdes
- [ ] 2.6 No aparelho: medir o PDF do scanner com 2, 4 e 10 páginas no iPhone e no Android, e fixar o `noOfPages`; confirmar se o Android precisa de `CAMERA` no manifest; testar num emulador sem Play Services. Registrar os números no PR
- [x] 2.6a Mudança de contrato do back (2026-11-22, o motorista manda só o arquivo, D6): `FileUploader.createWithFile` manda campos extras com o arquivo e devolve o corpo da resposta
- [x] 2.7 Rodar `make lint` e `make test`
- [ ] 2.8 Abrir o PR

## 3. Fase 3 — Modelo dos documentos (`VAN-86/3-documents-model`)

- [x] 3.1 Testes primeiro para os value objects: `DocumentType` (o tipo da API de cada um, o `DocumentKind`, se é de van e a ordem de exibição; "opcional" vem só do back, no requisito), `ComplianceState`, `SubmissionStatus` e `RejectionReason` lidos da API, valor desconhecido → `null`. Depois implementar
- [x] 3.2 Criar `DocumentFile` e `DocumentDisplayState` (sealed, equatable: `notSent`, `incomplete`, `rejected`, `expired`, `underReview`, `renewalUnderReview`, `expiringSoon(days)`, `approved`), com testes de igualdade
- [x] 3.3 Criar as entidades abstratas `DocumentSubmission`, `RequirementStatus`, `VehicleCompliance` e `DriverCompliance`; verificar com `flutter analyze --fatal-infos`
- [x] 3.3a Mudança de contrato do back (2026-11-22, o motorista manda só o arquivo, D6): sai o estado `incomplete`, e `RejectionReason` ganha `NOT_ELIGIBLE`
- [x] 3.4 Rodar `make lint` e `make test`
- [ ] 3.5 Abrir o PR

## 4. Fase 4 — Regras dos documentos (`VAN-86/4-documents-rules`)

- [x] 4.1 Testes primeiro para `resolveDocumentDisplayState`: cada linha da tabela da spec, inclusive envio incompleto, renovação em análise, "Vence hoje" e "Vence amanhã", o uso do `expiringSoon` quando vem do back e o `asOf` no lugar do relógio. Depois implementar
- [x] 4.2 Testes primeiro para o agrupamento (Pendentes e Enviados, ordem por tipo, vans com pendência primeiro, "Em dia") e para `summarizeDocuments` (contagem de pendentes, vencimento mais próximo, opcional fora da contagem). Depois implementar
- [x] 4.3 Testes primeiro para `DocumentFieldRules`: campos e obrigatórios de cada tipo; cada limite de data da spec (CRLV até 31/12 do ano que vem); o aviso de CNH sem D ou E. Depois implementar com os drafts sealed `PersonalDocumentDraft`, `VehicleDocumentDraft` e `CnhDraft`
- [x] 4.3a Ajuste do teste no emulador: categorias da CNH só D, E, AD e AE (as mesmas que o back aceita) e UF emissora validada contra as 27 UFs
- [x] 4.3b Ajuste do teste no emulador: documentos opcionais (alvará) ficam num grupo próprio e nunca contam como pendentes, nem na van nem no resumo
- [x] 4.3c Mudança de contrato do back (2026-11-22, o motorista manda só o arquivo, D6): saem as `DocumentFieldRules` e os drafts, e `resolveDocumentDisplayState` e `summarizeDocuments` deixam de ver envio sem arquivo
- [x] 4.4 Rodar `make lint` e `make test`
- [ ] 4.5 Abrir o PR

## 5. Fase 5 — Contratos e use cases (`VAN-86/5-documents-usecases`)

- [x] 5.1 Criar `DocumentSubmissionFailure` (sealed), `ComplianceFailure`, `SubmissionTarget` e os contratos `DriverComplianceRepository` e `DocumentSubmissionRepository`, só os contratos
- [x] 5.2 Testes primeiro (`mocktail`) para `LoadMyCompliance`, `UploadDocumentFile`, `FindSubmissionForResume` e `DownloadDocumentFile`. Depois implementar
- [x] 5.3 Testes primeiro para `SubmitDocument`: novo envio → `create` e depois o arquivo; `existing(token)` → `update` e depois o arquivo; falha no arquivo → falha com o token; falha nos dados → o arquivo não é enviado. Depois implementar
- [x] 5.3a Mudança de contrato do back (2026-11-22, o motorista manda só o arquivo, D6): saem `SubmissionTarget`, `UploadDocumentFile`, `FindSubmissionForResume` e as falhas de campo; o contrato vira `send(DocumentUpload)`, e o `SubmitDocument` só o repassa
- [x] 5.4 Rodar `make lint` e `make test`
- [ ] 5.5 Abrir o PR

## 6. Fase 6 — Dados (`VAN-86/6-documents-data`)

- [x] 6.1 Conferir o contrato final na sessão do back dona da VAN-86 (nomes de `expiringSoon` e dos `code` de data) e atualizar a Open Question do `design.md`
- [x] 6.2 Testes primeiro para os DTOs com o JSON real do `/api/drivers/me/compliance` (requisito com `current` e `pending`, `file` nulo, CNH com categoria) e para os corpos de criação e edição dos três recursos. Depois criar os DTOs e rodar o `build_runner`
- [x] 6.3 Adicionar ao `Environment` os endpoints de compliance, documentos do motorista, documentos da van, CNH e `/file`. Testes primeiro para os datasources (caminho, método, multipart, progresso)
- [x] 6.4 Testes primeiro para os repositórios: a rota certa para cada `DocumentDraft`; cada linha da tabela de erros da spec → `DocumentSubmissionFailure`; os `code` de data → erro de campo. Depois implementar
- [x] 6.5 Se o compliance ainda não estiver no back: criar `FakeDriverComplianceDataSource` com `TODO(VAN-86)` apontando para o pedido D2 e para o registro no container que sai junto. Não foi preciso: o back já tem o compliance (branch `VAN-86/11-driver-own-compliance`)
- [x] 6.6 Criar `driver_documents_container.dart` e registrá-lo no `main.dart`
- [x] 6.6b Mudança de contrato do back (2026-11-22, o motorista manda só o arquivo, D6): o datasource manda um `POST` multipart com `documentType` e `file` (a CNH só com `file`); saem os corpos de criação e edição e os endpoints por token; o mapeamento de erros lê os códigos do arquivo (`media.*`)
- [ ] 6.6a Verificar o `GET` do compliance e um envio completo contra o back local, com o login de um motorista (o back local responde 401 sem token; falta o teste manual)
- [x] 6.7 Rodar `make lint` e `make test`
- [ ] 6.8 Abrir o PR

## 7. Fase 7 — Listas (`VAN-86/7-documents-lists`)

- [x] 7.1 Testes primeiro (`bloc_test`) para o `DriverComplianceCubit`: carregar, falhar, `refresh` e o filtro por van
- [x] 7.2 Testes de widget primeiro para a M1 (seções com contagem, seção vazia escondida, cards com estado e cor, rodapé) e para a M2 (seção por van, "<n> pendentes" ou "Em dia", vazio sem van com o cadastro, só a van filtrada), mais skeleton e erro. Depois implementar com os widgets de `core/ui`
- [x] 7.3 Ligar "Documentos da van" da `VanCentralMenus` à M2 filtrada (a Central recarrega ao voltar) e criar a rota `openDriverVanDocuments` no `app.dart` (a de documentos pessoais entra na fase 11, com a primeira tela que a abre); até a fase 8, o card abre "Em breve" com `TODO(VAN-86)`; textos em `app_pt.arb` e `app_en.arb`
- [x] 7.3a Ajuste do teste no emulador: seção "Opcionais" na M1, depois de Enviados; na M2 o opcional fica no fim da van
- [x] 7.4 Rodar `make lint` e `make test`
- [ ] 7.5 Abrir o PR

## 8. Fase 8 — Detalhe e reprovado (`VAN-86/8-document-detail`)

- [x] 8.1 Testes de widget primeiro para o detalhe: os blocos na ordem, a frase por estado, "O que foi enviado" só com envio (com os dois envios na renovação), "Sobre o documento" de cada tipo, a ação de cada estado. Depois implementar
- [x] 8.2 Testes de widget primeiro para a M7: o título por código de motivo, a mensagem só quando existe, o aviso e "Reenviar". Depois implementar
- [x] 8.3 Testes primeiro para abrir o arquivo: imagem → tela com `ApiImageProvider`; PDF → download autenticado e `open_filex`; falha → aviso sem sair da tela. Depois implementar
- [x] 8.3a Ajuste do teste no emulador: o aviso de reprovado fica sem "Só" ("Este documento precisa ser enviado de novo."), porque podem faltar outros documentos
- [x] 8.3b Ajuste do teste no emulador: a linha "Arquivo" mostra "Ver arquivo" com o ícone de olho, nunca o nome do arquivo
- [x] 8.4 Rodar `make lint` e `make test`
- [ ] 8.5 Abrir o PR

## 9. Fase 9 — Fluxo de envio (`VAN-86/9-document-submission-flow`)

- [ ] 9.1 Testes primeiro (`bloc_test`) para o `DocumentSubmissionCubit`:
  - escolha do arquivo e cancelamento;
  - envio com progresso;
  - sucesso com `refresh` do `DriverComplianceCubit`;
  - falha no arquivo guardando o token;
  - "Tentar de novo" só com o arquivo;
  - "Revisar dados" virando `existing(token)`;
  - cada `DocumentSubmissionFailure`.
  Depois implementar
- [ ] 9.2 Testes de widget primeiro para a M3 (três opções, selo, dica, aviso de tamanho e de permissão) e para a M4 (destaque, miniaturas, "1 de 2", "Escanear de novo", "Continuar"). Depois implementar
- [ ] 9.3 Testes de widget primeiro para a M6 (enviando com MB e porcentagem, enviado com "Ainda falta", falha com as duas ações). Depois implementar; textos no ARB
- [ ] 9.4 Rodar `make lint` e `make test`
- [ ] 9.5 Abrir o PR

## 10. Fase 10 — Dados do documento e CNH (`VAN-86/10-document-forms`)

- [ ] 10.1 Testes de widget primeiro para a M5:
  - cartão do arquivo com "Trocar";
  - campos de cada tipo, a partir das `DocumentFieldRules`;
  - "(opcional)";
  - van travada;
  - botão desativado até ficar válido;
  - erro de data por campo;
  - CRLV com "Válido até" vazio e a dica do calendário do Detran.
  Depois implementar
- [ ] 10.2 Testes de widget primeiro para o formulário da CNH: máscara do registro com 9 a 11 dígitos, categorias, aviso sem D ou E, UF opcional e erro de número duplicado. Depois implementar
- [ ] 10.3 Testes primeiro para "Terminar envio": carrega o envio pelo `FindSubmissionForResume`, preenche a M5 e envia com `existing(token)`. Depois ligar no detalhe
- [ ] 10.4 Verificar no aparelho, contra o back local: envio novo, reenvio de reprovado, renovação, envio incompleto retomado e queda de rede no arquivo
- [ ] 10.5 Rodar `make lint` e `make test`
- [ ] 10.6 Abrir o PR

## 11. Fase 11 — Dados profissionais (`VAN-86/11-professional-data`)

- [ ] 11.1 Testes primeiro para o perfil do motorista com `ratingCount` e `experienceYears` opcionais (DTO e entidade do `profile`). Depois implementar e rodar o `build_runner`
- [ ] 11.2 Testes primeiro (`bloc_test`) para o cubit da tela: perfil, switch "Aceitando novos alunos" com o `ChangeAcceptingStudents` e falha só da situação dos documentos (as linhas aparecem sem subtítulo)
- [ ] 11.3 Testes de widget primeiro para a página:
  - topo com selo só com aprovado e linha sem nota ou sem experiência;
  - Atendimento: Áreas abre a rota; Expediente, Espera e Preço abrem "Em breve";
  - Documentos com o subtítulo âmbar de `summarizeDocuments`;
  - Empresa com "CNPJ · Opcional";
  - skeleton e erro.
  Depois implementar no módulo `driver_professional_data`
- [ ] 11.4 Ligar `ProfileMenuId.professionalData` no menu do motorista (`profile_menu_builder.dart` e `account_drawer.dart`) com a rota `openDriverProfessionalData`; verificar que responsável e auxiliar não ganham o item
- [ ] 11.5 Rodar `make lint` e `make test`
- [ ] 11.6 Abrir o PR
