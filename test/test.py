# SPDX-License-Identifier: Apache-2.0
"""Official template RTL/GL pin-level tests: host serves memory, CPU executes ISA."""
import sys,random,os
from pathlib import Path
import cocotb
from cocotb.triggers import Timer
HALF_PERIOD_NS=float(os.environ.get('HALF_PERIOD_NS','5'))
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'assembler'),str(ROOT/'simulator')]
from assemble import assemble
from reference import Machine

@cocotb.test()
async def test_atompu_s1_pin_protocol(dut):
    rng=random.Random(0x51A70)
    programs=[(p.stem,assemble(p.read_text())[0]) for p in sorted((ROOT/'examples').glob('*.s'))]
    for n in range(8):
        text='\n'.join([f'LDI R{i},{rng.randrange(256)}' for i in range(4)]+[f'{rng.choice(["ADD","SUB","XOR","AND","OR","CMP","MOV"])} R{rng.randrange(4)},R{rng.randrange(4)}' for _ in range(30)]+[f'STORE R{i},[{i}]' for i in range(4)]+['HALT'])
        programs.append((f'random-{n}',assemble(text)[0]))
    programs.append(('odd-jump',bytes([0xb0,3]+[0]*254)))
    for name,rom in programs:
        data=bytearray((i*37+13)&255 for i in range(256));ref=Machine(rom,bytearray(data));want_fetch=[]
        for _ in range(10000):
            if ref.halted:break
            want_fetch += [ref.pc,(ref.pc+1)&255];ref.step()
        else:assert False,'reference timeout'
        hs=0;delay=0;phase_expected=0;address=0;wr=False;fetch=False;payload=0;control=0;ack=0;rd=0;writes=[];fetches=[]
        dut.clk.value=0;dut.rst_n.value=0;dut.ena.value=1;dut.ui_in.value=0;dut.uio_in.value=0
        for _ in range(4):
            dut.clk.value=0;await Timer(HALF_PERIOD_NS,unit='ns');dut.clk.value=1;await Timer(HALF_PERIOD_NS,unit='ns')
        dut.rst_n.value=1
        for cycle in range(300000):
            dut.clk.value=0;await Timer(HALF_PERIOD_NS/2,unit='ns')
            assert int(dut.uio_oe.value)==0x7f,(name,'I/O contention directions')
            out=int(dut.uio_out.value);pins=int(dut.uo_out.value);req=out&1;phase=(out>>3)&1
            if out&0x10:
                assert out&1==0
                assert pins==ref.regs[0],(name,pins,ref.regs)
                assert (out>>5)&1==ref.z
                assert (out>>6)&1==int(ref.fault)
                assert writes==ref.writes,(name,writes,ref.writes)
                assert fetches==want_fetch,(name,fetches,want_fetch)
                break
            if hs==0 and req:
                assert phase==phase_expected
                payload=pins;control=out&0xe
                if not phase:address=pins;wr=bool(out&2);fetch=bool(out&4)
                else:
                    assert wr==bool(out&2) and fetch==bool(out&4)
                    if not wr:rd=rom[address] if fetch else data[address]
                delay=rng.randrange(5);hs=1
            elif hs==1:
                assert req and pins==payload and out&0xe==control
                if delay:delay-=1
                else:
                    ack=1;hs=2
                    if phase_expected:
                        if wr:
                            assert not fetch
                            data[address]=payload;writes.append([address,payload])
                        elif fetch:fetches.append(address)
            elif hs==2 and not req:delay=rng.randrange(4);hs=3
            elif hs==3:
                assert not req
                if delay:delay-=1
                else:ack=0;hs=0;phase_expected^=1
            dut.ui_in.value=rd;dut.uio_in.value=ack<<7
            await Timer(HALF_PERIOD_NS/2,unit='ns')
            dut.clk.value=1;await Timer(HALF_PERIOD_NS,unit='ns')
        else:assert False,(name,'DUT timeout')
        dut._log.info('PASS %s: %s writes, %s fetch bytes',name,len(writes),len(fetches))
