COMMENT!
	Prime Numbers
	Kyle Free
	Computer Organization
	COSC 2325 2801
	10 / 12 / 23
	Instructions: 
		Write a program that generates all prime numbers between 2 and 1000, using the
			Sieve of Eratosthenes method.
		You can find many articles that describe the method for finding primes in this
			manner on the Internet. Display all the prime values.
!

.386
.model flat, stdcall
.stack 1000h
ExitProcess PROTO, dwExitProcess:DWORD
PrintPrimes PROTO, count:DWORD

INCLUDE Irvine32.inc

FIRST		EQU		2					; The first number to check for prime
LAST		EQU		1000				; The last number to check for prime

.data
sieve		BYTE	LAST	DUP(10h)	; An array of 1000 marked (01) and unmarked (00) elements
commaStr	BYTE	", ", 0				; String for printing

.code
; Driver procedure
main PROC

	MOV		ecx,	LAST			; Move the LAST number into ecx as a counter
	MOV		edi,	OFFSET sieve	; Move the address of the array indo the destination register
	MOV		eax,	0				; Move 0 into the eax register

	PUSH	ecx						; Push the LAST number onto the stack
	CLD								; Clear direction flag
	REP		STOSB					; Repeat STOS operation that moves the value in the A register to the address at edi and then increments edi and decrements ecx
	POP		ecx						; Pop the LAST number into ecx

	MOV		esi,	FIRST			; Move the FIRST prime number into esi (data source register)

.WHILE (esi < LAST)						; Begin while loop
	CMP		sieve[esi * TYPE BYTE], 0	; Compare the value at the index to 0
		JNE		NEXT					; Jump if not equal to 0

	CALL	MarkNums					; Call the procedure to mark prime numbers

NEXT:
	INC		esi							; Increment esi by 1 (1 byte)
.ENDW									; End while loop

	INVOKE	PrintPrimes, LAST		; Invoke the PrintPrimes procedure with 1000d as count
	INVOKE	ExitProcess, 0

main ENDP

MarkNums PROC
COMMENT!----------------------------------------------------------------------------------
	This procedure runs through the array and marks the elements that are NOT prime.
------------------------------------------------------------------------------------------!

	PUSHAD								; Push all the registers onto the stack

	MOV		eax,	esi					; Move the value at esi to eax
	MOV		ecx,	LAST				; Move the last prime into the ecx counter register
	ADD		esi,	eax					; Add the value in eax to esi

L1:
	CMP		esi,	LAST				; Compare the value at esi to the last prime check (1000)
		JGE	L2							; Jump if greater or equal

	MOV		sieve[esi * TYPE sieve], 1	; Mark the element in the array index of esi
	ADD		esi,	eax					; Increment esi by the value at eax
	LOOP	L1							; Repeat loop

L2:
	POPAD								; Pop registers back into themselves
	
	RET									; Return pointer

MarkNums ENDP


PrintPrimes PROC, count:DWORD
COMMENT!----------------------------------------------------------------------------------
	PrintPrimes procedure checks for a marked element, and then prints the esi index that
		represents the prime number.
------------------------------------------------------------------------------------------!
	MOV		esi,	FIRST					; Move the first prime value into esi (source register)
	MOV		eax,	0						; Move 0 into eax
	MOV		ecx,	count					; Move the count parameter into ecx

L1:
	MOV		al,		sieve[esi * TYPE sieve]	; Move 1 into the index located at esi
	
	CMP		al,		0						; Compare the byte value in al to 0
		JNE	NEXT							; Jump if not equal

	MOV		eax,	esi						; Move the index in esi to eax
	CALL	WriteDec						; Write the number in eax as a decimal value

	MOV		edx,	OFFSET commaStr			; Move the address of the comma string to edx
	CALL	WriteString						; Write the string from address located at edx
	CALL	Crlf							; Carriage return line feed

NEXT:
	INC		esi								; Increment esi by 1 (1 byte)
	LOOP	L1								; Repeat loop

	RET										; Return pointer

PrintPrimes ENDP
END main