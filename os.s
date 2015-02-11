; Liam O'Shea 2014
; Basic OS for ARM Processor. Complete with interrupt handler, process handler, stack pointers, seperate stacks for system operations
; and user operations to provide seperation and security.

 AREA StackSwitch, CODE, READONLY 
 ;r0-r3;r14
 IMPORT PrintHex
 IMPORT PrintDec
 IMPORT PrintChar
 IMPORT SystemInit
 IMPORT PrintString
 EXPORT Start
 EXPORT Reset_Handler 
 EXPORT SVC_Handler
 
 THUMB 
 PRESERVE8 
 
 ENTRY
Reset_Handler 


Start 
 BL SystemInit ; Initialise the hardware and C init.
 BL Stackalign; Using STKALIGN hardware feature of the M3 processor 
ProcCount DCD 0 
 BL Demote
 SVC 0


 
Demote
 MOV r0, #0x2 ; set stack to PSP 
 MSR CONTROL, r0 
 ISB
 LDR SP, =0x20001000 ; PROBABLY NEED TO SET A PSP HERE SOMETIME
 MOV r0, #0x03 ; set privilege level to User. ; N.B. Cannot combine this to single MSR instruction with ; above PSP change when using RVDS ISSM!!
 MSR CONTROL, r0 
 ISB 
 BX lr ; and return safely 

Stackalign
 LDR r0, =0xE000ED14 ; NVIC CCR 
 LDR r1, [r0] 
 ORR.W r1, r1, #0x200 ; set STKALIGN bit
 STR r1, [r0] ; store back to CCR
 BX lr

 
SVC_Handler
 ;Get SVC number to determina operation (e.g. SVC 3)
 PUSH {r0-r3,r14}
 TST lr, #4 
 ITE eq ; check which mode we came from 
 MRSEQ r4, MSP ; load the relevant stack pointer 
 MRSNE r4, PSP 
 LDR r1, [r4, #24] ; stacked PC 
 LDRB r1, [r1, #-2] ; get SVC instruction’s operand 
 
 ;Now we need to compare operand 
 CMP r1,#5
 BEQ Createproc
 CMP r1,#4
 BEQ PrintString
 CMP r1,#3
 BEQ PrintChar
 CMP r1,#2
 BEQ PrintDec
 CMP r1,#1
 BEQ PrintHex
 CMP r1,#0
 BEQ KillProc
 POP {r0-r3,r14}
 BX lr
 
Createproc
 PUSH {r0} ; Push Process Address
 LDR r0, = 0x00000100 ; PSP Offset to Multiply
 LDR r1,ProcCount ; Get Process Number
 ;increment PC
 ADD r2, r1,#1
 ;STR ProcCount,r2
 
 MUL r2,r0,r1 ; (Offset * Program ID)
 LDR r1, = 0x20001100 ; Base Address
 ;MUL 
 ;ADD r3,r1,r2,lsl #2
 ADD r0,r1,r2; PSP Stack Pinter (Base + (Offset * Program ID))
 ISB
 ;demote
 POP {r1}
 ;execute
 SVC 0
 
Proc1
 NOP
Proc2
 NOP
Proc3
 NOP

ProcMon
 LDR r0,ProcCount ; Get Process Number
 LDR r1,=ProcTable ; Get Address of Process table
 LDR r0, [r1, r0, LSL#2] ;Load Address of Process in Processtable
 SVC 5 ; Run CreateProcess via Handler
 
ProcTable
 DCD Proc1
 DCD Proc2
 DCD Proc3
EndTable


KillProc
 LDR r0, = ProcMon ;0x08000441
 MRS r1, PSP
 ADD r1,r1,#24
 STR r0, [r1]
 LDR lr, =0xFFFFFFFD
 BX lr;
 
 
MULT
 CMP r1, #1 
 BEQ Finish
 ITTT HS
 SUBHS r1, #1
 MULHS r0, r2
 BLHS MULT
 

Finish
 B Finish 
 END ; Mark end of file 
 

;MSR
;Load an immediate value, or the contents of a general-purpose register, into specified fields of a Program Status Register(PSR).
;MRS
;Move the contents of a PSR to a general-purpose register.
