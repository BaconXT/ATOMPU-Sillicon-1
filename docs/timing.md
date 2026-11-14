# Protocolo externo de quatro fases

Cada acesso tem duas fases de requisição, primeiro endereço e depois dados. Os sinais WRITE/IFETCH identificam o tipo e permanecem estáveis nas duas fases. O host é um servidor de memória; não executa a ISA. Deve guardar o endereço latched na primeira fase, servir byte do espaço de programa/dados ou aceitar escrita na segunda fase.

1. ASIC mantémREQ=0 antes de iniciar e espera ACK sincronizado=0.
2. ASIC sobeREQ comDATA_PHASE=0 e uo=ADDRESS. Host amostra endereço, sobeACK e o mantém. ASIC observaACK através de2FF e baixaREQ. Host observaREQ=0 e baixaACK.
3. ASIC esperaACK sincronizado=0 e sobeREQ comDATA_PHASE=1. Em leitura, host colocaREAD_DATA antes de subirACK; em escrita, host recebeWRITE_DATA e efetiva **uma única escrita**. ASIC captura leitura quandoACK sincronizado=1 e baixaREQ.
4. Host baixaACK quandoREQ cai. ASIC só conclui a transação quandoACK sincronizado voltar0. Então a CPU pode continuar ou aposentar.

```text
fase        endereço        retorno ACK      dados           retorno ACK
REQ       __/────────\________________/────────\________________
ACK       _____/────────\________________/────────\_____________
DATA_PHASE   0                               1
uo           endereço                        dado STORE / endereço READ
ui                                            dado READ estável antes de ACK
```

A largura deREQ/ACK varia com a latência do host. Não há timeout que converta atraso em instrução falsa. O sincronizador evita depender da fase deACK; não é uma prova formal de MTBF. O barramento de dados é bundled-data estável, não oito sincronizadores independentes. O host de teste muda suas saídas na borda oposta e aplica esperas, inclusive ACK prolongado. Não se promete frequência funcional antes de STA e silício.

Cada instrução busca dois bytes por duas transações IFETCH. LOAD/STORE acrescenta uma terceira transação no espaço de dados. CPU usa clock externo; host pode mantê-lo lento no devkit, mas não pode alterarDATA/ACK junto à borda de captura sem cumprir os tempos oficiais de I/O. O sinal de parada eR0 permitem observar resultados sem clock adicional de protocolo.
