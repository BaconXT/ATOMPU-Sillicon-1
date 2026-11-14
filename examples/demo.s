; CPU computes 1+2+3+4+5 in ASIC, stores15 at data[0x20], then halts with R0=15.
LDI R0,0
LDI R1,5
LDI R2,1
loop:
 ADD R0,R1
 SUB R1,R2
 JNZ loop
STORE R0,[0x20]
HALT
