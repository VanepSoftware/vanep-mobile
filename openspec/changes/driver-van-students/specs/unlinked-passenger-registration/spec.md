## Purpose

Deixa o motorista cadastrar um aluno que ele já transporta e cuja família ainda não está no app.

## ADDED Requirements

### Requirement: Abrir o cadastro

"Adicionar aluno" na tela Alunos SHALL abrir a página "Adicionar aluno". Salvar com sucesso SHALL fechar a página, mostrar uma confirmação e recarregar a lista e o progresso.

#### Scenario: Cadastro concluído

- **WHEN** o motorista preenche tudo e toca em "Cadastrar aluno"
- **THEN** a página fecha e o aluno aparece em "Sem família" com "Convidar"

### Requirement: Campos

A página SHALL ter:
- **Aluno:** nome;
- **Escola:** busca de escola e o turno escolar (Manhã, Tarde, Noite, Integral);
- **Embarque:** o endereço pelo CEP, com cidade, rua, número, complemento e bairro;
- **Dias e horários:** a grade de trechos por dia e um horário de embarque para cada trecho ligado, com "Aplicar a todos os dias";
- **Observações:** opcional, até 500 caracteres.

#### Scenario: Turno integral

- **WHEN** o turno escolar é Integral e o motorista liga a ida e a volta de segunda
- **THEN** o slot de ida vai com turno de operação "manhã" e o de volta com "tarde"

### Requirement: Validação

O botão SHALL validar no toque e mostrar o erro em cada campo: nome obrigatório (até 255), escola obrigatória, turno obrigatório, cidade, rua e CEP com 8 dígitos, pelo menos um trecho, horário em todo trecho ligado e observações até 500. Erro do back SHALL aparecer pelo `VanepFeedback`, sem perder o que foi preenchido. Enquanto envia, o botão SHALL ficar desativado com o carregando.

#### Scenario: Trecho sem horário

- **WHEN** o motorista liga a ida de terça e não escolhe o horário
- **THEN** a seção de horários mostra "Escolha o horário de cada trecho" e nada é enviado
