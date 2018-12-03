%include "asm_io.inc"

extern rconf

section .data

array dd 0,0,0,0,0,0,0,0,0,0 ; Nine elements in the array, initalized 10 for edge case check with sort
num_pegs dd 0;
cur dd 0;
next dd 0;
change dd 0;
rc_pegs dd 0;
temp_pegs dd 0;
second_check dd 0;

final_version dd "Final Version of Tower",10,0
inital_position dd "Inital Tower Configuration",10,0
errorParams dd "Invalid number of input paramters.",10,0
errorRange  dd "Range Error: Number must be in the range 2-9.",10,0

;;;;; PEGS ;;;;;
p1:   db "          +|+          ",10,0
p2:   db "         ++|++         ",10,0
p3:   db "        +++|+++        ",10,0
p4:   db "       ++++|++++       ",10,0
p5:   db "      +++++|+++++      ",10,0
p6:   db "     ++++++|++++++     ",10,0
p7:   db "    +++++++|+++++++    ",10,0
p8:   db "   ++++++++|++++++++   ",10,0
p9:   db "  +++++++++|+++++++++  ",10,0
base: db "XXXXXXXXXXXXXXXXXXXXXXX",10,0

section .text
global asm_main

ERROR1:
	mov eax, errorParams
	call print_string
	call print_nl
	jmp END
ERROR2:
	mov eax, errorRange
	call print_string
	call print_nl
	jmp END

showp:
	enter 0,0
	pusha

	mov edx, [ebp+ 8] ; this would be array
	add edx, 32
	mov ebx, 0 ; counter
	
	showphelper:
		cmp ebx, 9
		je doneshowp
		cmp [edx], dword 0
		je cleanup

		cmp [edx], dword 1
		je print1
		cmp [edx], dword 2
		je print2
		cmp [edx], dword 3
		je print3
		cmp [edx], dword 4
		je print4
		cmp [edx], dword 5
		je print5
		cmp [edx], dword 6
		je print6
		cmp [edx], dword 7
		je print7
		cmp [edx], dword 8
		je print8
		cmp [edx], dword 9
		je print9

		print1:
			mov eax, p1
			jmp printit
		print2:
			mov eax, p2
			jmp printit
		print3:
			mov eax, p3
			jmp printit
		print4:
			mov eax, p4
			jmp printit
		print5:
			mov eax, p5
			jmp printit
		print6:
			mov eax, p6
			jmp printit
		print7:
			mov eax, p7
			jmp printit
		print8:
			mov eax, p8
			jmp printit
		print9:
			mov eax, p9
			jmp printit			

		printit:
			call print_string

		cleanup:
			inc ebx
			sub edx, 4
			jmp showphelper

	doneshowp:
		mov eax, base
		call print_string
		call read_char

	popa
	leave
	ret

greater:
	jmp sloopend

else:
	mov [change], dword 1
	sub edx, 4
	mov [edx], eax

	add edx, 4
	mov eax, [cur]
	mov [edx], eax

	inc ebx
	jmp sloop

final_swap:
	inc ecx
	mov [cur], eax ; smaller value
	mov eax, [edx] ; larger value
	mov [next], eax
	mov eax, [cur]
	mov [edx], eax
	sub edx, 4
	mov eax, [next]
	mov [edx], eax
	add edx, 4
	push num_pegs
	push array
	call showp
	add esp, 8
	jmp sort_loop

final_skip:
	inc ecx
	jmp sort_loop

final_sort:

	mov edx, array
	mov ecx, dword 0 ; counter
	sort_loop:

		cmp [num_pegs], ecx
		je final_sort_end
		mov eax, [edx]

		add edx, 4

		cmp [edx], eax
		jg final_swap
		jmp final_skip
	
	final_sort_end:
		cmp [second_check], dword 1
		je sorthem_end
		mov [second_check], dword 1
		jmp final_sort

sorthem:
	enter 0,0
	pusha

	mov edx, [ebp+ 8] ; this would be array
	mov ecx, [ebp+ 12] ; num pegs

	mov eax, [ecx] ; number of pegs for the sort

	cmp eax, dword 1 ; base case check for recursion
	je sorthem_end

	; NOT EQUAL SO RECURSIVE CALL

	dec dword [rc_pegs]
	push rc_pegs 
	add edx, 4
	push edx ; putting next index of array on stack for recursive call
	sub edx, 4
	call sorthem
	add esp, 8

	; COUNTER FOR THE LOOP
	mov ebx, dword 0 
	mov [change], dword 0

	mov [temp_pegs], eax ; NUMBER OF PEGS FOR THE RECURSIVE CALL

	sloop:
		mov eax, [temp_pegs] ;
		dec eax
		mov [temp_pegs], eax

		cmp ebx, [temp_pegs]
		je sloopend

		mov eax, [edx]
		mov [cur], eax
		add edx, 4
		mov eax, [edx]

		cmp [cur], eax ; COMPARING A(i) and A(i + 1)

		jg greater
		jmp else
		
		sloopend:
			cmp [change], dword 1
			jne sorthem_end
			push num_pegs
			push array
			call showp
			add esp, 8

	jmp final_sort

	sorthem_end:
		popa
		leave
		ret

asm_main:
	enter 0,0
	pusha

	; CHECK TO SEE NUMBER PARAMS VALID - top of stack contans argc
	mov eax, dword[ebp+8] 
	cmp eax, 2
	jne ERROR1

	; CHECK TO SEE IF RANGE OF ARG IS VALID
	mov ebx, dword [ebp+12] ; path argument
	mov eax, [ebx+4] ; pointer to the first argument
	mov bl, byte [eax]
	mov eax, 0
	mov al, bl
	sub al, 48
	cmp eax, dword 2
	jl ERROR2
	cmp eax, dword 9
	ja ERROR2

	mov [num_pegs], eax ; NUM PEGS used for all print statements
	mov [rc_pegs], eax  ; RC_PEGS used for sorthem recursive portion

	; CALL RCONF

	push eax
	push array
	call rconf
	add esp, 8

	; SHOWP ROUTE FOR INITAL PRINT
	mov eax, inital_position
	call print_string
	call print_nl
	push num_pegs
	push array
	call showp
	add esp, 8
	push num_pegs
	push array
	call sorthem
	add esp, 8

	mov eax, final_version
	call print_string
	call print_nl
	push num_pegs
	push array
	call showp
	add esp, 8

END:
	popa
	mov eax, 0
	leave
	ret