COMMENT!
	Filling An Array
	Kyle Free
	Computer Organization
	COSC 2325 2801
	9 / 18 / 23
	Description:
		Create a procedure that fills an array of doublewords with N random integers, making
			sure the values fall within the range j...k, inclusive.
		When calling the procedure, pass a pointer to the array that will hold the data, pass N,
			and pass the values of j and k.
		Preserve all register values between calls to the procedure.
		Write a test program that calls the procedure twice, using different values for j and k.
		Verify your results using a debugger.
!
.386
.model flat, stdcall
.stack 1000h
ExitProcess PROTO, dwExitProcess:DWORD

INCLUDE Irvine32.inc

.data
resultArray		SDWORD	50	DUP(?)
lowLimit		DWORD	?
highLimit		DWORD	?

.code
main PROC

	CALL	Randomize							; Seed randoms

AGAIN: ; Jump here if the random number is 0
	MOV		eax,		LENGTHOF	resultArray	; Move the length of the array into eax
	CALL	RandomRange							; Get a random number from 0 to 49

	CMP		eax,		0						; Compare the random number to 0
		JE	AGAIN								; Jump to try again for another random number

	MOV		highLimit,	eax						; Move the random number into the highLimit (j)

	CALL	RandomRange							; Get a random number from 0 to (highLimit - 1)
	MOV		lowLimit,	eax						; Move the random number into lowLimit

	MOV		ebx,	lowLimit					; Move the lowLimit into the base (ebx)
	MOV		edx,	highLimit					; Move the highLimit into the edx
	MOV		esi,	OFFSET		resultArray		; Move the address of the array into esi
	MOV		ecx,	LENGTHOF	resultArray		; Move the length of the array into ecx

	;CALL	FillWithRandoms						; Call procedure to fill the array
	CALL	FillAllWithRandoms

	; Second call
	MOV		ebx,	5
	MOV		edx,	50

	CALL	FillAllWithRandoms

	INVOKE	ExitProcess, 0

main ENDP

FillWithRandoms PROC
COMMENT!----------------------------------------------------------------------------------
	The FillWithRandoms procedure uses the address at esi to increment and fill the array,
		based on the values of j (lowLimit) and k (highLimit).
	The values j and k are randomized.
	The values are between the values of j and k, inclusive.
	The array is filled from index j to index k, inclusive.

	Parameters: esi, the address of the array
				ebx, the base value/index
				edx, the upper limit of the value/index
	Returns: Nothing
------------------------------------------------------------------------------------------!
.data
count		DWORD		0
interval	DWORD		?

.code
	PUSHAD							; Save all registers on the stack

	MOV		eax,		edx			; Move the highLimit into eax
	SUB		eax,		ebx			; Subtract the lowlimit from the highLimit (eax)
	MOV		interval,	eax			; Move the value of the difference into interval
	MOV		ecx,		interval	; Move the value of interval into ecx	
	INC		ecx						; Increment the ecx by one

	PUSH	eax						; Push the highLimit onto the stack
	PUSH	edx						; Push the lowLimit onto the stack

	MOV		eax,		4			; Move 4 into eax
	MUL		lowLimit				; Multiply lowLimit by 4 (eax)
	MOV		interval,	eax			; Move the value in eax (lowLimit*4) into interval

	POP		edx						; Pop lowLimit into edx
	POP		eax						; Pop highLimit into eax

	ADD		esi,	interval		; Add the interval into the array pointer

	CMP		esi,	resultArray		; If the interval was 0, keep the address
		JE  KEEP					; Jump to keep the address

	SUB		esi,	4				; Otherwise, subtract 4 from the address

KEEP:
	MOV		eax,	edx				; Move the highLimit (edx) into eax
	INC		eax						; Increment eax

FILL:
	PUSH	eax						; Push (highLimit + 1) onto the stack

	CALL	RandomRange				; Call a random number between 0 to (highLimit + 1)

	CMP		eax,	edx				; Compare the random number with the highLimit (edx)
		JG	SAVE_SPOT				; If the random number is greater, the number is not saved.

	CMP		eax,	ebx				; Computer the random number with the lowLimit (ebx)
		JL	SAVE_SPOT				; If the random number is lower, the number is not saved.

	; If both compare operations pass,
	MOV		[esi],	eax				; Move the value of eax into the address esi
	ADD		esi,	4				; Increment the esi pointer by one doubleword
	INC		count					; Increment the element counter
	JMP		NEXT					; Jump to the next spot in the array

SAVE_SPOT:
	INC		ecx						; The ecx counter is incremented to "save" the spot in the array

NEXT:
	POP		eax						; Pop the highLimit off the stack into eax

	LOOP	FILL					; Loop back to fill more elements

DONE:
	CALL	PrintAndClearCount		; Print counter and then clear it

	POPAD							; Pop register values from the stack into themselves

	CALL	PrintArray				; Print the array

	RET								; Return pointer

FillWithRandoms ENDP

FillAllWithRandoms PROC
COMMENT!----------------------------------------------------------------------------------
	The FillAllWithRandoms procedure uses the address at esi to increment and
		fill the entire array, based on the values of j(lowLimit) and k(highLimit).
	The values j and k are randomized.
	All of the elements of the array are filled with values between j and k, inclusive.

	Parameters: esi, the address of the array
				ebx, the lowest value that an element could be
				edx, the highest limit that an element could be
	Returns: Nothing
------------------------------------------------------------------------------------------!
.data
divider		DB	"FillAllWithRandoms", 0

.code
	PUSHAD

	MOV		edx,	OFFSET divider			; Move the address of the title string to edx
	CALL	WriteString						; Write string from the address in edx
	CALL	Crlf							; Carriage return line feed

	MOV		count,	0						; Clear counter
	MOV		edx,	highLimit				; Move highLimit back into edx
	MOV		eax,	edx						; Move the highLimit into eax
	INC		eax								; Increment eax for the random range

FILL:
	PUSH	eax								; Push the incremented highLimit onto the stack

	CALL	RandomRange						; Randomize the eax register

	CMP		eax,	edx						; Compare the random number with the highLimit
		JG	SAVE_SPOT						; If the random number is greater, save the spot in the array

	CMP		eax,	ebx						; Compare the random number with the lowLimit
		JL	SAVE_SPOT						; If the random number is lower, save the spot in the array

		; If both compare operations pass,
	MOV		[esi],	eax						; Move the value in eax to the spot in the array	
	ADD		esi,	4						; Increment the array address by one doubleword

	INC		count							; Increment the counter
	JMP		NEXT							; Jump to the next iteration

SAVE_SPOT:
	INC		ecx								; Increment the ecx register to save the spot in the array

NEXT:
	POP		eax								; Pop the incremented highLimit back into eax
	
	LOOP	FILL							; Loop back to fill another element

DONE:
	;CALL	PrintAndClearCount

	POPAD									; Pop the registers back into themselves
	
	CALL	PrintArray						; Print the array

	RET										; Return pointer

FillAllWithRandoms ENDP

PrintArray PROC
COMMENT!----------------------------------------------------------------------------------
	The PrintArray procedure uses the address of the resultArray to write
		and iterate through all fifty elements of the array.

	Parameters: esi, the address of the array to be printed
	Returns: Nothing
------------------------------------------------------------------------------------------!
	MOV		count,	0				; Clear counter

	PUSHAD							; Push all registers onto the stack

PRINT:
	MOV		eax,	[esi]			; Move the value of the element into eax

	CALL	WriteDec				; Print the value in eax as a decimal number
	CALL	Crlf					; Carriage return line feed

	ADD		esi,	4				; Increment array by one doubleword

	INC		count					; Increment count
	LOOP	PRINT					; Loop back to print the next element

	CALL	PrintAndClearCount		; Print the number of elements that were printed
	
	POPAD							; Pop the registers off of the stack
	
	CALL	DumpRegs				; Print all registers and flags

	RET								; Return pointer

PrintArray ENDP

PrintAndClearCount PROC
COMMENT!----------------------------------------------------------------------------------
	The PrintAndClearCount procedure prints the count variable and then clears the value.

	Parameters: NONE
	Returns: Nothing
------------------------------------------------------------------------------------------!
.data
countText	BYTE	"Count: "

.code
	PUSHAD								; Push registers onto the stack

	MOV		eax,	count				; Move the number of elements printed into eax
	MOV		edx,	OFFSET countText	; Move the address of the label to edx

	CALL	WriteString					; Write the string from the address in edx
	CALL	WriteDec					; Print the value at eax as a decimal number
	CALL	Crlf						; Carriage return line feed

	MOV		count, 0					; Clear counter

	POPAD								; Pop the registers from the stack into themselves

	RET									; Return pointer

PrintAndClearCount ENDP

END main