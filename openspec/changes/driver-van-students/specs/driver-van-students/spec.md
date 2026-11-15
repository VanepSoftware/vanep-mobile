## Purpose

Tela interna da Central da van que junta os alunos com família e sem família, mostra quantos já têm a família no app e mantém o convite e a junção à vista.

## ADDED Requirements

### Requirement: Abrir pela Central da van

O item "Alunos" da Central da van SHALL abrir a tela "Alunos" no lugar do "Em breve". O cabeçalho SHALL mostrar "Alunos" e, abaixo, "<modelo> · <placa>" da van selecionada, com voltar e buscar. Ao voltar, a Central SHALL recarregar.

#### Scenario: Abrir

- **WHEN** o motorista toca em "Alunos" na Central com a Sprinter SDF4E21 selecionada
- **THEN** a tela abre com "Sprinter · SDF4E21" no cabeçalho

### Requirement: Progresso de famílias no app

O card SHALL mostrar "<com família> de <total> com família no app", a porcentagem arredondada, a barra, o aviso "Sem a família no app, os pais não recebem avisos." e "Mandar link no grupo de pais". Os números SHALL vir da `occupancy`. Com total 0, o card SHALL NOT aparecer.

#### Scenario: 24 de 28

- **WHEN** a `occupancy` traz `students = 28` e `studentsWithFamily = 24`
- **THEN** o card mostra "24 de 28 com família no app" e "86%"

### Requirement: Sugestão de junção

Quando houver um aluno não vinculado com a família já entrou, o topo SHALL mostrar "É o mesmo <primeiro nome>?" e "A família <sobrenome> cadastrou <nome>, <idade> anos. Juntando, ele mantém a posição na rota.", com "Não é" e "Sim, juntar". Só a primeira sugestão pendente aparece. "Sim, juntar" SHALL pedir confirmação antes de juntar.

#### Scenario: Juntar

- **WHEN** o motorista toca em "Sim, juntar" e confirma
- **THEN** o card some, o aluno passa para "Com família" e o app mostra uma confirmação

#### Scenario: Não é

- **WHEN** o motorista toca em "Não é"
- **THEN** o card some e o aluno continua sem família, com "Convidar"

### Requirement: Filtros

O controle SHALL ter "Todos", "Com família" e "Sem família", cada um com a contagem, e começar em "Todos". Abaixo, um chip por turno presente na lista (Manhã, Tarde, Noite), todos ligados no início. Desligar um chip esconde os alunos que só têm aquele turno. O último chip ligado SHALL NOT poder ser desligado.

#### Scenario: Só a tarde

- **WHEN** o motorista desliga "Manhã"
- **THEN** só ficam os alunos com algum slot à tarde, e as contagens do controle mudam

### Requirement: Lista de alunos

Cada linha SHALL ter o avatar com as iniciais, o nome e o subtítulo e a ação da tabela D7 do design. Abaixo da lista, o texto "Alunos com família no app aparecem em "Com família", com contrato e avisos." Sem alunos no filtro, a tela SHALL mostrar o estado vazio com "Adicionar aluno".

#### Scenario: Convidar

- **WHEN** o motorista toca em "Convidar" na linha de Laura
- **THEN** a linha passa a mostrar "Convite enviado hoje" e "Reenviar"

#### Scenario: Família entrou

- **WHEN** o motorista toca na linha "Família entrou · confirmar"
- **THEN** abre a mesma confirmação de junção do card do topo

### Requirement: Busca

O botão de buscar SHALL trocar o título por um campo de busca que filtra por nome enquanto o motorista digita, sem diferenciar maiúscula, minúscula e acento. Fechar a busca limpa o texto.

#### Scenario: Buscar "rafa"

- **WHEN** o motorista digita "rafa"
- **THEN** só aparecem os alunos com "rafa" no nome

### Requirement: Estados

A carga SHALL mostrar o carregando; a falha, o `VanepErrorView` com "Tentar de novo"; puxar para baixo recarrega tudo. Falha numa ação SHALL mostrar o erro pelo `VanepFeedback` sem perder a lista.

#### Scenario: Falha na carga

- **WHEN** a lista de não vinculados falha
- **THEN** aparece o erro com "Tentar de novo"
