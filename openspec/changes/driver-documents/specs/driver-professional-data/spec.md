## Purpose

A tela Dados profissionais do motorista, com o seu perfil profissional e as entradas para os documentos pessoais e das vans. Inclui também as outras entradas do app que levam aos documentos.

## ADDED Requirements

### Requirement: Abrir pelo menu da conta

O item "Dados profissionais" do menu da conta do motorista SHALL abrir a tela Dados profissionais, no lugar do item desligado de hoje. Os menus do responsável e do auxiliar SHALL NOT ganhar esse item.

#### Scenario: Abrir

- **WHEN** o motorista abre o menu da conta e toca em "Dados profissionais"
- **THEN** a tela Dados profissionais abre

### Requirement: Topo com o perfil profissional

O topo SHALL mostrar a foto (ou as iniciais), o nome e uma linha com a nota, o número de avaliações e os anos de experiência ("4,9 (32) · 8 anos de experiência"). O selo de verificado SHALL aparecer só com o cadastro aprovado. Sem avaliações, a linha SHALL omitir a nota; sem anos de experiência, SHALL omitir essa parte. O botão de editar e "Ver perfil público" SHALL abrir "Em breve".

#### Scenario: Cadastro em análise

- **WHEN** o cadastro do motorista está em análise
- **THEN** o topo mostra nome e foto sem o selo de verificado

#### Scenario: Sem avaliações

- **WHEN** o motorista ainda não tem avaliação e tem 8 anos de experiência
- **THEN** a linha mostra só "8 anos de experiência"

### Requirement: Atendimento

A seção "Atendimento" SHALL mostrar, nesta ordem:
- "Áreas de atendimento": abre a tela de áreas que já existe;
- "Expediente", "Espera no ponto" e "Preço \"a partir de\"": abrem "Em breve";
- "Aceitando novos alunos": um switch com o mesmo comportamento e a mesma regra do switch da Central da van.

Essas linhas SHALL continuar também na Central da van. As linhas mostram só o nome, sem valor.

#### Scenario: Desligar novos alunos

- **WHEN** o motorista desliga "Aceitando novos alunos" em Dados profissionais e depois abre a Central da van
- **THEN** a Central mostra o switch desligado

### Requirement: Documentos

A seção "Documentos" SHALL ter "Pessoais", que abre a M1, e "Vans", que abre a M2 com todas as vans. Cada linha SHALL mostrar um subtítulo âmbar só quando há algo a fazer:
- "<n> pendentes", contando os documentos obrigatórios não enviados, os de envio incompleto, os reprovados e os vencidos;
- senão, "Vence em <n> dias", com o vencimento mais próximo dentro de 30 dias;
- sem pendência nem vencimento próximo, a linha mostra só o nome.

#### Scenario: Certidão reprovada

- **WHEN** a certidão foi reprovada e o resto dos documentos pessoais está em dia
- **THEN** a linha "Pessoais" mostra "1 pendente" em âmbar

#### Scenario: Tudo em dia

- **WHEN** todos os documentos das vans estão aprovados e nenhum vence em 30 dias
- **THEN** a linha "Vans" mostra só o nome

### Requirement: Empresa

A seção "Empresa" SHALL mostrar "CNPJ" com o subtítulo "Opcional", e a linha SHALL abrir "Em breve". O "não informado" do canvas fica para quando o CNPJ for editável, porque o `/api/drivers/me` não traz o CNPJ.

#### Scenario: Linha do CNPJ

- **WHEN** o motorista abre Dados profissionais
- **THEN** a seção Empresa mostra "CNPJ" e "Opcional", e tocar abre "Em breve"

### Requirement: Documentos da van na Central

O item "Documentos da van" da Central da van SHALL abrir "Documentos da van" só com a van selecionada, no lugar de "Em breve". Ao voltar, a Central SHALL recarregar.

#### Scenario: Abrir pela Central

- **WHEN** o motorista está com a Master RTA3B45 selecionada e toca em "Documentos da van"
- **THEN** a tela mostra só os documentos da Master

### Requirement: Carregando e erro

A tela SHALL mostrar o skeleton do app enquanto carrega. Se o perfil falhar, SHALL mostrar o erro padrão com "Tentar de novo". Se só a situação dos documentos falhar, a tela SHALL abrir normalmente e as linhas "Pessoais" e "Vans" SHALL aparecer sem subtítulo.

#### Scenario: Situação indisponível

- **WHEN** o perfil carrega e a leitura da situação dos documentos falha
- **THEN** a tela abre e as linhas de documentos aparecem sem subtítulo
