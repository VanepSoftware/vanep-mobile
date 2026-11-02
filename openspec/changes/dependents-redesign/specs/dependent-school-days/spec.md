## Purpose

Permite ao responsável registrar, uma vez por dependente, em quais dias da semana ele tem aula e o turno escolar de cada um desses dias, conforme a grade escolar semanal do back.

## ADDED Requirements

### Requirement: Editor da grade semanal

O editor de Dias e turnos SHALL ter um cabeçalho com o botão de voltar, o título "Dias e turnos" e o primeiro nome do dependente como legenda. SHALL carregar a grade de `GET /api/dependent/{token}/school-days` e mostrar a seção "Semana" com um contador "<n> dias" (ou "1 dia"), seguida de sete linhas, de segunda a domingo.

Cada linha SHALL ter um switch de liga/desliga com o rótulo de acessibilidade "<dia>: tem aula" e o nome completo do dia. Uma linha ligada SHALL mostrar um seletor com o turno atual. Uma linha desligada SHALL mostrar "Sem aula" e o nome do dia apagado. O seletor SHALL oferecer Manhã (`MORNING`), Tarde (`AFTERNOON`), Noite (`NIGHT`) e Integral (`FULLTIME`).

Enquanto a grade carrega, o editor SHALL mostrar linhas em skeleton. Se a carga falhar, SHALL mostrar uma tela de erro com a ação de tentar de novo e nenhuma linha editável.

#### Scenario: Grade existente

- **WHEN** a grade é de segunda a sexta `AFTERNOON`
- **THEN** o contador mostra "5 dias"
- **AND** segunda a sexta aparecem ligadas com "Tarde", e sábado e domingo desligados com "Sem aula"

#### Scenario: Grade vazia

- **WHEN** o dependente não tem grade
- **THEN** todas as linhas aparecem desligadas e o contador mostra "0 dias"

### Requirement: Editar dias e turnos

Ligar um dia SHALL dar a ele o turno do dia ligado mais próximo antes dele. Quando não há dia ligado antes, SHALL usar o dia ligado mais próximo depois dele. Quando nenhum dia está ligado, SHALL usar `MORNING`. Desligar um dia SHALL descartar o turno dele. Escolher um turno no seletor SHALL mudar só aquele dia. O contador SHALL ser atualizado a cada mudança. Cada dia SHALL ter no máximo um turno.

#### Scenario: Ligar um dia depois de um dia de manhã

- **WHEN** a segunda está ligada com Manhã e o responsável liga a terça
- **THEN** a terça mostra Manhã

#### Scenario: Primeiro dia ligado

- **WHEN** todos os dias estão desligados e o responsável liga a quarta
- **THEN** a quarta mostra Manhã

#### Scenario: Integral em um dia

- **WHEN** o responsável escolhe Integral na quinta
- **THEN** só a quinta mostra Integral

### Requirement: Salvar a grade

"Salvar" SHALL ficar habilitado só quando a grade é diferente da que foi carregada. SHALL enviar `PUT /api/dependent/{token}/school-days` com `{"days": [...]}`, contendo um `{weekday, schoolShift}` por dia ligado, começando na segunda. Uma lista vazia é válida e limpa a grade. Com sucesso, o editor SHALL fechar e devolver a grade salva para quem abriu. Com falha, SHALL continuar aberto com as edições mantidas e mostrar uma mensagem de erro.

#### Scenario: Salvar cinco dias

- **WHEN** o responsável salva segunda a sexta com Manhã e Integral na quinta
- **THEN** o body da requisição tem cinco entradas, começando na segunda, com `FULLTIME` em `THURSDAY` e `MORNING` nas outras

#### Scenario: Limpar a grade

- **WHEN** o responsável desliga todos os dias e salva
- **THEN** o body da requisição é `{"days": []}`
- **AND** o detalhe mostra "Não informado" em Dias e turnos

#### Scenario: Salvamento recusado

- **WHEN** o `PUT` devolve HTTP 400
- **THEN** o editor continua aberto com as edições e mostra uma mensagem de erro
