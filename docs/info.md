# ATOMPU Silicon 1 — 8-bit CPU

## How it works

ATOMPU S1 is a custom 8-bit, four-register, multi-cycle CPU implemented as a Tiny Tapeout digital user project. The chip contains the program counter, instruction decoding, state machine, arithmetic/logic unit, registers and status flags. It executes its own 16-bit instructions. Program and data memory are **external** and are supplied by a host controller; the host services memory reads/writes and does not emulate CPU instructions.

The design uses a two-phase memory handshake: address then data. The 8-bit `ui_in` bus carries read data from the host. The 8-bit `uo_out` bus carries an address or write data, depending on the phase. `uio_out[0]` is REQ, `[1]` WRITE, `[2]` IFETCH, `[3]` DATA_PHASE, `[4]` HALTED, `[5]` Z, and `[6]` C or FAULT (when halted). `uio_in[7]` is ACK from the host; the ASIC does not drive this pin. `uio_oe` is `0x7f`.

The externally provided clock is targeted at 10 MHz in the present implementation; this is a *design target*, not a measured frequency of manufactured silicon. Reset (`rst_n`) is active-low and sampled with the clock. Enabling (`ena`) gates operation; it is not a per-instruction step signal. See `docs/architecture.md`, `docs/isa.md`, `docs/pinout.md`, and `docs/timing.md` for the detailed specification.

## How to test

The RTL testbench is provided in `test/` using cocotb and an external-memory reference model. Run the Tiny Tapeout project's GitHub Actions tests and precheck before submitting. In a physical Tiny Tapeout devkit, select the **actual assigned project index** (not yet known), provide a valid clock and reset, and connect a host controller that observes REQ / DATA_PHASE and responds with ACK and read data according to `docs/timing.md`.

Hold read data stable before asserting ACK, and keep ACK high until REQ drops. Two handshakes are required per memory access. A running test program can halt with HALTED asserted and R0 observable on `uo_out`; review `docs/pinout.md` for the status flag conventions.

## External hardware

A compatible Tiny Tapeout breakout/devkit and an external program/data-memory controller are required for physical tests. The planned ATOMPU carrier PCB is a **separate, unapproved** project. Do not assume a physical breakout revision, supply voltage or project index until they are confirmed for the chosen shuttle.
