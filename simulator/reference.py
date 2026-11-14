#!/usr/bin/env python3
"""Independent architectural model; does not import RTL decoder or assembler opcode table."""
from dataclasses import dataclass,field
@dataclass
class Machine:
 program:bytes
 data:bytearray=field(default_factory=lambda:bytearray(256))
 regs:list=field(default_factory=lambda:[0,0,0,0])
 pc:int=0
 z:int=0
 c:int=0
 halted:bool=False
 fault:bool=False
 writes:list=field(default_factory=list)
 def step(self):
  if self.halted:return None
  pc=self.pc;word=self.program[pc];arg=self.program[(pc+1)&255];op=word//16;dst=(word//4)%4;src=word%4;a=self.regs[dst];b=self.regs[src]
  valid=True
  if op in (0,15):valid=(word%16==0 and arg==0)
  elif op in (1,9,10):valid=(src==0)
  elif op in (2,3,4,5,6,7,14):valid=(arg==0)
  elif op==8:valid=(src==0 and arg==0)
  elif op in (11,12,13):valid=(word%16==0)
  take=(op==11 or op==12 and self.z==1 or op==13 and self.z==0)
  if not valid or take and arg%2:self.halted=True;self.fault=True;return None
  result=None;update=False;carry=0
  if op==1:result=arg;update=True
  elif op==2:result=b;update=True
  elif op==3:result=(a+b)&255;carry=int(a+b>255);update=True
  elif op in (4,14):result=(a-b)&255;carry=int(a>=b);update=True
  elif op==5:result=a&b;update=True
  elif op==6:result=a|b;update=True
  elif op==7:result=a^b;update=True
  elif op==8:result=a^255;update=True
  elif op==9:result=self.data[arg];update=True
  elif op==10:self.data[arg]=a;self.writes.append([arg,a])
  if update:
   self.z=int(result==0);self.c=carry
   if op!=14:self.regs[dst]=result
  if op==15:self.halted=True
  else:self.pc=arg if take else (pc+2)&255
  return [pc,word,arg,*self.regs,self.z,self.c,self.pc]
 def run(self,limit=10000):
  trace=[]
  for _ in range(limit):
   if self.halted:return trace
   row=self.step()
   if row is not None:trace.append(row)
  raise RuntimeError('Reference instruction limit (possible nonhalting program)')

if __name__=='__main__':
 import argparse,json,sys
 from pathlib import Path
 parser=argparse.ArgumentParser(description='Run an ATOMPU S1 256-byte ROM in the independent reference model')
 parser.add_argument('program');parser.add_argument('--data');parser.add_argument('--trace');parser.add_argument('--limit',type=int,default=10000);args=parser.parse_args()
 program=Path(args.program).read_bytes();initial=Path(args.data).read_bytes() if args.data else bytes(256)
 if len(program)!=256 or len(initial)!=256:parser.error('Program and initial data images must have exactly 256 bytes')
 machine=Machine(program,bytearray(initial))
 try:trace=machine.run(args.limit)
 except RuntimeError as e:parser.exit(1,str(e)+'\n')
 result={'halted':machine.halted,'fault':machine.fault,'pc':machine.pc,'registers':machine.regs,'zero':machine.z,'carry':machine.c,'retired':len(trace),'writes':machine.writes}
 if args.trace:Path(args.trace).write_text(json.dumps({'result':result,'trace':trace},indent=2))
 print(json.dumps(result,indent=2));sys.exit(2 if machine.fault else 0)
