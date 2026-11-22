## Context

- **Design:** canvas "Vanep — Início, Vans e Propostas", página Motorista:
  - M1 a M7 e os detalhes `mob-doc-*`;
  - "Conta · Dados profissionais";
  - as notas `s-moto-docs`, `s-moto-docs-det` e `s-moto-conta`.
  As specs desta change prevalecem onde divergem do canvas (D13).
- **Back (vanep-api-java, change `driver-credentials-review`, branches `VAN-86/*`):**
  - documentos da pessoa: `/api/driver-documents`, com os tipos `CRIMINAL_RECORD`, `SCHOOL_DRIVER_COURSE` e `MUNICIPAL_AUTHORIZATION`;
  - documentos da van: `POST/GET /api/vehicles/{token}/documents` e `/api/vehicle-documents/{token}`, com os tipos `CRLV`, `VEHICLE_INSPECTION` e `SCHOOL_VEHICLE_AUTHORIZATION`;
  - CNH: `/api/driver-cnhs`;
  - o motorista manda só o arquivo: cada `POST` de criação é `multipart/form-data` com `documentType` e `file` (a CNH, só `file`); JPEG, PNG, WebP ou PDF, com o tipo descoberto pelo conteúdo. Não há `PUT` de dados: quem revisa preenche número, validade e, na CNH, registro, categoria e emissão, na aprovação;
  - um envio revisado não muda mais (409 `document.submission.reviewed`); renovar é um envio novo; só há um pendente por dono e tipo (409 `document.submission.pending_exists`);
  - erros com `code` estável no ProblemDetail;
  - recusa com código estruturado, inclusive `NOT_ELIGIBLE` para o documento que não serve ao transporte escolar (a CNH sem D ou E);
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
- o envio num passo só, só com o arquivo, que sobrevive a uma queda de rede (D5).

**Non-Goals:**
- a folha M0 e a grade de atalhos do Início do motorista;
- Expediente, Espera no ponto, Preço, CNPJ, Editar e Ver perfil público;
- trocar o arquivo ou excluir um envio pendente (o back aceita o `POST …/{token}/file` enquanto pendente; o app não oferece);
- push de decisão;
- juntar várias fotos da galeria num PDF;
- editar páginas dentro do app.

## Decisions

### D1. Módulos

- `lib/modules/driver_documents/` (R02): a situação, as listas, o detalhe e o envio.
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
| `file` {mimeType, sizeBytes, originalName} nos DTOs e no compliance | abrir o arquivo como imagem ou PDF e o nome ao salvar | nenhum: o detalhe mostra "Ver arquivo" com o ícone de olho, nunca o nome |
| limite de upload do Spring separado da regra de 10 MB (`MEDIA_MAX_UPLOAD_SIZE_MB`, 11) | arquivos perto de 10 MB | o 413 vira a mensagem de tamanho; a VPS não tem nginx (o Cloudflare Tunnel liga direto à API), então não há outro limite no caminho |
| `ratingCount` e `experienceYears` em `/api/drivers/me` | o topo de Dados profissionais | a linha omite o que faltar (já previsto na spec) |

Por que um endpoint agregado, e não montar a situação no app:
- sem ele, o app faz 3 + N chamadas;
- e o app copiaria as regras da policy (vencido, renovação), que divergiriam em silêncio;
- com ele, o app só deriva o que é de tela (D4).

As escritas continuam nas rotas de cada recurso.

### D3. Captura do arquivo

- **Contrato:** `DocumentCapture.capture(DocumentSource)` devolve `Result<DocumentCaptureFailure, PickedDocument?>`. O `null` significa que o motorista cancelou.
  - `PickedDocument` tem `path`, `fileName`, `mimeType`, `sizeBytes`, `pageCount?` e `pagePreviewPaths`.
  - `DocumentSource` pode ser `scanner`, `gallery` ou `pdfFile`.
- **Scanner:** `cunning_document_scanner` ^3.1.0, com `scanDocuments(output: ScanOutput.imagesAndPdf, noOfPages: 10)`. O PDF é o arquivo enviado. As imagens são só as prévias da M5, sem biblioteca de PDF. Os arquivos são copiados do cache do plugin para uma pasta temporária do app (`path_provider`, que entra como dependência direta).
  - Alternativas descartadas: `google_mlkit_document_scanner` (só Android, em beta), `flutter_doc_scanner` (0.0.x, sem importar da galeria) e uma câmera feita à mão.
- **Galeria:** reaproveita o `ImagePickerPhotoPicker` (R06). Os 1600 px com qualidade 85 transformam HEIC em JPEG, e o back recusa HEIC.
- **PDF:** `file_picker`, na versão mais recente compatível com o SDK, com `FileType.custom` e `['pdf']`.
- **Tamanho:** uma única regra, `isWithinDocumentUploadLimit(sizeBytes)`, com o limite de 10 MB (1024 × 1024 bytes por MB), o mesmo da regra de negócio do back e do texto da tela. O back separou o limite de transporte (`MEDIA_MAX_UPLOAD_SIZE_MB`, padrão 11) da regra de 10 MB: um PDF de 9,9 MB passa, e acima de 10 MB volta 413 com `code` `media.file.too_large`, que cai na mesma mensagem de tamanho (D9).
- **Configuração nativa:**
  - iOS: textos de câmera e fotos citando documentos, e `CFBundleLocalizations` com pt-BR, para o VisionKit seguir o idioma do app.
  - Android: `minSdk` 24, que já é o padrão do Flutter. A permissão `CAMERA` só entra se o teste em aparelho mostrar que precisa: a documentação do plugin se contradiz.
- **SPM:** os três plugins novos (`cunning_document_scanner`, `file_picker` e `open_filex` ^5) têm `Package.swift`. A fase 2 confirma que o build iOS não recria um Podfile.

### D4. Estado de exibição, um dono

Uma função pura, `resolveDocumentDisplayState(RequirementStatus, asOf)`, devolve `DocumentDisplayState`, na ordem da spec. Os estados possíveis são `notSent`, `rejected`, `expired`, `underReview`, `renewalUnderReview`, `expiringSoon(days)` e `approved`.

Cada estado sai assim:

| Estado | De onde vem |
|---|---|
| `renewalUnderReview` | `current` aprovado e um `pending` |
| `expiringSoon` | vem do `expiringSoon` do back quando existir; senão, `current.expiresAt - asOf <= 30` dias |
| os demais | o `state` do back (`MISSING`, `PENDING`, `REJECTED`, `EXPIRED`, `APPROVED`) |

Desta função derivam (R06a):
- os grupos Pendentes e Enviados, e a ordem;
- a ação do detalhe;
- o rótulo e a cor;
- o resumo das linhas de Dados profissionais (`summarizeDocuments`).

Nenhum widget recalcula estado.

### D5. Envio num passo só

- **Contrato:** `DocumentSubmissionRepository`, com:
  - `send(DocumentUpload, onProgress)`, que devolve o token do envio criado;
  - `downloadFile(fileUrl)`.
  O `DocumentUpload` leva o tipo, o arquivo e, no documento de van, o token da van. O datasource escolhe a rota pelo `DocumentKind` e manda `documentType` quando o tipo tem nome de documento (a CNH não tem).
- **`SubmitDocument`:** repassa o `DocumentUpload` ao repositório.
- **Cubit do fluxo:**
  - "Enviar para análise" e "Tentar de novo" chamam o mesmo `submit()`;
  - sem resposta, o passo vira `failed`; o 409 `pending_exists` ou `reviewed` sai do fluxo; qualquer outra recusa volta à M5 com a mensagem;
  - um arquivo novo, escolhido depois de uma falha, limpa a falha.
- **Reenviar e renovar:** sempre um envio novo.

Por que "Tentar de novo" pode repetir o `POST`: sem resposta, o mais comum é o back não ter gravado nada. Se ele gravou e a resposta se perdeu, o segundo `POST` recebe o 409 `pending_exists`, e o app recarrega a situação, que já mostra o envio em análise.

### D6. Sem dados digitados (mudança de contrato de 2026-11-22)

Até 2026-11-21 o motorista digitava, na M5, o número, a validade e, na CNH, registro, categoria, emissão e UF, e o app repetia os limites de data e a lista de categorias do back. O back passou a pedir só o arquivo, e o revisor preenche esses dados olhando o arquivo (D2 do back). Por isso saíram:
- os formulários por tipo e da CNH, as `DocumentFieldRules`, os drafts e os erros de campo;
- o envio em dois passos, o estado "Envio incompleto" e "Terminar envio";
- os avisos de categoria da CNH e de documento vencido antes da revisão: a CNH pendente não tem categoria nem validade, e o que não serve chega como recusa (`NOT_ELIGIBLE`, `EXPIRED`).

A dica do calendário do Detran no CRLV também saiu: quem preenche a validade agora é o revisor.

### D7. Envio do arquivo com progresso

- O `PhotoUploader` vira `FileUploader.upload(endpoint, path, fileName, {onSendProgress})`. Os chamadores de foto passam a usá-lo sem progresso (R06, R06a). Assim não fica um segundo uploader.
- `FileUploader.createWithFile(endpoint, path, fileName, {fields, onSendProgress})` monta o mesmo multipart com campos extras e devolve o corpo da resposta, para o `POST` de criação dos documentos (D5).
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

1. **M4 juntada à M5:** uma tela de conferência só, para os três jeitos de enviar, com a prévia do arquivo (carrossel das páginas, foto ou "Abrir PDF"), tela cheia com zoom, "Trocar arquivo" e a lista do que conferir. Sem ferramentas por página (decisão do desenvolvedor em 2026-11-22: a M5 sem campos ficou vazia, e a M4 virava uma segunda conferência seguida).
2. **Comprovante de residência:** sai da M1.
3. **Estados novos:** Vencido e "Aprovado · nova versão em análise".
4. **M5 sem campos:** a tela de dados do canvas vira a conferência do arquivo antes do envio (D6). O motorista não digita nada, nem na CNH.
5. **"O que foi enviado":**
   - o nome do arquivo nunca aparece: a linha mostra "Ver arquivo";
   - "Placa" vem da própria van, sem pedido ao back;
   - número, categoria e validade só aparecem depois da aprovação, preenchidos pelo revisor.
6. **Âmbar:** a partir de 30 dias do vencimento, e não só nas últimas 48h.
7. **M0:** fica fora.

### Entrega fatiada (R16–R23)

Issue no Genwork: **VAN-86**. Branches empilhadas a partir de `VAN-86/spec-driver-documents`.

| Phase | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Contrato da captura em `core/media` (`DocumentCapture`, `PickedDocument`, `DocumentSource`, falhas, regra de tamanho) | — | — |
| 2 | Implementações da captura, `FileUploader`, dependências e configuração nativa | 1 | 3 |
| 3 | Modelo de `driver_documents`: value objects (`DocumentType`, estados, motivo, `DocumentFile`, `DocumentDisplayState`) e entidades abstratas | — | 2 |
| 4 | Regras de `driver_documents`: `resolveDocumentDisplayState`, agrupamento e resumo | 3 | — |
| 5 | Falhas, `DocumentUpload`, contratos dos repositórios e use cases | 4 | — |
| 6 | Dados de `driver_documents`: DTOs, datasources, repositórios, endpoints, mapeamento de erros, container | 5 e o contrato do back (D2) | — |
| 7 | Listas: `DriverComplianceCubit`, M1, M2, vazio sem van, entrada da Central da van, rotas | 6 | — |
| 8 | Detalhe e M7, abrir o arquivo | 7, 2 | 9 |
| 9 | Fluxo de envio: cubit, M3, M4, M6 (enviando, enviado, falha) | 7, 2 | 8 |
| 10 | M5: conferência do arquivo e envio (até 2026-11-21: formulários por tipo e da CNH e "Terminar envio", ver D6) | 9 | 11 |
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
- **[Dívida VAN-87]** → o `POST /api/driver-cnhs` ainda acha o motorista pelo e-mail do token (os documentos já usam o `uid`). Depois de uma troca de e-mail, o envio da CNH falha até o back corrigir. O app mostra o erro genérico.
- **["Tentar de novo" depois de um envio que chegou]** → o segundo `POST` recebe 409 `pending_exists`, e o app recarrega a situação (D5).
- **["Vencendo" duplicado no app]** → se o back não mandar `expiringSoon`, o app calcula com o `asOf` e a mesma janela de 30 dias. A dívida fica registrada para trocar pelo campo.
- **[Cache do scanner limpo pelo sistema]** → copiar o arquivo logo ao receber (D3).

## Migration Plan

Não há dado local para migrar. Cada fase entra atrás da tela que ainda não existe:
- os documentos só aparecem quando a fase 7 liga a Central;
- Dados profissionais só aparece quando a fase 11 liga o menu.
Para voltar atrás, basta reverter o PR da fase.

## Open Questions

Nenhuma. O back fechou o contrato em 2026-11-20 e o mudou em 2026-11-22 para o envio só com o arquivo (branches `VAN-86/*` do `vanep-api-java`):
- `GET /api/drivers/me/compliance` com `asOf`, `approvalStatus`, requisitos com `expiringSoon` sempre presente e envios com `kind`, `file` e, na CNH, `category`, `issueDate` e `registrationNumber`;
- `file {mimeType, sizeBytes, originalName}` nos três recursos;
- os códigos do arquivo `media.file.too_large`, `media.mime.not_allowed` e `media.file.unreadable`; os códigos de data só existem na aprovação, do lado do admin;
- `ratingCount` e `experienceYears` no `/api/drivers/me`.
O limite de upload separado (`MEDIA_MAX_UPLOAD_SIZE_MB`, padrão 11) entrou na fase 11 da VAN-86 do back (D3).
