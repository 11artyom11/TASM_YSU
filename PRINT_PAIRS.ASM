;
;
.model small
.STACK 256

.DATA
	MAX_LEN EQU 255
	SUCCESS_CODE EQU 0
	USER_PROMPT_1 DB "Please input first string: $"
	USER_PROMPT_2 DB "Please input second string: $"


    A DB MAX_LEN, ?, MAX_LEN dup (?)
    B DB MAX_LEN, ?, MAX_LEN dup (?)


.CODE 
MAIN:
	MOV AX, @DATA
	MOV DS, AX
	XOR AX, AX
	MOV AX, @STACK
	MOV SP, AX
	MOV BP, AX
	
	XOR AX, AX
	PUSH DS     	
	POP ES
;Preparation is done

INPUT_STRINGS:
	LEA DX, USER_PROMPT_1
	CALL _TERM_OUTB_SEQ_
	LEA DX, A				; Inquire the first line (A)
	CALL _TERM_INB_SEQ_

	CALL _TERM_LINEFEED_   	; Line feed

	LEA DX, USER_PROMPT_2
	CALL _TERM_OUTB_SEQ_
	LEA DX, B   			; Inquire the second line (B)
	CALL _TERM_INB_SEQ_

	CALL _TERM_LINEFEED_

; Input of the strings is done

	XOR CX, CX  ; Nullate CX
	LEA DI, B + 2 ; Load the pseudo start of the Second string (B) to DI
	LEA SI, A + 1 ; Load the actual length of the First String (A) to SI
	XOR AX, AX  ; Nullate AX
	LODSB 		; Load to AX the value of the ES:[SI] (the actual length of the A string)
	LEA SI, A + 2 ; Load the pseudo start of the First string (A) to SI
	MOV CX, AX ; Move the length of the first string to Counter register (CX)
	XOR AX, AX ; Nullate AX

BACK:
	CMP CX, 0  ; Compare counter to 0
	JZ END_OF_LOOP ;If diff is zero we are done
	XOR AX, AX	; Again Nullate AX
	XOR BX, BX ; Nullate BX
	MOV AL, ES:[SI] ; Move the next byte of the A string to lower AX
	MOV BL, ES:[DI] ; Move the next byte of the B string to lower BX
	INC SI			; Increment the A string iterator
	INC DI			; Increment the B string iterator
	DEC	 CX			; Decrement the CX (counter)
	CMP AL, BL		; Compare the sequenced bytes of the A and B
	JNZ BACK		; If not equal, jump back to grab next bytes
	JMP PRINT_PAIRS	; if equal jump to the PRINT_PAIR

PRINT_PAIRS:
	MOV AL, '#'	; Load the byte to print to the DL
	CALL _TERM_OUTB_
	
	MOV AL, CL
	CALL _TERM_OUT_DEC_
	
	MOV AL, ' '	; Load the byte to print to the DL
	CALL _TERM_OUTB_

	MOV AL, BL
	CALL _TERM_OUTB_

	MOV AL, '-'	; Load the byte to print to the DL
	CALL _TERM_OUTB_
	
	MOV AL, BL
	CALL _TERM_OUTB_
	
	CALL _TERM_LINEFEED_
	JMP BACK 	; Jump back to the loop

END_OF_LOOP:
	MOV AH, 4CH ; End the program with status code SUCCESS
	MOV AL, SUCCESS_CODE
	INT 21h

;_TERM_OUTB_ PRINTS TO SERIAL TERMINAL ONE SINGLE SYMBOL
_TERM_OUTB_ PROC ; INPUT PARAMETER IS A ASCII SYMBOL IN LOWER AX (AL)
	XOR DL, DL 
	MOV DL, AL
	MOV AH, 2
	INT 21H
	RET
_TERM_OUTB_ ENDP

;_TERM_OUTB_ PRINTS TO SERIAL TERMINAL ONE SINGLE DIGIT 
_TERM_OUT_DEC_ PROC ; INPUT PARAMETER IS A BYTE_LEN INTEGER SYMBOL IN LOWER AX (AL)
	ADD AL, 48
	CALL _TERM_OUTB_
	RET
_TERM_OUT_DEC_ ENDP


;_TERM_LINEFEED_ SERVES AS A NEWLINE SERVICE
_TERM_LINEFEED_ PROC ; NO INPUT/OUTPUT PARAMS
	MOV DL, 10
	MOV AH, 02h
	INT 21h		 ; Line Feed (<CR><LF>)
	MOV DL, 13
	MOV AH, 02h
	INT 21h
	RET
_TERM_LINEFEED_ ENDP

;_TERM_INB_SEQ_ SERVES TO MOVE INSERTED BYTE-SEQUENCE INTO MEMORY STARTING FROM LOCATION
; DS:[DX+2]
_TERM_INB_SEQ_ PROC ; INPUT PARAMETER IS EFFECTIVE ADDRESS OF BYTE SEQUENCE IN DX
	MOV AH, 10 ; Inquire the first string (A)
	INT 21h
	RET
_TERM_INB_SEQ_ ENDP

;_TERM_INB_SEQ_ SERVES TO PRINT BYTE-SEQUENCE FROM MEMORY STARTING FROM LOCATION
; DS:[DX]
_TERM_OUTB_SEQ_ PROC
	MOV AH, 9
	INT 21h
	RET
_TERM_OUTB_SEQ_ ENDP

END MAIN

