Mode_Switch 
 MOV r0, #0x2 ; set stack to PSP 
 MSR CONTROL, r0 
 ISB
 
 MOV r0, #0x03 ; set privilege level to User. ; N.B. Cannot combine this to single MSR instruction with ; above PSP change when using RVDS ISSM!!
 MSR CONTROL, r0 
 ISB 
 BX lr ; and return safely 