## Purpose

Leva o arquivo de cada documento do motorista e da van, e a CNH, até a revisão da Vanep. O motorista só manda o arquivo: quem revisa lê os dados do documento (número, categoria, emissão, validade) e os preenche na aprovação. O app não pede nem valida dado nenhum do documento.

## ADDED Requirements

### Requirement: Conferir e enviar (M5)

Depois de escolher o arquivo, pelos três jeitos de enviar, o app SHALL abrir uma única tela de conferência, com o nome do documento no cabeçalho e, embaixo dele, "<modelo> · <placa>" quando o documento é de van. Não há uma tela própria para as páginas do scanner. A tela SHALL mostrar:
- a prévia do arquivo, ocupando a maior parte da tela:
  - do scanner, as páginas num carrossel, com a posição ("1 de 2") quando há mais de uma;
  - da galeria, a foto;
  - de um PDF escolhido no celular, que não tem prévia, o ícone de PDF e "Abrir PDF", que abre o arquivo no visualizador do sistema; se não abrir, o app avisa "Não deu para abrir o arquivo.";
- tocar numa página SHALL abri-la em tela cheia, com zoom, podendo passar para as outras páginas;
- embaixo da prévia, o formato, as páginas (do scanner) e o tamanho, nunca o nome do arquivo, e "Trocar arquivo", que abre "Como você quer enviar?" (escanear de novo é escolher o scanner ali);
- "Antes de enviar, confira", com "Dá para ler tudo", "O documento aparece inteiro, sem cortes" e "Frente e verso, quando tiver";
- "Enviar para análise", fixo no rodapé, ativo sempre que há um arquivo.

A tela SHALL NOT ter campo de dados do documento, nem avisos sobre a categoria da CNH ou sobre a validade: enquanto o documento está pendente ele não tem esses dados, e o que não serve chega como motivo de recusa (ver `driver-documents`). A tela também SHALL NOT oferecer edição por página: recortar, girar e refazer acontecem dentro do scanner do sistema.

#### Scenario: Documento de van

- **WHEN** o motorista chega ao envio da vistoria da Sprinter SDF4E21
- **THEN** o cabeçalho mostra "Vistoria semestral" e, embaixo, "Sprinter · SDF4E21"

#### Scenario: Ver a segunda página

- **WHEN** o motorista escaneou duas páginas e arrasta a prévia para o lado
- **THEN** a prévia mostra a página 2 e a posição "2 de 2"

#### Scenario: Escanear de novo

- **WHEN** o motorista toca em "Trocar arquivo", escolhe o scanner e escaneia uma página só
- **THEN** a prévia mostra 1 página, e o arquivo anterior é descartado

#### Scenario: CNH sem formulário

- **WHEN** o motorista escolhe a foto da CNH
- **THEN** a tela mostra a foto, a lista do que conferir e "Enviar para análise", sem nenhum campo

### Requirement: Envio num passo só

"Enviar para análise" SHALL mandar o tipo e o arquivo numa única requisição `multipart/form-data`:
- documento pessoal: `POST /api/driver-documents` com `documentType` e `file`;
- documento de van: `POST /api/vehicles/{token}/documents` com `documentType` e `file`;
- CNH: `POST /api/driver-cnhs` só com `file`.

Durante o envio, o app SHALL mostrar "Enviando…" com o nome do documento (e a van, se for de van), a barra de progresso do arquivo, os MB enviados de MB totais e "Mantenha o app aberto até terminar.". O documento SHALL ser marcado como enviado quando o back responder 201.

#### Scenario: Envio completo

- **WHEN** o back aceita o arquivo da autorização escolar
- **THEN** o app mostra "Documento enviado"

### Requirement: Documento enviado (M6)

A tela de sucesso SHALL mostrar:
- "Documento enviado";
- o texto "A Vanep confere em até 2 dias úteis. Você recebe a resposta aqui e por e-mail.";
- "Pendências", com os documentos obrigatórios que continuam pendentes, quando houver, tirados da leitura da situação feita depois do envio. Tocar num deles SHALL fechar o fluxo de envio e abrir o detalhe (M3) daquele documento, com a van dele quando for de van; voltar do detalhe leva à lista de onde o motorista começou;
- um botão para voltar à lista de onde o documento veio.

#### Scenario: A certidão continua pendente

- **WHEN** o motorista envia a autorização escolar e a certidão continua reprovada
- **THEN** "Pendências" lista "Certidão criminal · Reprovado", e tocar nela abre o detalhe da certidão

### Requirement: Falha de rede e "Tentar de novo"

Se a requisição cair sem resposta, o app SHALL mostrar "Não deu para enviar", com o texto "A conexão caiu no meio do envio. O arquivo continua aqui, é só tentar de novo.". As ações são:
- "Tentar de novo" SHALL mandar o mesmo arquivo de novo, com o mesmo `POST`. Sem resposta, o back não gravou nada; se ele tiver gravado antes de a conexão cair, o novo `POST` recebe o 409 `pending_exists` da tabela de erros;
- "Trocar arquivo" SHALL abrir "Como você quer enviar?".

#### Scenario: A conexão cai no envio

- **WHEN** a conexão cai no envio da certidão e o motorista toca em "Tentar de novo"
- **THEN** o app manda a certidão de novo e, aceita, mostra "Documento enviado"

### Requirement: Reenviar e renovar criam um envio novo

"Reenviar" (reprovado), "Enviar nova versão" (vencendo ou vencido) e "Enviar versão atualizada" (aprovado) SHALL criar um envio novo do mesmo tipo, e da mesma van quando for de van. O app SHALL NOT alterar um envio já revisado. Enquanto a versão nova está em análise, o aprovado continua valendo.

#### Scenario: Renovar a vistoria

- **WHEN** o motorista envia a vistoria nova com a atual vencendo em 9 dias
- **THEN** a vistoria aparece "Aprovado · nova versão em análise"

### Requirement: Erros do envio

O app SHALL tratar cada resposta de erro do envio assim:

| Resposta | Comportamento |
|---|---|
| 409 `document.submission.pending_exists` | refaz a leitura da situação, avisa "Já existe um envio deste documento em andamento." e volta ao detalhe |
| 409 `document.submission.reviewed` | refaz a leitura e avisa "Este envio já foi revisado. Confira a situação do documento." |
| 400 `media.mime.not_allowed` ou `media.file.unreadable`, ou outro 400 | na tela de envio: "Este tipo de arquivo não é aceito. Envie PDF, JPG ou PNG." |
| 413, ou `media.file.too_large` | na tela de envio, a mesma mensagem do tamanho máximo |
| sem resposta (rede) | "Não deu para enviar", com "Tentar de novo" |
| outro erro | na tela de envio, o `detail` da resposta, ou a mensagem genérica do app |

#### Scenario: Outro aparelho já mandou

- **WHEN** o motorista manda a CNH e já existe uma CNH pendente
- **THEN** a situação é recarregada, o aviso aparece e a CNH é mostrada com o estado atual
