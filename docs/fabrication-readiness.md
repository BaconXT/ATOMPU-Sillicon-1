# Prontidão da S1

**Candidato digital para revisão; fabricação/submissão bloqueadas.** Commit físico `0780090a2c90b8b6f12df4c7988d60fdeaa7179c`.

PASS: hardening oficial local, GDS/LEF, tile1x1 roteado, DRC Magic, Netgen LVS, STA extraída nove cantos, precheck 15/15 e regressões de CPU/firmware/netlist. SDF complementar tem limitações detalhadas; ambiente precheck usa Magic 623 em vez do default Nix 568. Revisar essas diferenças antes de qualquer tapeout.

BLOCKED: rodada definitiva, manifesto/índice efetivo S1, revisão física entregue do breakout. Referência CAD3.2/esquema3.1 não prova fornecimento. Índice nulo e verificações de hardware/identidade falsas continuam no firmware.

BLOCKED: dois pares Hirose DF12N em placas rígidas requerem avaliação de tolerâncias/diretriz ETAD-H1028-00; conjunto3D com Pico H/soquetes/cabo/fixação e encaixe físico não validados. Modelo oficial confirma projeção/saliência6,05mm apenas.

BLOCKED: consumo/inrush/queda/ripple/temperatura, domínios/sequência de power e concessão USB desconhecidos; F1 protege5V_TT, não3V3, e não limita corrente precisamente. A carga do ASIC não é desligada antes da enumeração USB. Não aceitar compatibilidade só pelo exemplo130,3 mA; ele é estimativa e pode exceder100 mA de pré-configuração. Caso necessário, projetar alimentação com margem, limitação e chaveamento/anti-retorno/retenção segura de reset depois de congelar a revisão real. Essa alteração ainda não foi implementada e não basta aumentar F1.

NOT_RUN: bancada, chip/shuttle completo, aprovação foundry, análise térmica/EM/IR do conjunto, ensaios USB, CDC/MTBF formal, equivalência formal pós-layout, revisão humana independente, DFM da montadora, consulta de estoque/preço/reserva. Os testes atuais não concedem essas aprovações.

A carrier KiCad Rev A1 não mudou eletricamente; ERC/DRC+615 checks e Gerbers foram repetidos, sem alegar validação do breakout fornecido. Tudo permanece local; create-tt-submission criou arquivos, não enviou nada.

`python3 verification/check_release.py --candidate` valida evidências digitais; sem esse parâmetro deve continuar retornandoBLOCKED pelos gates físicos/humanos. Não marcar camposPASS para contornar o bloqueio.
