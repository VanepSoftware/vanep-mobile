## Purpose

Guia o responsável por todos os dados que um dependente precisa para um contrato, tanto ao adicionar um dependente novo quanto ao completar um que tem dados faltando, sem obrigar nenhum passo além do primeiro.

## ADDED Requirements

### Requirement: Sequência de criação

"Adicionar dependente" SHALL abrir um wizard de quatro passos, nesta ordem: Dados pessoais, Escola, Dias e turnos, Embarque. Cada passo SHALL reaproveitar o editor correspondente (`dependent-personal-data`, `dependent-school`, `dependent-school-days`, `dependent-pickup`), com os mesmos campos e a mesma validação. O cabeçalho SHALL mostrar o título do passo e a legenda "Passo <n> de <total>".

O primeiro passo SHALL criar o dependente por `POST /api/dependent`, e o botão principal dele SHALL ser "Continuar". Ele SHALL NOT ter a opção de pular, porque o nome é obrigatório. Os passos 2 a 4 SHALL salvar no dependente criado exatamente como os editores deles salvam. O botão principal desses passos SHALL ser "Continuar" ("Concluir" no último), e eles SHALL oferecer "Pular", que avança sem salvar. Se o salvamento de um passo falhar, o wizard SHALL continuar naquele passo com o que foi digitado.

#### Scenario: Criação completa

- **WHEN** o responsável preenche os quatro passos e toca em "Concluir"
- **THEN** o dependente é criado com dados pessoais, escola, grade e endereço
- **AND** o detalhe do dependente novo abre

#### Scenario: Pular os passos opcionais

- **WHEN** o responsável preenche Dados pessoais e toca em "Pular" nos outros três passos
- **THEN** o dependente existe só com os dados pessoais
- **AND** o detalhe dele abre com o card "Cadastro incompleto"

#### Scenario: A criação falha

- **WHEN** `POST /api/dependent` falha no primeiro passo
- **THEN** o wizard continua em Dados pessoais com o que foi digitado e mostra uma mensagem de erro

### Requirement: Sair do wizard

Voltar do primeiro passo SHALL fechar o wizard sem criar nada. Voltar de um passo seguinte SHALL encerrar o wizard e abrir o detalhe do dependente criado, porque ele já existe. Quando o wizard termina, o detalhe do dependente SHALL substituir o wizard na pilha, de forma que voltar desse detalhe leva à lista. A lista SHALL então incluir o dependente novo.

#### Scenario: Voltar no primeiro passo

- **WHEN** o responsável volta de Dados pessoais sem salvar
- **THEN** a lista aparece e nenhum dependente foi criado

#### Scenario: Voltar depois da criação

- **WHEN** o responsável volta do passo Escola
- **THEN** o detalhe do dependente novo abre
- **AND** voltar dele mostra a lista com o dependente novo

### Requirement: Modo de completar

"Completar cadastro" no detalhe SHALL abrir o mesmo wizard só com os passos cujos itens de prontidão estão faltando, na ordem da criação. `BIRTH_DATE` corresponde a Dados pessoais, `SCHOOL` a Escola, `SCHOOL_DAYS` a Dias e turnos e `ADDRESS` a Embarque. Todo passo no modo de completar SHALL editar o dependente existente e oferecer "Pular". A contagem na legenda SHALL considerar só esses passos. Quando o wizard termina, ou o responsável volta de qualquer passo, o app SHALL voltar ao detalhe com os dados e a prontidão atualizados.

#### Scenario: Dois itens faltando

- **WHEN** o responsável toca em "Completar cadastro" num dependente sem `SCHOOL` e sem `SCHOOL_DAYS`
- **THEN** o wizard mostra Escola como "Passo 1 de 2" e depois Dias e turnos como "Passo 2 de 2"

#### Scenario: Completar tudo

- **WHEN** o responsável salva os dois passos que faltavam
- **THEN** o detalhe abre sem o card "Cadastro incompleto"
