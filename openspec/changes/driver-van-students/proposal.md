## Why

A Central da van (VAN-57, canvas "Motorista → Vans · 3. Alunos da van") tem o item "Alunos", que hoje abre "Em breve". O motorista precisa ver todos os alunos que transporta numa lista só: os que já têm a família no app e os que ele mesmo cadastrou, sem família (aluno não vinculado). Os não vinculados continuam com "Convidar família" à vista (D12 do canvas) e, quando a família entra e cadastra o filho, a troca pelo dependente real pede confirmação.

O back já entrega parte disso: o CRUD do aluno não vinculado (`/api/drivers/me/unlinked-passengers`) e a contagem "n de m com família no app" (`/api/drivers/me/occupancy`). Ainda faltam no back a lista de alunos com família do motorista, o convite da família e a junção com o dependente. Por decisão do desenvolvedor, a tela sai inteira agora: liga na API o que já existe e usa dados fictícios no resto, marcados com `TODO(VAN-57)` (R40b).

## What Changes

- **Tela "Alunos"** aberta pelo item "Alunos" da Central da van, com o nome e a placa da van selecionada no cabeçalho:
  - card de progresso "n de m com família no app" vindo da API (`occupancy`), com "Mandar link no grupo de pais";
  - card "É o mesmo <nome>?" quando uma família cadastrou um filho que bate com um aluno não vinculado, com "Não é" e "Sim, juntar";
  - controle Todos / Com família / Sem família, com contagens;
  - filtro por turno (Manhã, Tarde e Noite, só os turnos que aparecem na lista), com mais de um ligado ao mesmo tempo;
  - lista de alunos. Sem família: "Convidar", "Convite enviado há n dias" com "Reenviar", ou "Família entrou · confirmar";
  - busca por nome no cabeçalho;
  - botão "Adicionar aluno".
- **Cadastro do aluno sem família**, aberto por "Adicionar aluno": nome, escola, turno escolar, endereço de embarque, dias e trechos com horário de embarque, e observações. Usa o `POST` real.
- **Dados reais:** lista e cadastro do aluno não vinculado e o progresso.
- **Dados fictícios (`TODO(VAN-57)`):** os alunos com família, o estado do convite, o convidar e reenviar, a sugestão de junção, juntar e "não é", e o link do grupo de pais. Ficam todos num único datasource fictício, que sai quando o back entregar os endpoints (ver o relatório de API em `design.md`).
- **Refatoração (R06, R06a):**
  - `RouteLeg`, `ClockTime`, `ScheduleSlot` e `OperationShift` saem de `negotiations/domain` e vão para `lib/core/domain/schedule/`, porque o aluno não vinculado usa a mesma grade;
  - sai o `OperationShift` duplicado de `driver_van_central`;
  - o editor de dias, trechos e horários do "Montar proposta" vira um widget do `core/ui` (`VanepScheduleEditor`), usado pelo composer e pelo cadastro.

## Capabilities

### New Capabilities

- `van-students-data`: leitura e cadastro do aluno não vinculado na API, e o contrato (por enquanto fictício) dos alunos com família, do convite e da junção.
- `driver-van-students`: a tela Alunos da van.
- `unlinked-passenger-registration`: o cadastro do aluno sem família.

### Modified Capabilities

Nenhuma (`openspec/specs/` está vazio). Na change `service-request-proposal`, só muda o lugar dos value objects de horário e do editor de horários. O comportamento do composer continua o mesmo.

## Impact

- **Módulo novo** `lib/modules/driver_van_students/`.
- **Alterados:**
  - `negotiations` e `driver_proposals`: imports dos value objects movidos; o composer passa a usar o `VanepScheduleEditor`;
  - `driver_van_central`: o `OperationShift` do core e o item "Alunos" abrindo a tela nova;
  - `app.dart`: rota `openDriverVanStudents`.
- **`Environment`:** `driverUnlinkedPassengersEndpoint`.
- **Localização:** textos novos em `app_pt.arb` e `app_en.arb`.
- **Dependências:** nenhuma nova. O compartilhamento do link espera o endpoint de convite (D6).
