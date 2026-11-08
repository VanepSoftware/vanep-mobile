## Purpose

Mostra ao responsável a proposta de um motorista com tudo o que foi oferecido e a história da negociação, e deixa ele aceitar, recusar ou pedir ajuste na versão vigente.

## ADDED Requirements

### Requirement: Detalhe da proposta

O detalhe SHALL abrir pela proposta e mostrar, de cima para baixo:

- o cabeçalho "Proposta" com "Para <filhos>" e o botão de conversa;
- o motorista: nome, nota quando houver, e o veículo da proposta ("Master 2019 · 15 lugares"), sem selo de verificado, que o back não tem;
- o card de valor: "VERSÃO n" e o selo "Expira em dd/mm" no topo (em âmbar quando faltam até 2 dias), a parcela em destaque com a quantidade ("R$ 300/mês · 12x") e "R$ X no total";
- "Aluno": por filho, nome, idade, escola e turno, sem aviso de privacidade;
- "Dias e trechos": a grade da proposta;
- "Horários": uma linha por trecho, com ícone, "Ida" e "Embarque em casa" (horário do embarque) ou "Volta" e "Saída da escola" (horário da volta), e o horário à direita. Quando os horários mudam entre os dias, uma linha por dia abaixo do trecho;
- "Condições": período ("1 fev a 17 dez 2027", com o ano só no fim quando é o mesmo), vencimento ("Dia n"), taxa de reserva (só o valor, e só quando houver), reajuste e cancelamento;
- a mensagem do motorista, quando houver;
- "Histórico" (próximo requisito);
- a linha "Em caso de aceite, o contrato é gerado para revisão e assinatura.".

"Chegada à escola" e "Espera no ponto" SHALL NOT aparecer.

#### Scenario: Horário de volta diferente na quarta

- **WHEN** a volta é às 18h00 de segunda a sexta, menos quarta, às 12h30
- **THEN** "Saída da escola" mostra os horários por dia

#### Scenario: Sem taxa de reserva

- **WHEN** a proposta não tem `enrollmentFee`
- **THEN** a linha "Taxa de reserva" não aparece

### Requirement: Diferença para a versão anterior

A partir da versão 2, o card de valor SHALL mostrar numa faixa própria, separada por uma linha, o que mudou no preço desde a versão anterior: a diferença do total, nunca da parcela (seta para baixo e "R$ 480" em verde quando baixou, seta para cima e "R$ 240" em cinza quando subiu), e a troca do número de parcelas em cinza ("10x → 12x"), as duas juntas quando ambas mudaram e nada quando nenhuma mudou e o link "Comparar" com o ícone de comparar à esquerda, sem citar a versão. A comparação SHALL ser uma tabela única, sem título e sem resumo de preço à parte, com as duas versões como colunas, nomeadas uma vez só no topo, e uma linha por item que mudou entre as duas versões (valor, parcelas, período, vencimento, taxa de reserva, reajuste, cancelamento, dias e trechos, horários, veículo). Em cada linha, uma seta SHALL ligar o valor de antes, à esquerda, ao de agora, à direita. Dias com mais de um trecho SHALL aparecer um por linha. Em horários, a linha SHALL mostrar só os horários que mudaram, cada mudança com o trecho e os dias ("Volta · Seg, Qua", "Ida · Seg a sex") e o horário de antes e o de agora; os dias que mudaram do mesmo jeito SHALL ficar juntos, e com irmãos a mudança de um só SHALL dizer de quem é ("Ana · Volta · Sex"). Sem nenhuma mudança, a tela SHALL dizer "Nada mudou entre as duas versões.".

#### Scenario: O motorista baixou o valor

- **WHEN** a versão 1 era R$ 340/mês · 12x e a versão 2 é R$ 300/mês · 12x
- **THEN** o card da versão 2 mostra "−R$ 40"
- **AND** a comparação mostra o valor de antes e o de agora

### Requirement: Histórico

O histórico SHALL listar, em ordem de data: o pedido de orçamento, cada versão só pelo número ("Versão 2"), cada pedido de ajuste com o valor sugerido (ou o assunto, quando não houver valor) e o aceite ou a recusa. A versão aberta SHALL aparecer destacada só pela bolinha azul, sem a palavra "Atual". Um traço SHALL ligar cada bolinha à seguinte.

#### Scenario: Negociação com ajuste

- **WHEN** houve o pedido, a versão 1, um ajuste para R$ 290 e a versão 2
- **THEN** o histórico mostra os quatro, com a versão 2 destacada

### Requirement: Ações só na versão vigente

Com a proposta `SENT`, o rodapé SHALL ter "Pedir ajuste" e "Aceitar", e "Recusar proposta" SHALL aparecer no fim do detalhe, abaixo do aviso do contrato, em destaque de perigo. Esses botões SHALL aparecer só quando a proposta está `SENT`. Uma versão substituída SHALL aparecer só para leitura, com o link para a versão vigente. Uma proposta aceita, recusada, vencida ou retirada SHALL aparecer só para leitura, com o resultado.

#### Scenario: Abrir uma versão antiga

- **WHEN** o responsável abre a versão 1 depois de a versão 2 chegar
- **THEN** o detalhe não tem rodapé e mostra o link para a versão 2

### Requirement: Detalhe no modo pedido

Para uma negociação sem proposta, o detalhe SHALL mostrar o motorista, os alunos, os dias e trechos pedidos, o início desejado, a mensagem enviada, o prazo de resposta e o histórico, com "Cancelar pedido" no rodapé.

#### Scenario: Ver pedido

- **WHEN** o responsável abre "Ver pedido" num pedido `OPEN`
- **THEN** o detalhe mostra o que foi pedido e "Cancelar pedido"

### Requirement: Pedir ajuste

A tela SHALL mostrar o motorista, os filhos, a versão vigente com o valor e a validade, e:

- "Alterações": uma única escolha entre Valor, Parcelas, Dias e horários, Período do contrato e Outro;
- "Valor sugerido" opcional, até 100 caracteres. Para Valor, um campo de dinheiro, "Mensalidade";
- "Mensagem" opcional, até 500 caracteres;
- a linha "A versão n segue válida até dd/mm".

O envio SHALL exigir o valor sugerido ou a mensagem. No sucesso, o detalhe SHALL mostrar o ajuste no histórico, e a negociação SHALL passar para "Aguardando resposta" na lista.

#### Scenario: Ajuste só com mensagem

- **WHEN** o responsável escolhe Dias e horários e escreve só a mensagem
- **THEN** o pedido de ajuste é enviado

#### Scenario: Ajuste vazio

- **WHEN** o responsável não preenche valor nem mensagem
- **THEN** "Enviar pedido de ajuste" fica desativado

### Requirement: Recusar proposta

"Recusar" SHALL abrir uma gaveta com o motorista, o valor e os filhos, uma escolha de motivo (Valor acima do esperado, Horários não atendem, Escolhi outra van, Não preciso mais do transporte, Outro motivo), uma mensagem opcional e a linha "A negociação com <motorista> é encerrada.". Antes de recusar, o app SHALL pedir confirmação ("Recusar proposta?", "Isso encerra a negociação com <motorista> e não pode ser desfeito."). O app SHALL mandar o motivo e a mensagem juntos num texto de até 500 caracteres; a mensagem SHALL caber com qualquer motivo. No sucesso, a negociação SHALL ir para Encerradas como "Encerrada por você". Num 409 ou 404, a gaveta SHALL fechar com a mensagem do back e o detalhe SHALL recarregar.

#### Scenario: Recusa com motivo e mensagem

- **WHEN** o responsável escolhe "Escolhi outra van" e escreve "Obrigada, Rita."
- **THEN** o motivo enviado contém os dois textos e a negociação é encerrada

#### Scenario: Recusa de uma versão substituída

- **WHEN** o responsável recusa a versão 2 e o back responde 409 porque a versão 3 chegou
- **THEN** a gaveta fecha com a mensagem do back e o detalhe recarrega, sem sair para a lista

### Requirement: Aceitar e proposta aceita

"Aceitar", no detalhe ou no cartão da conversa, SHALL pedir confirmação ("Aceitar proposta?", "O contrato de <filhos> com <motorista> é gerado para revisão e assinatura.") e, confirmado, SHALL aceitar a versão aberta. "Voltar" SHALL fechar a confirmação sem aceitar. No sucesso, o app SHALL abrir a tela "Proposta aceita" com:

- "Contrato de <filhos> com <motorista> gerado para assinatura.";
- "Resumo": valor em parcelas, período e dias;
- "Próximas etapas": aceite da proposta (com a data e a hora do aceite), sua assinatura, assinatura do motorista e início das viagens (o início proposto), sem prazos;
- "Ao assinar o contrato, as outras negociações de <filhos> são encerradas.";
- "Revisar e assinar contrato", que abre "Em breve", e "Assinar depois", que fecha a tela.

Num 409 (proposta vencida, substituída ou cadastro mudado), o app SHALL mostrar a mensagem do back e recarregar o detalhe.

#### Scenario: Aceite com sucesso

- **WHEN** o responsável aceita a versão 2
- **THEN** a tela "Proposta aceita" abre com o resumo e as próximas etapas
- **AND** "Revisar e assinar contrato" abre "Em breve"

#### Scenario: A família mudou de bairro

- **WHEN** o back responde 409 `proposal.accept.stale`
- **THEN** a mensagem do back aparece e o detalhe é recarregado
