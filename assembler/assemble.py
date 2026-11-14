#!/usr/bin/env python3
"""ATOMPU S1 ISA v1 two-pass assembler. Standard library only."""
import re,sys,argparse,json
from pathlib import Path
OPS={'NOP':0,'LDI':1,'MOV':2,'ADD':3,'SUB':4,'AND':5,'OR':6,'XOR':7,'NOT':8,'LOAD':9,'STORE':10,'JMP':11,'JZ':12,'JNZ':13,'CMP':14,'HALT':15}
class AssemblyError(ValueError):pass
def assemble(text):
 lines=[];labels={};pc=0;used=set()
 for lineno,line in enumerate(text.splitlines(),1):
  line=line.split(';')[0].strip()
  if not line:continue
  if ':' in line:
   label,line=line.split(':',1);label=label.strip().upper()
   if not re.fullmatch('[A-Z_][A-Z_0-9]*',label) or label in labels:raise AssemblyError(f'line {lineno}: invalid/duplicate label')
   labels[label]=pc;line=line.strip()
  if not line:continue
  tok=[x for x in re.split(r'[\s,\[\]]+',line.upper()) if x];op=tok[0]
  if op=='.ORG':
   if len(tok)!=2:raise AssemblyError(f'line {lineno}: .org needs address')
   pc=int(tok[1],0)
   if not 0<=pc<=255:raise AssemblyError(f'line {lineno}: .org outside memory')
   continue
  if pc%2 or pc>254:raise AssemblyError(f'line {lineno}: instruction address must be even within 0..254')
  if pc in used or pc+1 in used:raise AssemblyError(f'line {lineno}: overlapping program')
  used|={pc,pc+1};lines.append((lineno,pc,tok));pc+=2
 rom=bytearray(256);listing=[]
 def reg(token):
  if not re.fullmatch('R[0-3]',token):raise AssemblyError('register must be R0..R3')
  return int(token[1])
 def imm(token):
  val=labels[token] if token in labels else int(token,0)
  if not 0<=val<=255:raise AssemblyError('immediate/address outside 0..255')
  return val
 for lineno,pc,t in lines:
  try:
   op=t[0];opcode=OPS[op];rd=rs=value=0
   argc=0 if op in ['NOP','HALT'] else 1 if op in ['NOT','JMP','JZ','JNZ'] else 2
   if len(t)!=argc+1:raise AssemblyError(f'{op} expects {argc} operand(s)')
   if op in ['JMP','JZ','JNZ']:
    value=imm(t[1])
    if value%2:raise AssemblyError('branch target must be even')
   elif argc:
    rd=reg(t[1])
    if argc==2:
     if op in ['LDI','LOAD','STORE']:value=imm(t[2])
     else:rs=reg(t[2])
   rom[pc]=opcode<<4|rd<<2|rs;rom[pc+1]=value;listing.append({'address':pc,'bytes':[rom[pc],rom[pc+1]],'assembly':' '.join(t)})
  except (ValueError,KeyError,IndexError) as e:raise AssemblyError(f'line {lineno}: {e}') from e
 return bytes(rom),listing
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('input');p.add_argument('-o','--output',required=True);p.add_argument('--hex');p.add_argument('--listing');a=p.parse_args()
 try:rom,listing=assemble(Path(a.input).read_text())
 except AssemblyError as e:p.exit(1,str(e)+'\n')
 Path(a.output).write_bytes(rom)
 if a.hex:Path(a.hex).write_text(''.join(f'{x:02x}\n' for x in rom))
 if a.listing:Path(a.listing).write_text(json.dumps(listing,indent=2))
