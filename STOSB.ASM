; a[9], word, signed,
; output(count of (a[i]>0 && a[i]%4==1))
.model small
.STACK 256

.DATA
    A DB 'abcde'
    B DB 'cd74e'
    C DB 5 dup(?)

.CODE 
MAIN:
		MOV AX, @DATA
		MOV DS, AX
		XOR AX, AX
		MOV AX, @STACK
		MOV SP, AX
		MOV BP, AX
		PUSH BP
		MOV SP, BP
		XOR AX, AX
    	PUSH DS     	

    	POP ES      
	
    	CLD      
  	    	
      	LEA DI, C
    	LEA SI, A   
      	LODSB       	

    	MOV CX, 5   	

    	REP STOSB 
		RET
end main
