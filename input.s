    SYS_READ   equ     0          ; read text from stdin
    SYS_WRITE  equ     1          ; write text to stdout
    SYS_EXIT   equ     60         ; terminate the program
    STDIN      equ     0          ; standard input
    STDOUT     equ     1          ; standard output
; --------------------------------
section .bss
    uinput_len equ     24         ; 24 bytes for user input
    uinput     resb    uinput_len ; buffer for user input
; --------------------------------
section .data
    prompt     db      "Please input some text: "
    prompt_len equ     $ - prompt
    text       db      10, "You wrote: "
    text_len   equ     $ - text
; --------------------------------
section .text
    global _start

_start:
    mov     rdx, prompt_len
    mov     rsi, prompt
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall

    mov     rdx, uinput_len
    mov     rsi, uinput
    mov     rdi, STDIN
    mov     rax, SYS_READ
    syscall                      ; -> RAX
    push    rax                  ; (1)

    mov     rdx, text_len
    mov     rsi, text
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall

    pop     rdx                  ; (1)
    mov     rsi, uinput
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall

    xor     edi, edi             ; successful exit
    mov     rax, SYS_EXIT
    syscall