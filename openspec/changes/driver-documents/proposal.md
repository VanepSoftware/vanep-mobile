## Why

O motorista só é aprovado, e só pode oferecer uma van, quando tem os documentos que o CTB exige aprovados pela Vanep (arts. 136, 138 e 329): CNH categoria D ou E, curso especializado e certidão criminal, além de CRLV, vistoria e autorização escolar de cada van. O back já tem essa parte pronta na change `vehicle-documents` (VAN-86): documentos da pessoa, documentos da van, CNH revisada, revisão do admin e situação do motorista. O app ainda não envia nada: a CNH não existe no app, "Documentos da van" na Central abre "Em breve" e "Dados profissionais" está desligado no menu da conta.

Esta change leva para o app o envio e o acompanhamento desses documentos, e a tela Dados profissionais que dá acesso a eles. Ela segue o canvas "Vanep — Início, Vans e Propostas" (página Motorista, telas M1 a M7, detalhes por documento e "Conta · Dados profissionais"), com as correções combinadas com o desenvolvedor.

## What Changes

- **Captura do arquivo:** três jeitos de enviar, cada um gerando um arquivo por documento:
  - escanear com a câmera, pelo scanner do sistema, que recorta e endireita a página e junta as páginas num PDF;
  - escolher uma foto da galeria (uma imagem);
  - escolher um PDF salvo no celular.
  O app recusa arquivos acima de 10 MB antes de enviar.
- **Conferir o escaneado (M4, simplificada):** o motorista vê as páginas e pode escanear de novo ou continuar. Os ajustes por página (recortar, girar, refazer, excluir) acontecem dentro do scanner do sistema. A M4 só aparece no caminho do scanner.
- **Documentos pessoais (M1):** CNH, curso especializado, certidão criminal e alvará municipal (opcional). Os pendentes vêm primeiro, depois os enviados. **O comprovante de residência sai do canvas**, porque o back removeu esse tipo (LGPD).
- **Documentos das vans (M2):** uma seção por van com CRLV, vistoria e autorização escolar. A van com pendência vem primeiro. Se o motorista não tem van, aparece um estado vazio que leva ao cadastro da van.
- **Situação de cada documento:** além dos estados do canvas (não enviado, em análise, aprovado, vence em N dias, reprovado), entram três:
  - **Vencido**;
  - **Envio incompleto** (os dados foram criados, mas o arquivo não chegou);
  - **"Aprovado · nova versão em análise"**.
  "Vencendo" começa a 30 dias do vencimento, como no back e no admin.
- **Detalhe do documento:** status, o que foi enviado (incluindo o nome do arquivo) e "Sobre o documento". A ação depende do estado. O documento reprovado (M7) mostra o motivo, com os rótulos do admin.
- **Dados do documento (M5):** os campos mudam conforme o tipo, e a CNH ganha um formulário próprio. O app repete as validações de data do back. No CRLV, o motorista informa a validade com a ajuda de uma dica sobre o calendário do Detran.
- **Envio em dois passos:** primeiro os dados, depois o arquivo. "Tentar de novo" reenvia só o arquivo. Reenviar um documento reprovado ou renovar um aprovado cria um envio novo; nunca edita o anterior.
- **Dados profissionais (tela nova):**
  - topo: foto, nome, selo de verificado (só com o cadastro aprovado), nota, número de avaliações e anos de experiência;
  - seção Documentos: Pessoais e Vans, com aviso âmbar quando algo falta ou vence;
  - "Aceitando novos alunos" e "Áreas de atendimento" repetidos da Central da van, onde continuam;
  - Expediente, Espera no ponto, Preço, CNPJ, Editar e Ver perfil público aparecem como "Em breve".
- **Entradas:**
  - o item "Dados profissionais" do menu da conta passa a funcionar;
  - "Documentos da van", na Central da van, abre a M2 só com aquela van.
- **Fora desta change:**
  - a folha M0 (atalho Documentos do Início), que espera a grade de atalhos do motorista;
  - o resto da tela Dados profissionais.

## Capabilities

### New Capabilities

- `document-capture`: escolher ou escanear o arquivo de um documento e conferir o escaneado.
- `driver-documents`: a situação dos documentos do motorista e de cada van, as listas e o detalhe.
- `driver-document-submission`: os dados de cada tipo de documento e da CNH, as validações e o envio em dois passos, com novo envio, retomada e erros.
- `driver-professional-data`: a tela Dados profissionais e as entradas para os documentos.

### Modified Capabilities

Nenhuma (`openspec/specs/` está vazio).

## Impact

- **Back (vanep-api-java, VAN-86):** usa o contrato da change `vehicle-documents` e depende de pedidos feitos ao back em 2026-11-20 (lista no `design.md`, D2):
  - `GET /api/drivers/me/compliance`;
  - expor o arquivo (`file`) nos DTOs;
  - limites de data com `code` estável;
  - `ratingCount` e `experienceYears` no `/api/drivers/me`.
- **Módulos novos:** `lib/modules/driver_documents/` e `lib/modules/driver_professional_data/`.
- **Core:** captura de documento em `lib/core/media/`; o envio de arquivo com progresso em `lib/core/network/`, generalizando o `PhotoUploader`.
- **Alterados:**
  - `auth` (menu da conta);
  - `driver_van_central` (entrada dos documentos da van);
  - `profile` (nota, avaliações e experiência do motorista);
  - `app.dart` (rotas).
- **Dependências novas:** `cunning_document_scanner` e `file_picker`.
- **Configuração nativa:**
  - iOS: textos de câmera e fotos citando documentos, e `CFBundleLocalizations` com pt-BR;
  - Android: a permissão de câmera só se o teste em aparelho exigir.
- **Localização:** textos novos em `app_pt.arb` e `app_en.arb`.
- **Canvas:** fica divergente em 5 pontos até ser atualizado (a M4, o comprovante de residência, os três estados novos, o formulário da CNH e os campos que saem: "Concluído em" do curso e "Exercício" do CRLV). As decisões estão no `design.md`.
- **Genwork:** VAN-86.
