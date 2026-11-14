# ATOMPU Silicon 1 — repositório para validação Tiny Tapeout

Esta pasta foi montada a partir de `ATOMPU_S1_0780090_20261114.zip` (versão da conversa de 14/11/2026).

## Antes de submeter

1. **Não envie este ZIP diretamente ao Tiny Tapeout.** Extraia-o e coloque o CONTEÚDO na raiz de um repositório GitHub público. A raiz deverá conter `info.yaml`, `src/`, `test/` e `docs/info.md` (não `asic/src/`).
2. Em `info.yaml`, substitua `author: ATOMPU project` pelo nome/nome de equipe a publicar e verifique `top_module` e `source_files`.
3. Revise `.github/workflows/gds.yaml` e `.github/workflows/test.yaml`. O workflow GDS foi copiado da entrega original, com ação Tiny Tapeout fixada por commit e execução manual; confirme que ainda é compatível com TTSKY26e e execute-o pelo GitHub Actions. Não presuma que a configuração esteja validada na nuvem.
4. Confira a documentação, o projeto, os resultados de ações GDS, precheck e testes. Não pague nem use `Submit a new revision` enquanto não houver aprovação.
5. `src/` e `rtl/` são cópias dos mesmos fontes; `verification/sync_template.py --check` verifica a sincronização.
6. **Nenhum GDSII ou PCB de fabricação foi incluído**: os arquivos gerados e relatórios anteriores permanecem no ZIP completo original, para consulta.

## Conteúdo

- `src/`: Verilog usado pelo fluxo Tiny Tapeout.
- `rtl/`: fonte canônico do projeto, mantido para conferir sincronização.
- `test/`: testes cocotb e testbench.
- `docs/info.md`: resumo para datasheet do Tiny Tapeout, criado a partir de `docs/pinout.md` e `docs/timing.md`.
- `info.yaml`: dados de identificação, área solicitada e pinos.
- `assembler/`, `simulator/`, `examples/`: suporte de verificação e programas de demonstração.
- `verification/`: scripts originais de validação.
- `.github/workflows/`: workflows da entrega original, ainda sujeitos à aprovação da plataforma.

**Status:** pacote de fontes organizado para cadastro/validação, NÃO aprovação ou reserva de fabricação.
