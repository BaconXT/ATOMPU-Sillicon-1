# ATOMPU Silicon 1 — decisão de arquitetura antes de RTL

Datapath de 8 bits,4×8 registradores,PC de 8 bits, instrução16 bits e flagsZ/C. Controle multicíclo com ALU e comparações internas. Memórias externas de programa/dados com256 bytes cada economizam área; o host só atende acessos, sem simular o processador em seu lugar. Formato, flags e protocolo estão congelados em isa.md/pinout.md/timing.md para os testes diferenciais.

Módulos: ALU, banco de registradores, PC, decoder, controlador FSM e bridge de barramento. O wrapper Tiny Tapeout concentra o mapeamento de portas/direções. RESET e ena=0 zeram a arquitetura; HALT/fault mantêmR0 observável. Nada deriva clock de lógica combinacional; estado muda somente na borda do clock.

Candidata atual consultada: TTSKY26e, SKY130A, template oficial ttsky-verilog-template. A página de rodadas lista fechamento30/11/2026 e envio estimado25/06/2027. O template main ainda referencia ação ttsky26d; existe tag oficial **ttsky26e**, que será fixada por commit na integração. Disponibilidade de slots/preço não foi reservada. Nenhum número de tiles é considerado aprovado antes de síntese e implementação física.

Não há FPGA nesta solução final. Tiny Tapeout coloca este bloco num chip compartilhado; não produz um die exclusivo da nossa CPU. A placa de suporte da fase seguinte usará preferencialmente o breakout/devkit oficial; KiCad permanece condicionado à confirmação mecânica e elétrica específica da rodada.
