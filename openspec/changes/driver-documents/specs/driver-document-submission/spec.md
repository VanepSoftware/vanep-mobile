## Purpose

Leva os dados e o arquivo de cada documento do motorista e da van, e a CNH, até a revisão da Vanep. Os campos mudam com o tipo. O app repete as validações do back, e o envio em dois passos sobrevive a uma falha no arquivo.

## ADDED Requirements

### Requirement: Tela de dados do documento (M5)

A tela de dados SHALL ter o nome do documento no cabeçalho e mostrar:
- o arquivo escolhido: a miniatura da primeira página (ou um ícone de PDF), o formato, as páginas (quando o arquivo veio do scanner), o tamanho e "Trocar", que volta para "Como você quer enviar?";
- a seção "Dados do documento", com o texto "Copie do jeito que está escrito no documento." e os campos do tipo;
- para documento de van, o campo "Van" travado com "<modelo> · <placa>";
- "Enviar para análise", fixo no rodapé.

#### Scenario: Documento de van

- **WHEN** o motorista chega aos dados da vistoria da Sprinter SDF4E21
- **THEN** o campo "Van" mostra "Sprinter · SDF4E21" e não pode ser alterado

### Requirement: Campos por tipo

Cada tipo SHALL pedir só estes campos. Os opcionais SHALL ter a marca "(opcional)":

| Documento | Campos |
|---|---|
| Certidão criminal | Número (opcional), Válida até (opcional) |
| Curso especializado | Número do certificado (opcional), Válido até (opcional) |
| Alvará municipal | Número do alvará, Válido até (opcional) |
| CRLV | Válido até, Número (opcional) |
| Vistoria semestral | Número do laudo (opcional), Válida até |
| Autorização escolar | Número da autorização, Válida até |
| CNH | Número de registro, Categoria, Data de emissão, Validade, UF emissora (opcional) |

As datas SHALL usar o formato dd/mm/aaaa, digitadas ou escolhidas no calendário. "Enviar para análise" SHALL ficar ativo só com os campos obrigatórios preenchidos e válidos.

#### Scenario: Alvará sem número

- **WHEN** o motorista deixa o número do alvará em branco
- **THEN** "Enviar para análise" fica desativado

### Requirement: Limites de data

O app SHALL validar as datas antes de enviar, com as mesmas regras do back, contando "hoje" pela data do back:
- toda validade informada SHALL ser hoje ou depois, com a mensagem "Este documento já venceu. Envie a versão em dia.";
- CRLV: validade até 31/12 do ano que vem;
- vistoria: validade até hoje + 7 meses;
- autorização escolar: validade até hoje + 2 anos;
- curso: validade até hoje + 5 anos;
- certidão: sem limite de cima;
- alvará: validade até hoje + 5 anos;
- CNH: emissão até hoje; validade depois da emissão e até a emissão + 10 anos.

Uma data além do limite SHALL mostrar no campo "Confira a data: ela está longe demais.". Se o back recusar uma data por esses limites, o app SHALL mostrar o erro no campo correspondente, identificado pelo `code` da resposta.

#### Scenario: Vistoria com o ano errado

- **WHEN** o motorista digita a validade da vistoria como 24/11/2062
- **THEN** o campo mostra "Confira a data: ela está longe demais." e o envio fica desativado

### Requirement: Validade do CRLV

O CRLV não traz a validade escrita: ela segue o calendário de licenciamento do Detran de cada estado, pelo final da placa. O campo "Válido até" do CRLV SHALL começar vazio, sem data sugerida, e SHALL ter a dica "Data limite do próximo licenciamento, conforme o calendário do Detran para o final da sua placa.". O admin confere a data na revisão.

#### Scenario: Campo vazio com a dica

- **WHEN** o motorista abre os dados do CRLV
- **THEN** "Válido até" está vazio e mostra a dica do calendário do Detran

### Requirement: Categoria da CNH

O campo "Categoria" SHALL oferecer as categorias da CNH (A, B, C, D, E, AB, AC, AD, AE). Se a escolhida não tiver D nem E, o app SHALL avisar, sem bloquear o envio: "Para transporte escolar, a CNH precisa ser categoria D ou E. Esta não vai valer como credencial."

#### Scenario: CNH categoria B

- **WHEN** o motorista escolhe a categoria B
- **THEN** o aviso aparece e "Enviar para análise" continua ativo

### Requirement: Envio em dois passos

"Enviar para análise" SHALL primeiro gravar os dados e depois enviar o arquivo para o documento gravado. Durante o envio, o app SHALL mostrar "Enviando…" com o nome do documento (e a van, se for de van), a barra de progresso do arquivo, os MB enviados de MB totais e "Mantenha o app aberto até terminar.". O documento SHALL ser marcado como enviado só quando os dois passos derem certo.

#### Scenario: Envio completo

- **WHEN** os dados e o arquivo da autorização escolar são aceitos
- **THEN** o app mostra "Documento enviado"

### Requirement: Documento enviado (M6)

A tela de sucesso SHALL mostrar:
- "Documento enviado";
- o texto "A Vanep confere em até 2 dias úteis. Você recebe a resposta aqui e por e-mail.";
- "Ainda falta", com os documentos que continuam pendentes, quando houver, tirados da leitura da situação feita depois do envio;
- um botão para voltar à lista de onde o documento veio.

#### Scenario: Ainda falta a certidão

- **WHEN** o motorista envia a autorização escolar e a certidão continua reprovada
- **THEN** "Ainda falta" lista "Certidão criminal · Reprovado"

### Requirement: Falha no arquivo e "Tentar de novo"

Se os dados forem gravados e o arquivo falhar, o app SHALL mostrar "Não deu para enviar", com o texto "A conexão caiu no meio do envio. O arquivo e os dados continuam aqui, é só tentar de novo.". As ações são:
- "Tentar de novo" SHALL reenviar só o arquivo, para o mesmo documento, sem gravar os dados de novo;
- "Revisar dados" SHALL voltar à tela de dados; um novo "Enviar para análise" SHALL atualizar o mesmo documento e reenviar o arquivo.

#### Scenario: A conexão cai no arquivo

- **WHEN** os dados da certidão são gravados, o arquivo falha e o motorista toca em "Tentar de novo"
- **THEN** só o arquivo é reenviado, e nenhum documento novo é criado

### Requirement: Terminar um envio incompleto

"Terminar envio", no detalhe de um documento com envio incompleto, SHALL:
1. carregar os dados já gravados daquele envio;
2. pedir o arquivo (como enviar, conferir, dados);
3. abrir a tela de dados preenchida;
4. ao enviar, atualizar o mesmo documento e enviar o arquivo.

O app SHALL NOT criar um documento novo nesse caminho.

#### Scenario: Voltar no dia seguinte

- **WHEN** a certidão ficou sem arquivo ontem e o motorista toca em "Terminar envio"
- **THEN** a tela de dados abre com o número e as datas de ontem, e o envio completa aquele mesmo documento

### Requirement: Reenviar e renovar criam um envio novo

"Reenviar" (reprovado), "Enviar nova versão" (vencendo ou vencido) e "Enviar versão atualizada" (aprovado) SHALL criar um envio novo do mesmo tipo, e da mesma van quando for de van, com os campos vazios. O app SHALL NOT alterar um envio já revisado. Enquanto a versão nova está em análise, o aprovado continua valendo.

#### Scenario: Renovar a vistoria

- **WHEN** o motorista envia a vistoria nova com a atual vencendo em 9 dias
- **THEN** a vistoria aparece "Aprovado · nova versão em análise"

### Requirement: Erros do envio

O app SHALL tratar cada resposta de erro do envio assim:

| Resposta | Comportamento |
|---|---|
| 409 `document.submission.pending_exists` | refaz a leitura da situação, avisa "Já existe um envio deste documento em andamento." e volta ao detalhe |
| 409 `document.submission.reviewed` | refaz a leitura e avisa "Este envio já foi revisado. Confira a situação do documento." |
| 409 `driver_cnh.registration.duplicate` | erro no campo "Número de registro": "Este número de CNH já está em outro cadastro." |
| 400 com `code` de data ou de campo | erro no campo correspondente, com o texto do app para aquele `code` |
| 400 de tipo de arquivo | "Este tipo de arquivo não é aceito. Envie PDF, JPG ou PNG." |
| 413 | a mesma mensagem do tamanho máximo |
| sem resposta (rede) | "Não deu para enviar", com "Tentar de novo" |
| outro erro | o `detail` da resposta, ou a mensagem genérica do app |

#### Scenario: Outro aparelho já mandou

- **WHEN** o motorista tenta criar a CNH e já existe uma CNH pendente
- **THEN** a situação é recarregada, o aviso aparece e a CNH é mostrada com o estado atual
