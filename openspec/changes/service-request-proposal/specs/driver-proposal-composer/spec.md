## Purpose

Permite ao motorista montar uma proposta para um pedido de orçamento, ou mandar uma nova versão, com valores, parcelas, período, agenda, horários, van e condições que o back aceita.

## ADDED Requirements

### Requirement: Abrir o montar proposta

"Montar proposta" no pedido SHALL abrir a tela vazia, com o início igual ao início desejado do pedido. "Nova versão" no ajuste SHALL abrir a tela preenchida com a versão atual. O título SHALL ser "Nova proposta" com "<responsável> · <filhos>".

#### Scenario: Nova versão preenchida

- **WHEN** a versão 1 era R$ 340,/mês · 12x de 1º fev a 17 dez
- **THEN** a tela abre com esses valores, prontos para editar

### Requirement: Valores e pagamento

A tela SHALL pedir:

- o total do contrato, digitado pelo motorista, maior que zero e com pelo menos um centavo por parcela, como o back exige; abaixo disso, o erro "Pelo menos 1 centavo por parcela";
- as parcelas, de 1 a 12, e o dia de vencimento, de 1 a 28;
- o período, com o início de hoje em diante e o fim depois do início, em até 12 meses.

A tela SHALL mostrar a prévia "R$ <total ÷ parcelas>/mês · <parcelas>x", com os centavos truncados, como o back calcula. O app SHALL NOT pedir nem mandar preço por aluno: o valor combinado é só o total e as parcelas, e o desconto de irmão fica no total. Um valor fora da faixa SHALL mostrar o erro curto "De <mín> a <máx>", que cabe no campo. Comissão e "você recebe" SHALL NOT aparecer.

#### Scenario: Prévia da parcela

- **WHEN** o motorista digita total R$ 7.440 em 12 parcelas
- **THEN** a prévia mostra "R$ 620/mês · 12x"

#### Scenario: Período longo demais

- **WHEN** o período passa de 12 meses
- **THEN** a tela mostra o erro no período e não deixa enviar

### Requirement: Dias, trechos e horários

Para cada aluno, a grade "Dias e trechos" SHALL começar igual ao pedido ("Conforme o pedido") e o motorista SHALL poder desligar trechos, mas SHALL NOT ligar um trecho que a família não pediu. Cada trecho ligado SHALL ter um horário só: o embarque em casa na ida e a saída da escola na volta. Os horários SHALL aparecer numa tabela com uma linha por dia e as colunas "Ida" e "Volta", sem os rótulos "Embarque em casa" e "Saída da escola"; um trecho desligado no dia mostra "—". A tela SHALL permitir aplicar o horário do primeiro dia de cada trecho a todos os dias. O turno da rota de cada trecho SHALL ser derivado do período escolar do dia, sem perguntar ao motorista. "Chegada" e "Espera no ponto" SHALL NOT aparecer.

#### Scenario: Mesmo embarque a semana toda

- **WHEN** o motorista define o embarque de segunda às 12h05 e aplica a todos os dias
- **THEN** todas as idas ligadas ficam às 12h05

#### Scenario: Trecho que a família não pediu

- **WHEN** a família pediu quarta só ida
- **THEN** a volta de quarta não pode ser ligada

### Requirement: Van

A proposta SHALL levar uma van do motorista. Com uma van, ela SHALL ser escolhida sem perguntar. Com mais de uma, a tela SHALL mostrar um seletor. Sem nenhuma, a tela SHALL avisar e levar para o cadastro de van, e o envio SHALL ficar desativado. Numa nova versão, a van da versão anterior SHALL vir escolhida; se ela não está mais entre as vans do motorista, a tela SHALL pedir outra.

#### Scenario: Duas vans

- **WHEN** o motorista tem uma Sprinter e uma Master
- **THEN** a tela pede para escolher uma

#### Scenario: Nova versão com a van removida

- **WHEN** o motorista removeu a Master da versão 1 e abre "Nova versão"
- **THEN** a tela pede para escolher outra van

### Requirement: Condições, validade e mensagem

A tela SHALL ter a taxa de reserva (valor opcional, zero ou mais), o reajuste (Sem reajuste; IPCA na renovação), o cancelamento (Aviso de 30 dias; Aviso de 30 dias + 10% do saldo) e a mensagem opcional de até 1000 caracteres. A validade SHALL ficar numa seção própria, "Validade da proposta", depois das condições, com o campo "Dias para a família responder" (de 1 a 7, 7 por padrão) e a explicação de que a proposta vence depois desse prazo. A regra de abater a taxa da 1ª parcela SHALL NOT aparecer.

#### Scenario: Validade padrão

- **WHEN** o motorista não mexe na validade
- **THEN** a proposta vai com 7 dias

### Requirement: Envio

O rodapé SHALL mostrar a prévia da parcela, a linha "Proposta válida por n dias. Em caso de aceite, o contrato é gerado." e "Enviar proposta". O envio SHALL mandar um item por aluno do pedido. No sucesso, o app SHALL voltar para a lista de negociações, com a negociação em "Aguardando resposta". Num 409 (outra versão ou pedido encerrado), o app SHALL mostrar a mensagem do back e recarregar a negociação. Num 422 ou 400, SHALL mostrar a mensagem e manter o que foi preenchido.

#### Scenario: Primeira proposta enviada

- **WHEN** o motorista envia a proposta de um pedido novo
- **THEN** a lista mostra a negociação em "Aguardando resposta" com o valor em parcelas

#### Scenario: O pedido foi retirado enquanto ele montava

- **WHEN** o back responde 409 `proposal.request.not_open`
- **THEN** a mensagem do back aparece e a negociação é recarregada
