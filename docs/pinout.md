# Interface lógica Tiny Tapeout — ATOMPU S1

O top `tt_um_atompu_s1` preserva exatamente portas oficiais: ui_in[7:0], uo_out[7:0], uio_in/out/oe[7:0], ena,clk,rst_n. São sinais lógicos do projeto no multiplexer do shuttle, **não pinos de um encapsulamento privado de CPU**. O breakout/devkit físico precisa ser confirmado antes de KiCad; não há footprint inventado.

- ui_in[7:0]: READ_DATA, barramento de dados **do host para o ASIC**.
- uo_out[7:0]: ADDRESS na fase de endereço; WRITE_DATA na fase de dados de escrita; endereço permanece visível em leitura. Em repouso/halt mostraR0.
- uio[0]: REQ, saída, válida enquanto uma fase espera reconhecimento.
- uio[1]: WRITE, saída,1 para STORE,0 para leitura.
- uio[2]: IFETCH, saída,1 para memória de programa,0 para dados.
- uio[3]: DATA_PHASE, saída,0 endereço,1 dados.
- uio[4]: HALTED, saída,1 em HALT ou fault.
- uio[5]: Z, saída.
- uio[6]: C, saída quando não parado; **FAULT quando HALTED=1**.
- uio[7]: ACK, **entrada** do host; nunca dirigida pelo ASIC.

`uio_oe=0x7f` fixa direções sem troca durante transação. Host não deve dirigir uio0..6; ASIC não dirigeuio7. ui é sempre entrada; uo é sempre saída. Nenhum barramento bidirecional de dados reversível e nenhuma hipótese de USB/UART no ASIC.

rst_n é reset ativo baixo **síncrono**; manter baixo por pelo menos2 bordas de clock com dados/ACK em0. ena=0 aborta/reset na próxima borda, REQ é forçado0 imediatamente; host deve descartar a transação em andamento e baixarACK antes de reativar. Um STORE já reconhecido pode ter efeito externo antes de reset: abortar não desfaz memória. Não usar ena como passo/instrução ou como controle de direção.

ACK atravessa dois flip-flops no ASIC. Dados de leitura devem estabilizar **antes** de subirACK e permanecer estáveis atéREQ cair. O protocolo não permite pulso de ACK curto: manter nível até observarREQ cair. Reset não remove a necessidade de clock. Clock e todos os níveis elétricos físicos devem seguir o manual oficial do kit que for comprado; não extrapolar tensão de core para I/O do breakout.
