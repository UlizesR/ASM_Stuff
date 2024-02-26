; Utility routines for NASM macOS 64bit
; Nevedomsky Dmitry, 2021
; Usage:
; nasm -Wall -f macho64 -Ox -o test.a test.asm
; ld -macosx_version_min 10.13 -L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -lSystem -o run test.a

;==============================================================================
; CONSTANTS
;==============================================================================

%define STDIN       dword 0
%define STDOUT      dword 1
%define BUFSIZE     256

%define BYTEMAX     127
%define BYTEMIN     -BYTEMAX - 1

%define WORDMAX     32767
%define WORDMIN     -WORDMIN - 1

%define DWORDMAX    2147483647
%define DWORDMIN    -DWORDMAX - 1

%define QWORDMAX    9223372036854775807
%define QWORDMIN    -QWORDMIN - 1

%define SYS_CALL(x) 0x02000000 + x
%define SYS_EXIT    SYS_CALL(1)
%define SYS_FORK    SYS_CALL(2)
%define SYS_READ    SYS_CALL(3)
%define SYS_WRITE   SYS_CALL(4)
%define SYS_OPEN    SYS_CALL(5)
%define SYS_CLOSE   SYS_CALL(6)
%define SYS_OPENAT  SYS_CALL(463)

%macro  SYSCALL    1
    mov     rax, %1
    syscall
%endmacro

%define UMASKDEF    dword 0o644
%define O_CREATE    dword 0x0601
%define O_READONLY  dword 0x0000

%macro  main        0-1 _main
    default     rel
    global      %1
    section     .text
%1:
%endmacro

%define msg(name,value) name: db value,`\0`


;==============================================================================
    section .bss
;==============================================================================


    bool        resb    1
    readbuf     resb    BUFSIZE ; buffer for read operations


;==============================================================================
    section .data
;==============================================================================


    msg(msgnumerr,`Not a number. Try again...\n> `)
    msg(nl,`\n`)
    msg(false,"False")
    msg(true,"True")


;==============================================================================
    section .text
;==============================================================================


; void newline() - moves caret to newline
newline:
    mov     rdi, STDOUT
    lea     rsi, [nl]
    mov     rdx, 1
    SYSCALL SYS_WRITE
    ret


; rax strlen(rdi) <- Length of string at RSI, terminated by 0 or \n
strlen:
    mov         rax, rdi

    .nextchar:
        cmp     byte [rax], 0
        je      strlen.finished
        inc     rax
        jmp     strlen.nextchar

    .finished:
        sub     rax, rdi
        ret


; ; eax checknumber(esi) - 1 if number in ESI, 0 if not
; checknumber:
;     push 	esi

;     mov 	eax, esi

;     cmp 	byte [eax], '-' ; Check whether first symbol is '-'
;     jne 	checknumber.loopy
;     inc 	esi
;     inc 	eax ; if true, then skip minus

;     .loopy:
;         cmp 	byte [eax], 0 ; if met end
;         je 		checknumber.exityes

;         ; cmp 	byte [eax], 0xA ; if met newline
;         ; je 		checknumber.exityes

;         cmp 	byte [eax], '0'
;         jl 		checknumber.exitno

;         cmp 	byte [eax], '9'
;         jg 		checknumber.exitno

;         inc 	eax
;         jmp 	checknumber.loopy

;     .exityes:
;         cmp 	eax, esi
;         mov 	eax, 1
;         jne 	checknumber.exit

;     .exitno:
;         mov 	eax, 0

;     .exit:
;     pop 	esi
;     ret


; void print(rdi) - prints buffer at ESI
print:
    call    strlen
    mov     rdx, rax

    mov     rsi, rdi
    mov     rdi, STDOUT
    SYSCALL SYS_WRITE
    ret


; void prinln(rsi) - same as print, but with linefeed
println:
    call    print
    call    newline
    ret


; rax read(rdi,rsi) - reads from terminal at RDI, eax shows how many was read
read:
    mov     rdx, rsi
    mov     rsi, rdi
    mov     rdi, STDIN
    SYSCALL SYS_READ

    mov 	byte [rsi + rax - 1], 0 ; remove linefeed
    ret


; ; eax atoi(esi) - converts string at ESI to number at EAX
; atoi:
;     push 	esi
;     push 	ecx
;     push 	ebx
;     push 	edx

;     call 	strlen
;     mov 	ecx, eax

;     mov 	edx, 0 ; is negative
;     mov 	eax, 0
;     mov 	ebx, 0

;     cmp 	byte [esi], '-'
;     jne 	.loopy

;         inc 	esi
;         dec 	ecx

;         mov 	edx, 1


;     .loopy:
;         imul 	eax, 10

;         mov 	bl, byte [esi]
;         inc 	esi

;         sub 	bl, '0'
;         add 	eax, ebx

;         loop 	.loopy

;     cmp 	edx, 0
;     je  	.finish
;     mov 	edx, eax
;     mov 	eax, 0
;     sub 	eax, edx

;     .finish:
;     pop 	edx
;     pop 	ebx
;     pop 	ecx
;     pop 	esi
;     ret


; ; edi itoa(eax) - convert number from EAX and store it to EDI
; itoa:
;     push 	edi
;     push 	edx
;     push 	ecx
;     push 	ebx
;     push 	eax

;     mov 	ecx, 0
;     mov 	ebx, 0 ; is negative

;     test 	eax, eax
;     jns  	.loopy

;         mov 	ebx, eax
;         mov 	eax, 0
;         sub 	eax, ebx
;         inc 	ecx

;     .loopy:
;         inc 	ecx
;         mov 	edx, 0
;         idiv 	word [ten]
;         add 	edx, '0'
;         push 	edx
;         cmp 	eax, 0
;         jg  	.loopy

;     cmp 	ebx, 0
;     je  	.loopo
;     push 	'-'

;     .loopo:
;         pop 	eax
;         mov 	[edi], al
;         inc 	edi
;         loop 	.loopo

;     mov 	[edi], byte 0;

;     pop 	eax
;     pop 	ebx
;     pop 	ecx
;     pop 	edx
;     pop 	edi
;     ret


; ; void printbool() - prints value of [bool]
; printbool:
;     push 	esi

;     cmp 	eax, 0
;     je  	printbool.false

;     ; true
;         mov 	esi, true
;         jmp 	printbool.printend

;     .false:
;         mov 	esi, false

;     .printend:

;     call 	print
;     pop 	esi
;     ret


; ; eax readnumber() - reads input until number typed
; readint:
;         mov 	edi, readbuf
;         mov 	eax, BUFSIZE
;         call 	read

;         mov 	esi, readbuf
;         call 	checknumber

;         cmp 	eax, 0
;         jne 	.success

;         mov 	esi, msgnumerr
;         call 	print

;         jmp 	readint

;     .success:
;     mov 	esi, readbuf
;     call 	atoi
;     ret


; ; void exit() - exit program
; exit:
;     push 	dword 0
;     mov 	eax, 1
;     sub 	esp, 4
;     int 	0x80


; void exitcode(rdi) - exit with exitcode
exitcode:
    SYSCALL SYS_EXIT

; numerror:
;     mov 	esi, msgnumerr
;     call 	println

;     mov 	eax, 1
;     call 	exitcode

; strcmp:
;     push 	esi
;     push 	edi
;     push 	ecx
;     push 	ebx

;     mov 	ecx, 0
;     mov 	ebx, 0

;     .loops:
;         cmp 	byte [esi + ecx], ' '
;         je  	.lesser
;         cmp 	byte [esi + ecx], 0
;         je  	.lesser
;         cmp 	byte [esi + ecx], 10
;         je  	.lesser
;         cmp 	byte [edi + ecx], ' '
;         je  	.bigger
;         cmp 	byte [edi + ecx], 0
;         je  	.bigger
;         cmp 	byte [edi + ecx], 10
;         je  	.bigger

;         mov 	bl, byte [esi + ecx]
;         cmp 	bl, byte [edi + ecx]
;         jg  	.bigger
;         jl  	.lesser
;         inc 	ecx
;         jmp 	.loops


;     .lesser:
;         mov 	eax, 0
;         jmp 	.end

;     .bigger:
;         mov 	eax, 1

;     .end:

;     pop 	ebx
;     pop 	ecx
;     pop 	edi
;     pop 	esi
;     ret


; ; void printword(esi) - prints word, starting at ESI, till its end
; printword:
;     push 	eax
;     push 	esi

;     .loops:
;         cmp 	byte [esi], ' '
;         je  	.end
;         cmp 	byte [esi], 0
;         je  	.end
;         cmp 	byte [esi], 10
;         je  	.end
;         inc 	esi
;         jmp 	.loops
;     .end:

;     cmp 	byte [esi - 1], ','
;     je  	.punc
;     cmp 	byte [esi - 1], '.'
;     je  	.punc
;     cmp 	byte [esi - 1], ';'
;     je  	.punc
;     cmp 	byte [esi - 1], ':'
;     je  	.punc
;     cmp 	byte [esi - 1], '!'
;     je  	.punc
;     cmp 	byte [esi - 1], '?'
;     je  	.punc
;     cmp 	byte [esi - 1], '-'
;     je  	.punc
;     jmp 	.nopunc
;     .punc:
;     dec esi
;     .nopunc:

;     mov 	eax, esi
;     pop 	esi

;     sub 	eax, esi

;     cmp 	eax, 0
;     je  	.exit

;     push 	eax
;     push 	esi
;     push 	STDOUT
;     sub 	esp, 4
;     mov 	eax, 4
;     int 	80h
;     add 	esp, 16

;     .exit:
;     pop 	eax
;     ret


; rax openfile(rdi,rsi) - opens file, with path and mode specified
openfile:
    mov     rdx, UMASKDEF
    SYSCALL SYS_OPEN
    ret


; void closefile(rdi) - closes file by its descriptor
closefile:
    SYSCALL SYS_CLOSE
    ret


; void fprint(rdi, rsi) - write RSI contents to stream at RDI
fprint:
    xchg    rsi, rdi
    call    strlen

    xchg    rsi, rdi
    mov     rdx, rax
    SYSCALL SYS_WRITE
    ret