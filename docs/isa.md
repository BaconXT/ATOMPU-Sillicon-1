# ATOMPU S1 ISA v1 — congelada para verificação

CPU original de 8 bits, quatro registradores R0..R3, PC de **endereço de byte** 8 bits, flags Z e C. Programa externo tem256 bytes; dados externos têm256 bytes, espaços independentes. Todas as instruções ocupam2 bytes, endereços de instrução pares. Byte0=`opcode[7:4],rd[3:2],rs[1:0]`; byte1=operando imediato/endereço ou0 conforme tabela. Valores wrap modulo256, inclusive incremento de PC deFE para00. A aritmética é unsigned; comparação signed não existe na v1.

| Opcode | Assembly | Ação | Z/C |
|---|---|---|---|
|0|NOP|nenhuma alteração de registrador|preservados|
|1|LDI rd,imm|Rd←imm|Z=(resultado==0), C=0|
|2|MOV rd,rs|Rd←Rs|Z=resultzero,C=0|
|3|ADD rd,rs|Rd←Rd+Rs modulo256|Z=resultzero,C=carry bit8|
|4|SUB rd,rs|Rd←Rd−Rs modulo256|Z=resultzero,C=1 se Rd≥Rs (**sem borrow**)|
|5|AND rd,rs|Rd←Rd&Rs|Z=resultzero,C=0|
|6|OR rd,rs|Rd←Rd\|Rs|Z=resultzero,C=0|
|7|XOR rd,rs|Rd←Rd^Rs|Z=resultzero,C=0|
|8|NOT rd|Rd←~Rd|Z=resultzero,C=0|
|9|LOAD rd,[addr]|Rd←dados[addr]|Z=resultzero,C=0|
|A|STORE rd,[addr]|dados[addr]←Rd|flags preservados|
|B|JMP addr|PC←addr|preservados|
|C|JZ addr|PC←addr se Z=1, senãoPC+2|preservados|
|D|JNZ addr|PC←addr se Z=0, senãoPC+2|preservados|
|E|CMP rd,rs|não escreve Rd; calcula Rd−Rs|Z=igualdade,C=sem borrow|
|F|HALT|para, saída em repouso=R0|preservados|

`LOAD imediato` é LDI e `LOAD` é leitura externa; STORE usa o campo rd como fonte. Não há RAM ou ROM integradas, pipeline, interrupções, stack, multiplicador ou instrução SHIFT nesta versão. SHIFT foi opcional no plano e deu lugar à comparação sem destruir o operando. ADD/SUB são computados dentro da ALU do ASIC; o host não interpreta instruções.

Campos reservados: NOP/JMP/JZ/JNZ/HALT exigem rd=rs=0; NOT/LDI/LOAD/STORE exigem rs=0; instruções de registrador/MOV/NOT/CMP/NOP/HALT exigem byte1=0. Codificação inválida ou **alvo ímpar de salto efetivamente tomado** entra em parada de falha sem aposentar a instrução, mantendo PC e registradores. Saltos condicionais não tomados não avaliam alinhamento do operando. HALT válido aposenta, deixa PC no próprio HALT e sinaliza parada. Reset limpa PC, R0..R3, Z=0,C=0 e fault=0. A indicação de falha externa usa o modo ocioso de controles descrito em pinout; diagnóstico detalhado via flags/teste, sem CSR inventado.

As instruções aposentam uma vez após seus efeitos; LOAD/STORE somente depois do término do protocolo de memória. Nenhuma nova busca começa antes da retirada do ACK da transação anterior.
