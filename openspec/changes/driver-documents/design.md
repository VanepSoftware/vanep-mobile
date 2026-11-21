## Context

- **Design:** canvas "Vanep — Início, Vans e Propostas", página Motorista:
  - M1 a M7 e os detalhes `mob-doc-*`;
  - "Conta · Dados profissionais";
  - as notas `s-moto-docs`, `s-moto-docs-det` e `s-moto-conta`.
  As specs desta change prevalecem onde divergem do canvas (D13).
- **Back (vanep-api-java, change `vehicle-documents`, branches `VAN-86/*`):**
  - documentos da pessoa: `/api/driver-documents`, com os tipos `CRIMINAL_RECORD`, `SCHOOL_DRIVER_COURSE` e `MUNICIPAL_AUTHORIZATION`;
  - documentos da van: `POST/GET /api/vehicles/{token}/documents` e `/api/vehicle-documents/{token}`, com os tipos `CRLV`, `VEHICLE_INSPECTION` e `SCHOOL_VEHICLE_AUTHORIZATION`;
  - CNH: `/api/driver-cnhs`;
  - o arquivo de cada um vai em `POST …/{token}/file` (multipart `file`; JPEG, PNG, WebP ou PDF), e o tipo é descoberto pelo conteúdo;
  - um envio revisado não muda mais (409 `document.submission.reviewed`); renovar é um envio novo; só há um pendente por dono e tipo (409 `document.submission.pending_exists`);
  - erros com `code` estável no ProblemDetail;
  - limite de 10 MB no arquivo e na requisição (`max-file-size` e `max-request-size`).
- **Pedidos ao back (2026-11-20, sessão `vanep-api-java-6f`):** ver D2. Os nomes finais dos campos chegam com a resposta do back. Mudar um nome não muda nenhuma spec.
- **App hoje:**
  - `PhotoUploader` e `ImagePickerPhotoPicker` em `core`;
  - `ApiImageProvider` para imagem privada;
  - `share_plus`;
  - nenhuma tela de documento ou de CNH;
  - "Dados profissionais" desligado em `profile_menu_builder.dart`;
  - "Documentos da van" como "Em breve" em `van_central_menus.dart`;
  - o iOS usa Swift Package Manager (não há Podfile).

## Goals / Non-Goals

**Goals:**
- uma única leitura da situação, que alimenta todas as telas;
- as regras de exibição numa função pura;
- o envio em dois passos, que sobrevive a uma queda no arquivo;
- as validações iguais às do back.

**Non-Goals:**
- a folha M0 e a grade de atalhos do Início do motorista;
- Expediente, Espera no ponto, Preço, CNPJ, Editar e Ver perfil público;
- editar ou excluir um envio pendente fora do caminho "Terminar envio";
- push de decisão;
- juntar várias fotos da galeria num PDF;
- editar páginas dentro do app.

## Decisions

### D1. Módulos

- `lib/modules/driver_documents/` (R02): a situação, as listas, o detalhe, os dados e o envio.
- `lib/modules/driver_professional_data/`: a tela Dados profissionais. Ela usa, pelos contratos de domínio (R07):
  - o resumo da situação do `driver_documents`;
  - o `ChangeAcceptingStudents` do `driver_van_central`;
  - o perfil do `profile`.
- Em `lib/core/media/`: a captura do arquivo do documento (D3), que serve para qualquer módulo.
- Em `lib/core/network/`: o `PhotoUploader` vira `FileUploader`, com progresso (D7).

Alternativa descartada: pôr a tela Dados profissionais dentro de `driver_documents`. Ela tem atendimento e perfil, e a única ligação com documentos é a seção Documentos.

### D2. Contrato do back e pedidos

| Pedido | Usado em | Se atrasar |
|---|---|---|
| `GET /api/drivers/me/compliance` (situação calculada pela `DriverCompliancePolicy`, com `asOf`, requisitos do motorista e de cada van, `current`/`pending` e `expiringSoon` se vier) | todas as telas de leitura | a fase 6 implementa um datasource fictício com `TODO(VAN-86)` (R40b, R21) |
| `file` {mimeType, sizeBytes, originalName} nos DTOs e no compliance | o nome do arquivo no detalhe | o detalhe mostra "Arquivo enviado" no lugar do nome |
| limites de data com `code` estável | o erro por campo vindo do back | o app já valida antes de enviar (D6); o `detail` cai no erro genérico |
| limite de upload do Spring separado da regra de 10 MB (`MEDIA_MAX_UPLOAD_SIZE_MB`, 11) | arquivos perto de 10 MB | o 413 vira a mensagem de tamanho; a VPS não tem nginx (o Cloudflare Tunnel liga direto à API), então não há outro limite no caminho |
| `ratingCount` e `experienceYears` em `/api/drivers/me` | o topo de Dados profissionais | a linha omite o que faltar (já previsto na spec) |

Por que um endpoint agregado, e não montar a situação no app:
- sem ele, o app faz 3 + N chamadas;
- e o app copiaria as regras da policy (vencido, categoria da CNH, renovação), que divergiriam em silêncio;
- com ele, o app só deriva o que é de tela (D4).

As escritas continuam nas rotas de cada recurso.

### D3. Captura do arquivo

- **Contrato:** `DocumentCapture.capture(DocumentSource)` devolve `Result<DocumentCaptureFailure, PickedDocument?>`. O `null` significa que o motorista cancelou.
  - `PickedDocument` tem `path`, `fileName`, `mimeType`, `sizeBytes`, `pageCount?` e `pagePreviewPaths`.
  - `DocumentSource` pode ser `scanner`, `gallery` ou `pdfFile`.
- **Scanner:** `cunning_document_scanner` ^3.1.0, com `scanDocuments(output: ScanOutput.imagesAndPdf, noOfPages: 10)`. O PDF é o arquivo enviado. As imagens são só as prévias da M4 e da M5, sem biblioteca de PDF. Os arquivos são copiados do cache do plugin para uma pasta temporária do app (`path_provider`, que entra como dependência direta).
  - Alternativas descartadas: `google_mlkit_document_scanner` (só Android, em beta), `flutter_doc_scanner` (0.0.x, sem importar da galeria) e uma câmera feita à mão.
- **Galeria:** reaproveita o `ImagePickerPhotoPicker` (R06). Os 1600 px com qualidade 85 transformam HEIC em JPEG, e o back recusa HEIC.
- **PDF:** `file_picker`, na versão mais recente compatível com o SDK, com `FileType.custom` e `['pdf']`.
- **Tamanho:** uma única regra, `isWithinDocumentUploadLimit(sizeBytes)`, com o limite de 10 MB (1024 × 1024 bytes por MB), o mesmo da regra de negócio do back e do texto da tela. Hoje o back limita também a requisição inteira em 10 MB, e o cabeçalho do multipart faz um arquivo perto do limite voltar 413. O ajuste foi pedido ao back (D2). Até ele sair, esse 413 cai na mesma mensagem de tamanho (D9).
- **Configuração nativa:**
  - iOS: textos de câmera e fotos citando documentos, e `CFBundleLocalizations` com pt-BR, para o VisionKit seguir o idioma do app.
  - Android: `minSdk` 24, que já é o padrão do Flutter. A permissão `CAMERA` só entra se o teste em aparelho mostrar que precisa: a documentação do plugin se contradiz.
- **SPM:** os três plugins novos (`cunning_document_scanner`, `file_picker` e `open_filex` ^5) têm `Package.swift`. A fase 2 confirma que o build iOS não recria um Podfile.

### D4. Estado de exibição, um dono

Uma função pura, `resolveDocumentDisplayState(RequirementStatus, asOf)`, devolve `DocumentDisplayState`, na ordem da spec. Os estados possíveis são `notSent`, `incomplete`, `rejected`, `expired`, `underReview`, `renewalUnderReview`, `expiringSoon(days)` e `approved`.

Cada estado sai assim:

| Estado | De onde vem |
|---|---|
| `incomplete` | `pending ?? current` com status `PENDING` e sem `file` |
| `renewalUnderReview` | `current` aprovado e `pending` com arquivo |
| `expiringSoon` | vem do `expiringSoon` do back quando existir; senão, `current.expiresAt - asOf <= 30` dias |
| os demais | o `state` do back (`MISSING`, `PENDING`, `REJECTED`, `EXPIRED`, `APPROVED`) |

Desta função derivam (R06a):
- os grupos Pendentes e Enviados, e a ordem;
- a ação do detalhe;
- o rótulo e a cor;
- o resumo das linhas de Dados profissionais (`summarizeDocuments`).

Nenhum widget recalcula estado.

### D5. Envio em dois passos

- **Contrato:** `DocumentSubmissionRepository`, com:
  - `create(DocumentDraft)`, que devolve o token;
  - `update(token, DocumentDraft)`;
  - `uploadFile(token, kind, PickedDocument, onProgress)`;
  - `findForResume(token, kind)`;
  - `downloadFile(fileUrl)`.
  O `DocumentDraft` é sealed: `PersonalDocumentDraft`, `VehicleDocumentDraft` e `CnhDraft`. O repositório de dados escolhe a rota pelo tipo.
- **`SubmitDocument`:**
  - recebe um `SubmissionTarget`: `newSubmission` ou `existing(token)`;
  - grava os dados (`create` ou `update`) e envia o arquivo;
  - se o arquivo falhar, devolve uma falha que leva o token.
- **Cubit do fluxo:**
  - guarda o token, para que "Tentar de novo" chame só `UploadDocumentFile(token)`;
  - depois de qualquer falha no arquivo, o alvo vira `existing(token)`, inclusive em "Revisar dados".
- **"Terminar envio":** abre o fluxo com `existing(token)` e preenche o formulário pelo `findForResume`.
- **Reenviar e renovar:** sempre `newSubmission`.

Alternativa descartada: apagar o pendente sem arquivo e criar outro. Sairiam duas chamadas e um buraco, se a segunda falhar.

### D6. Regras dos campos, um dono

`DocumentFieldRules.of(DocumentType)` define:
- quais campos aparecem;
- quais são obrigatórios;
- os limites de data da spec, recebendo `asOf`.

A M5 só desenha o que as regras mandam. A validação devolve um erro por campo. Os `code` do back são traduzidos para o mesmo erro de campo por uma tabela única no data layer.

Por que o CRLV não sugere validade: ela segue o calendário de licenciamento de cada Detran, pelo final da placa. Sugerir 31/12 daria, para quase toda placa, uma validade mais longa que a real, e um CRLV vencido apareceria como válido. Calcular pela placa exigiria manter o calendário dos 27 Detrans, que muda todo ano. Por isso o campo começa vazio, com uma dica, e o admin confere na revisão (decisão do desenvolvedor, repassada pela sessão do back).

### D7. Envio do arquivo com progresso

- O `PhotoUploader` vira `FileUploader.upload(endpoint, path, fileName, {onSendProgress})`. Os chamadores de foto passam a usá-lo sem progresso (R06, R06a). Assim não fica um segundo uploader.
- `photoFailureFrom` continua para foto. Os documentos têm o seu próprio mapeamento (D9).
- O Dio já não tem `sendTimeout`, então um arquivo grande não é cortado pelo cliente.

### D8. Quem guarda a situação

- O `DriverComplianceCubit` é criado na entrada da navegação: Dados profissionais, ou "Documentos da van" na Central.
- Ele desce por `BlocProvider.value` para M1, M2, detalhe e fluxo de envio.
- O fluxo chama `refresh()` depois do sucesso, e as telas abertas refletem na hora.
- Não fica num singleton global, que vazaria entre contas depois do logout.
- Dados profissionais tem um cubit próprio para o perfil. O resumo de documentos vem do mesmo `DriverComplianceCubit` que ela entrega às telas de documentos.

### D9. Erros

`DocumentSubmissionFailure` é sealed:
- `pendingExists`;
- `alreadyReviewed`;
- `cnhNumberTaken`;
- `field(FieldKey, FieldError)`;
- `unsupportedFile`;
- `fileTooLarge`;
- `network`;
- `unexpected(detail)`.

A tabela de respostas da spec mapeia para esses casos, lendo `code` com `readProblemCode`. Os textos ficam no ARB (R10).

### D10. Abrir o arquivo

- **Imagem:** abre dentro do app, numa tela com `ApiImageProvider`, que já leva o token.
- **PDF:** é baixado pelo Dio autenticado para uma pasta temporária e aberto com `open_filex` ^5, que suporta SPM.

Alternativa descartada: `share_plus`, que já está no app. Ele abre a folha de compartilhar, e não um visualizador.

### D11. Dados profissionais

- O topo vem do `/api/drivers/me` pelo `profile`. A entidade ganha `ratingCount` e `experienceYears`, opcionais até o back entregar.
- O switch "Aceitando novos alunos" usa o `ChangeAcceptingStudents` e a mesma regra do `VanCentralCubit`. A Central recarrega ao voltar.
- "Áreas de atendimento" abre a rota que já existe, `openDriverServiceAreas`.
- Rotas novas no `app.dart`:
  - `openDriverProfessionalData`;
  - `openDriverDocuments` (pessoais);
  - `openDriverVanDocuments(van?)`.

### D12. Textos fixos

- "Sobre o documento" (o que é, quem emite, validade) e os rótulos de motivo de reprovação ficam no ARB.
- Os motivos repetem os textos de `documentRejectionOption` do `vanep-frontend`.
- Os textos do canvas que prometem prazo, e-mail e bloqueio ficam como estão (risco aceito, ver Risks).

### D13. Divergências com o canvas (decididas com o desenvolvedor)

1. **M4:** sem ferramentas por página; ações "Escanear de novo" e "Continuar".
2. **Comprovante de residência:** sai da M1.
3. **Estados novos:** Vencido, Envio incompleto e "Aprovado · nova versão em análise".
4. **CNH:** ganha formulário próprio na M5 (registro, categoria, emissão, validade e UF).
5. **Campos que vêm do back:**
   - o nome do arquivo vem do back;
   - "Placa" continua em "O que foi enviado", mas vem da própria van, sem pedido ao back;
   - saem "Exercício" do CRLV, "Concluído em" do curso e "Emitida em" da certidão: nenhuma regra usa essas datas, e elas já estão no arquivo.
6. **Âmbar:** a partir de 30 dias do vencimento, e não só nas últimas 48h.
7. **M0:** fica fora.

### Entrega fatiada (R16–R23)

Issue no Genwork: **VAN-86**. Branches empilhadas a partir de `VAN-86/spec-driver-documents`.

| Phase | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Contrato da captura em `core/media` (`DocumentCapture`, `PickedDocument`, `DocumentSource`, falhas, regra de tamanho) | — | — |
| 2 | Implementações da captura, `FileUploader`, dependências e configuração nativa | 1 | 3 |
| 3 | Modelo de `driver_documents`: value objects (`DocumentType`, estados, motivo, `DocumentFile`, `DocumentDisplayState`) e entidades abstratas | — | 2 |
| 4 | Regras de `driver_documents`: `resolveDocumentDisplayState`, agrupamento e resumo, `DocumentFieldRules` e drafts | 3 | — |
| 5 | Falhas, `SubmissionTarget`, contratos dos repositórios e use cases | 4 | — |
| 6 | Dados de `driver_documents`: DTOs, datasources, repositórios, endpoints, mapeamento de erros, container | 5 e o contrato do back (D2) | — |
| 7 | Listas: `DriverComplianceCubit`, M1, M2, vazio sem van, entrada da Central da van, rotas | 6 | — |
| 8 | Detalhe e M7, abrir o arquivo | 7, 2 | 9 |
| 9 | Fluxo de envio: cubit, M3, M4, M6 (enviando, enviado, falha) | 7, 2 | 8 |
| 10 | M5: formulários por tipo e da CNH, "Terminar envio" | 9 | 11 |
| 11 | Dados profissionais: perfil com nota, avaliações e experiência; tela; menu da conta | 7 | 10 |

As branches são empilhadas na ordem das fases, mesmo quando duas poderiam andar em paralelo, para que cada PR tenha uma base só.

A fase 3 original (domínio inteiro) foi dividida em 3, 4 e 5 antes de começar, porque passava de 10 arquivos de produção e 600 linhas (R23).

Cada fase fica abaixo de 600 linhas produtivas e 10 arquivos novos (R23). Se passar, ela é dividida antes de começar.

## Risks / Trade-offs

- **[Risco aceito] Textos sem lastro no back:**
  - "A Vanep confere em até 2 dias úteis": não há prazo no back;
  - "Você recebe a resposta aqui e por e-mail": o back só manda e-mail quando reprova, e não há push;
  - "o app bloqueia novas rotas" (vistoria vencendo): não está implementado.
  Ficam por decisão do desenvolvedor.
- **[PDF do scanner acima de 10 MB]** → a fase 2 mede no iPhone e no Android, com 2, 4 e 10 páginas, antes de fixar o `noOfPages`. A mensagem de tamanho manda escanear com menos páginas.
- **[Android sem Google Play Services]** → o plugin cai num recorte manual. Fica como limitação conhecida, testada num emulador sem Play.
- **[Permissão de câmera no Android: documentação contraditória]** → teste em aparelho na fase 2; a permissão só é declarada se for preciso.
- **[Pedidos ao back atrasados]** → a tabela da D2 diz o que fazer em cada caso. O datasource fictício leva `TODO(VAN-86)`.
- **[Dívida VAN-87]** → o `POST /api/driver-cnhs` ainda acha o motorista pelo e-mail do token. Depois de uma troca de e-mail, o envio da CNH falha até o back corrigir. O app mostra o erro genérico.
- **["Vencendo" duplicado no app]** → se o back não mandar `expiringSoon`, o app calcula com o `asOf` e a mesma janela de 30 dias. A dívida fica registrada para trocar pelo campo.
- **[Cache do scanner limpo pelo sistema]** → copiar o arquivo logo ao receber (D3).

## Migration Plan

Não há dado local para migrar. Cada fase entra atrás da tela que ainda não existe:
- os documentos só aparecem quando a fase 7 liga a Central;
- Dados profissionais só aparece quando a fase 11 liga o menu.
Para voltar atrás, basta reverter o PR da fase.

## Open Questions

- Os nomes finais dos campos pedidos ao back (`expiringSoon`, `ratingCount`, `experienceYears` e os `code` de data) chegam da sessão do back dona da pilha VAN-86. Só mudam os DTOs e a tabela de códigos. O `ratingCount` e o `experienceYears` entram na fase 11 da VAN-86 no back.
