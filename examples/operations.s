LDI R0,255
LDI R1,1
ADD R0,R1       ; overflow ->0 Z1 C1
SUB R0,R1       ; underflow ->255 Z0 C0
NOT R0          ; 0 Z1 C0
MOV R2,R1
OR R0,R2
XOR R0,R1
AND R2,R0
CMP R2,R0
JZ equal
LDI R0,99
HALT
equal:
LOAD R3,[0x42]
STORE R3,[0x43]
JMP end
NOP
end:
HALT
