## Purpose

Deixa o motorista produzir o arquivo de um documento (escaneado, foto da galeria ou PDF do celular) e conferir o escaneado antes de enviar. Cada documento sai com um único arquivo que o back aceita.

## ADDED Requirements

### Requirement: Escolher como enviar

Tocar na ação de envio de um documento SHALL abrir a folha "Como você quer enviar?", com o nome do documento no título e três opções nesta ordem:
- "Escanear com a câmera", com o selo "Recomendado";
- "Escolher da galeria";
- "Escolher arquivo PDF".

A folha SHALL mostrar a dica: "Documento inteiro na foto, sem reflexo e com tudo legível. PDF, JPG ou PNG de até 10 MB." Fechar a folha SHALL voltar à tela anterior sem mudar nada.

#### Scenario: Abrir a folha

- **WHEN** o motorista toca em "Enviar" na autorização escolar
- **THEN** a folha abre com "Autorização escolar" no título e as três opções

### Requirement: Escanear com a câmera

"Escanear com a câmera" SHALL abrir o scanner do sistema, que detecta as bordas, recorta e endireita cada página. Ao final, o app SHALL ter um único PDF com todas as páginas e uma imagem de cada página para mostrar na tela. O app SHALL guardar o arquivo fora do cache temporário do scanner antes de seguir. Se o motorista cancelar o scanner, o app SHALL voltar à folha sem erro.

#### Scenario: Frente e verso

- **WHEN** o motorista escaneia duas páginas e conclui
- **THEN** o app segue para a conferência do envio (M5) com um PDF de 2 páginas

#### Scenario: Cancelar o scanner

- **WHEN** o motorista fecha o scanner sem concluir
- **THEN** a folha "Como você quer enviar?" continua aberta e nenhum erro aparece

### Requirement: Escolher da galeria

"Escolher da galeria" SHALL abrir a galeria para uma única imagem. O app SHALL enviar a imagem como JPEG, inclusive quando a original é HEIC, sem juntar fotos num PDF. Depois de escolher, o app SHALL ir direto para a conferência do envio (M5), sem passar pela conferência.

#### Scenario: Foto do iPhone

- **WHEN** o motorista escolhe uma foto HEIC da galeria
- **THEN** o arquivo enviado é um JPEG

### Requirement: Escolher arquivo PDF

"Escolher arquivo PDF" SHALL abrir o seletor de arquivos do sistema mostrando só PDFs. Depois de escolher, o app SHALL ir direto para a conferência do envio (M5).

#### Scenario: CRLV digital

- **WHEN** o motorista escolhe o PDF do CRLV-e baixado do aplicativo do governo
- **THEN** o app abre a conferência do envio com esse PDF

### Requirement: Tamanho máximo

O app SHALL recusar, antes de qualquer envio, um arquivo acima de 10 MB (1 MB = 1024 × 1024 bytes, como no back), com a mensagem "O arquivo passou de 10 MB. Escaneie de novo com menos páginas ou escolha um arquivo menor." O motorista SHALL continuar na folha para escolher outro arquivo.

#### Scenario: PDF grande demais

- **WHEN** o motorista escolhe um PDF de 12 MB
- **THEN** a mensagem aparece e nada é enviado

### Requirement: Permissão negada

Se a câmera ou a galeria for negada, o app SHALL avisar que a permissão é necessária, e o motorista SHALL poder escolher outro jeito de enviar.

#### Scenario: Câmera negada

- **WHEN** o motorista nega a permissão da câmera ao escanear
- **THEN** o app mostra o aviso e a folha continua aberta com as três opções
