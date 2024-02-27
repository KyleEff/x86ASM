COMMENT!
	Find Threes
	Kyle Free
	Computer Organization
	COSC 2325 2801
	11 / 18 / 23
	Instructions:
		Create a procedure named FindThrees that returns 1 if an array has three consecutive
		values of 3 somewhere in the array. Otherwise, return 0. The procedure's input
		parameter list contains a pointer to the array and the array's size. Use the PROC
		directive with a parameter list when declaring the procedure. Preserve all
		registers (except EAX) that are modified by the procedure.
		Write a test program that calls FindThrees several times with different arrays.
!

.386
.model flat, stdcall
.stack 1000h
ExitProcess PROTO, dwExitProcess:DWORD
FindThrees PROTO, arrayNums:DWORD, arrayLength:DWORD ; Prototype

INCLUDE Irvine32.inc

.data
returnValue		BYTE	0								; Return value stored in memory
values1			BYTE	50 DUP(?)						; Values that do not return a true value
values2			BYTE	25 DUP(?), 3, 3, 3, 22 DUP(?)	; Values that return a true value
values3			SBYTE	5, 10, 15, 7, -125, -54, 3, 3, 3; Values that return a true value
values4			SBYTE	-1, -2, -3, 3, 2, 1				; Values that return a false value

.code
main PROC
	; Invoke procedure with two arguments: the address of the array and the length of the array
	INVOKE	FindThrees,	ADDR values2, LENGTHOF values2

	MOV		eax,	0				; Clear the EAX register
	MOV		al,		returnValue		; Move the return value into the lower bits of the A register
	CALL	WriteDec				; Print the return value. This instance should be 1
	CALL	Crlf

	; The pattern is not found on this second procedure call. The return value is 0.
	INVOKE	FindThrees, ADDR values1, LENGTHOF values1
	MOV		eax,	1				; Reset the EAX register to 1, so that the procedure returns 0
	MOV		al,		returnValue
	CALL	WriteDec				; Print the return value. This instance should be 0
	CALL	Crlf

	INVOKE	FindThrees, ADDR values3, LENGTHOF values3
	MOV		al,		returnValue
	CALL	WriteDec
	CALL	Crlf

	INVOKE	FindThrees, ADDR values4, LENGTHOF values4
	MOV		eax,		DWORD PTR returnValue
	CALL	WriteDec

	INVOKE	ExitProcess, 0			; Exit program

main ENDP

FindThrees PROC USES ebx ecx esi,	; EBX for value storage, ECX for loop counter, ESI for array source index
	arrayNums:DWORD,				; Array of numbers for searching
	arrayLength:DWORD				; Length of the array parameter
	
	MOV		eax,	0				; Clear the EAX register
	MOV		ebx,	0				; Clear the EBX register
	MOV		ecx,	arrayLength		; Move the length into the ECX register
	MOV		esi,	arrayNums		; Move the address of the array into the ESI register
	MOV		returnValue, 0			; Reset return value

FIND:
	MOV		bl,		[esi]			; Move the value at the ESI source index into the lower bits of the B register

	CMP		bl,		3		; Compare the value at the lower bits of the B register to 3
		JNE	RESET			; Jump if not equal to reset the count of 3's in EAX
	INC	eax					; If equal, increment the EAX register to keep track of the count

		CMP		eax,	3	; Compare the EAX register to 3
			JNE	NEXT		; Jump if not equal to the next array element

		PUSH	eax			; If there have been three 3's in a row, push the value onto the stack

		JMP	NEXT			; Skip the EAX reset because the value was valid
RESET:
	MOV		eax,	0		; Reset the EAX register to 0

NEXT:
	INC		esi					; Increment the ESI index
	LOOP	FIND				; Loop back to find another 3

	POP		eax					; Pop the stack into EAX
	CMP		eax,	3			; Compare the value in EAX to 3
		JNE NOMATCH				; Jump if not equal to the end of the procedure

	MOV		returnValue,	1	; If there is a 3 in EAX, the return value is 1
NOMATCH:
	RET						; Return pointer

FindThrees ENDP				; End procedure
END main