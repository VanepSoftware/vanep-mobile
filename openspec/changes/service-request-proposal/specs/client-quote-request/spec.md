## Purpose

Permite ao responsável pedir orçamento a um motorista para um ou mais filhos, dizendo em quais dias precisa de ida e de volta, só quando o cadastro já tem tudo o que o contrato vai precisar.

## ADDED Requirements

### Requirement: Entradas do pedido de orçamento

O card de motorista da busca (Vans · 1) e o perfil do motorista SHALL ter o botão "Pedir orçamento" (no perfil, no lugar do "Conversar com o motorista", spec `negotiation-chat`), que abre a tela Pedir orçamento daquele motorista. No perfil de um motorista com `available = false`, o botão SHALL aparecer desativado com o aviso de que ele não está aceitando novos alunos. O card da busca SHALL mostrar o preço base como "a partir de R$ X", sem parcelas.

#### Scenario: Motorista que não aceita alunos

- **WHEN** o responsável abre o perfil de um motorista com `available = false`
- **THEN** "Pedir orçamento" está desativado e o aviso aparece

### Requirement: Cabeçalho do motorista

A tela SHALL mostrar o nome do motorista, a nota quando houver, e o modelo, o ano e a capacidade da primeira van do perfil. Ocupação e vagas por turno SHALL NOT aparecer.

#### Scenario: Motorista sem avaliação

- **WHEN** o motorista ainda não tem nota
- **THEN** o cabeçalho mostra o nome e a van, sem nota

### Requirement: Escolha dos alunos com a prontidão

A tela SHALL listar todos os dependentes do responsável com uma caixa de marcar. O app SHALL consultar a prontidão contratual com os tokens de todos eles. Um dependente com alguma lacuna SHALL aparecer desativado, com "Cadastro incompleto" e o link "Completar", que abre o wizard de dependente no modo de completar e, ao voltar, consulta a prontidão de novo. Lacunas do próprio responsável (CPF, telefone, endereço) SHALL aparecer num aviso acima do botão de envio, com o que falta, e SHALL desativar o envio. O envio SHALL exigir pelo menos um aluno marcado.

#### Scenario: Um filho pronto e outro incompleto

- **WHEN** Bia está pronta e Davi não tem escola
- **THEN** Bia pode ser marcada e Davi aparece desativado com "Completar"

#### Scenario: Responsável sem telefone

- **WHEN** a prontidão aponta `{subject: CLIENT, field: PHONE}`
- **THEN** o aviso diz que falta o telefone e "Enviar pedido" fica desativado

### Requirement: Dias e trechos por filho

Para cada aluno marcado, a tela SHALL mostrar uma grade "Dias e trechos" com uma coluna por dia que tem aula na grade escolar dele e duas linhas, Ida e Volta, todas ligadas no início. Sábado e domingo SHALL aparecer só se a grade tiver esses dias. Um dia com Ida e Volta desligadas SHALL NOT ser enviado. Cada aluno marcado SHALL ter pelo menos um trecho ligado para o envio ficar disponível.

#### Scenario: Quarta só ida

- **WHEN** o responsável desliga a Volta de quarta para a Bia
- **THEN** o pedido leva quarta com `needsOutbound = true` e `needsReturn = false`

#### Scenario: Dia sem aula

- **WHEN** a grade da Bia não tem sábado
- **THEN** a grade dela não mostra sábado

### Requirement: Trajeto, início e mensagem

A tela SHALL mostrar o trajeto como dois pontos ligados por uma linha: o embarque (casa, com o endereço do dependente inteiro, quebrando linha quando não cabe, sem reticências, e o bairro e a cidade abaixo) e o destino (escola, com o nome dela e o bairro e a cidade abaixo) e o destino (escola dele), sem aviso de privacidade. O início desejado SHALL ser obrigatório e de hoje em diante. A mensagem SHALL ser opcional, com até 1000 caracteres.

#### Scenario: Data no passado

- **WHEN** o responsável tenta escolher uma data anterior a hoje
- **THEN** a data não pode ser escolhida

### Requirement: Limite de pedidos abertos

O rodapé SHALL mostrar "Resposta em até 72 h", sem a contagem de pedidos abertos. O app SHALL contar as negociações `OPEN` e `ANSWERED` do responsável e, com 5 abertas, o envio SHALL ficar desativado e o rodapé SHALL dizer que o limite foi atingido.

#### Scenario: Quinto pedido

- **WHEN** o responsável tem 4 negociações abertas
- **THEN** o rodapé mostra só "Resposta em até 72 h" e o envio está disponível

### Requirement: Envio

"Enviar pedido" SHALL mandar o motorista, o início, a mensagem e, por aluno, os dias com os trechos. O app SHALL NOT mandar período escolar, horário nem turno da rota. No sucesso, a tela SHALL ser substituída pela lista de propostas, com o pedido em "Aguardando resposta". Num 409 de pedido já aberto com esse motorista, o app SHALL mostrar a mensagem do back e oferecer abrir a negociação existente. Nos outros erros, SHALL seguir a regra de erros da `negotiation-data`.

#### Scenario: Pedido enviado

- **WHEN** o responsável envia um pedido para Bia, seg a sex, ida e volta
- **THEN** a lista de propostas abre com o pedido para o Carlos em "Aguardando resposta"

#### Scenario: Já existe pedido com esse motorista

- **WHEN** o back responde 409 `service_request.open_exists`
- **THEN** a mensagem do back aparece com a ação de abrir a negociação existente
