## Purpose

Mostra ao motorista a situação de cada documento que a lei pede dele e de cada van: o que falta, o que está em análise, o que vence e o que foi reprovado e por quê. Tudo sai de uma única leitura da situação do motorista no back.

## ADDED Requirements

### Requirement: Uma leitura da situação

As telas de documentos e a seção Documentos de Dados profissionais SHALL usar a mesma leitura da situação do motorista (`GET /api/drivers/me/compliance`). Cada requisito vem com a situação calculada pelo back, o envio que vale e o envio novo. Datas e prazos SHALL ser contados a partir da data do back (`asOf`), não do relógio do aparelho. Depois de qualquer envio, a leitura SHALL ser refeita, e todas essas telas SHALL mostrar o resultado novo.

#### Scenario: Depois de um envio

- **WHEN** o motorista envia a certidão criminal e volta para Documentos pessoais
- **THEN** a certidão aparece "Em análise" sem precisar sair e entrar de novo

#### Scenario: Relógio do aparelho errado

- **WHEN** o aparelho está com a data adiantada em um mês e o back diz que a vistoria vence em 9 dias
- **THEN** o app mostra "Vence em 9 dias"

### Requirement: Situação mostrada de cada documento

Cada documento SHALL mostrar exatamente um destes estados, com ícone e texto colorido (sem pílula), escolhido nesta ordem:

| Estado | Quando | Cor |
|---|---|---|
| Não enviado | sem envio | cinza |
| Envio incompleto | o envio pendente não tem arquivo | cinza |
| Reprovado | o envio mais novo foi reprovado | vermelho |
| Vencido | o envio aprovado venceu | vermelho |
| Em análise | só há envio pendente, com arquivo | azul |
| Aprovado · nova versão em análise | há um aprovado válido e um pendente com arquivo | verde, com a segunda linha em azul |
| Vence em N dias | aprovado, vencendo em até 30 dias, sem envio novo | âmbar |
| Aprovado | aprovado e válido | verde |

"Vence em N dias" SHALL virar "Vence amanhã" com 1 dia e "Vence hoje" com 0. Um documento opcional não enviado SHALL mostrar "Opcional".

#### Scenario: Renovação em análise

- **WHEN** a CNH aprovada vale até daqui a 20 dias e o motorista já mandou a nova
- **THEN** o card mostra "Aprovado" e "Nova versão em análise", sem botão de envio

#### Scenario: Envio sem arquivo

- **WHEN** a certidão criminal tem um envio pendente sem arquivo
- **THEN** o card mostra "Envio incompleto", e não "Em análise"

#### Scenario: Vistoria vencida

- **WHEN** a vistoria aprovada venceu ontem e não há envio novo
- **THEN** o card mostra "Vencido" em vermelho

### Requirement: Documentos pessoais (M1)

A tela "Documentos pessoais" SHALL listar CNH, Curso especializado, Certidão criminal e Alvará municipal em duas seções, cada uma com a contagem:
- "Pendentes": não enviado, envio incompleto, reprovado, vencido e vence em N dias;
- "Enviados": em análise, aprovado e aprovado com nova versão em análise.

Dentro de cada seção, a ordem SHALL ser CNH, curso, certidão, alvará. Uma seção vazia SHALL ser escondida. Cada card mostra ícone, nome, estado e seta, e abre o detalhe. A tela SHALL mostrar no rodapé: "Seus documentos só são vistos pela equipe Vanep que faz a análise."

#### Scenario: Certidão reprovada e alvará não enviado

- **WHEN** a certidão foi reprovada, o alvará não foi enviado e o resto está aprovado
- **THEN** "Pendentes (2)" lista certidão e alvará, e "Enviados" lista CNH e curso

### Requirement: Documentos das vans (M2)

A tela "Documentos das vans" SHALL mostrar uma seção por van ativa, com o título "<modelo> · <placa>" e, à direita, "<n> pendentes" ou "Em dia". As vans com pendência SHALL vir primeiro. Cada seção lista CRLV, Vistoria semestral e Autorização escolar, com os mesmos cards e estados da M1, pendentes primeiro.

Aberta pela Central da van, a tela SHALL mostrar só a van selecionada, com o título "Documentos da van".

Se o motorista não tem van ativa, a tela SHALL mostrar o vazio "Cadastre sua van para enviar os documentos dela", com um botão que abre o cadastro da van.

#### Scenario: Duas vans

- **WHEN** a Sprinter tem 2 pendências e a Master está em dia
- **THEN** a Sprinter vem primeiro com "2 pendentes", e a Master depois com "Em dia"

#### Scenario: Sem van

- **WHEN** o motorista não tem van ativa
- **THEN** a tela mostra o vazio com o botão para cadastrar a van

### Requirement: Detalhe do documento

O detalhe SHALL ter o nome do documento no cabeçalho e, abaixo, "Documento pessoal" ou "<modelo> · <placa>". Depois vêm, nesta ordem:
1. O estado, com a data ao lado (aprovado em, enviado em, válida até) e uma frase quando o estado pede: em análise, vencendo, vencido, envio incompleto.
2. "O que foi enviado", só quando existe envio: o nome do arquivo, que abre o arquivo; os dados informados (número, categoria da CNH, placa da van, validade); e a data de envio. Com nova versão em análise, mostra os dois envios.
3. "Sobre o documento": o que é, quem emite e a validade típica, com textos fixos por tipo.
4. O rodapé com a ação do estado:
   - não enviado: "Enviar";
   - envio incompleto: "Terminar envio";
   - reprovado: "Reenviar";
   - vencido e vencendo: "Enviar nova versão";
   - aprovado: "Enviar versão atualizada" (botão secundário);
   - em análise e aprovado com nova versão em análise: sem ação.

#### Scenario: Em análise não tem ação

- **WHEN** o motorista abre o curso em análise
- **THEN** o detalhe mostra "Em análise", a data de envio e nenhum botão no rodapé

### Requirement: Documento reprovado (M7)

O detalhe de um documento reprovado SHALL mostrar:
- "Reprovado" e a data da decisão;
- como título, o rótulo do motivo, os mesmos do admin:
  - `ILLEGIBLE`: "Documento ilegível ou cortado";
  - `EXPIRED`: "Documento vencido";
  - `DATA_MISMATCH`: "Dados não conferem com o cadastro";
  - `WRONG_TYPE`: "Tipo de documento errado";
  - `INCOMPLETE`: "Faltam páginas, frente ou verso";
  - `OTHER`: "Outro motivo";
- a mensagem do admin, quando houver, com a marca "Mensagem da equipe Vanep";
- o aviso "O resto do seu cadastro continua valendo. Só este documento precisa ser enviado de novo.";
- "Reenviar".

#### Scenario: Reprovado por dados que não conferem

- **WHEN** o admin reprovou a certidão com `DATA_MISMATCH` e a mensagem "O nome está abreviado"
- **THEN** o título é "Dados não conferem com o cadastro" e a mensagem aparece abaixo, marcada como da equipe Vanep

### Requirement: Abrir o arquivo enviado

Tocar no nome do arquivo SHALL abrir o arquivo com o acesso do motorista: uma imagem abre dentro do app, um PDF abre no visualizador do sistema. Se não der para baixar, o app SHALL avisar sem sair da tela.

#### Scenario: Abrir o PDF da CNH

- **WHEN** o motorista toca em "cnh.pdf" no detalhe da CNH
- **THEN** o PDF abre no visualizador do sistema

### Requirement: Carregando e erro

Enquanto a situação carrega, as telas SHALL mostrar o skeleton do app. Se a leitura falhar, as telas SHALL mostrar o erro padrão com "Tentar de novo".

#### Scenario: Sem conexão

- **WHEN** a leitura da situação falha por falta de rede
- **THEN** a M1 mostra o erro padrão e "Tentar de novo" refaz a leitura
