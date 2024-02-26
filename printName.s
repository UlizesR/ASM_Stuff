section .data
    promptText:         db "What is your name: "
    promptTextLength:   equ $ - promptText
    secondText:         db " is your name?", 10
    secondTextLength:   equ $ - secondText

section .bss
    name resb 15 + secondTextLength ; Space for input and appended string

section .text
global _start

_start:

    ; Print prompt message
    mov rax, 1                  ; SYS_WRITE
    mov rdi, 1                  ; fd = STDOUT
    mov rsi, promptText         ; *buf
    mov rdx, promptTextLength   ; Count of bytes to write
    syscall                     ; Call Linux

    ; Get name
    mov rax, 0                  ; SYS_READ
    mov rdi, 0                  ; fd = STDIN
    mov rsi, name               ; *buf
    mov rdx, 15                 ; Max count of bytes to read
    syscall                     ; Call Linux - return EAX = number of bytes read

    ; Append secondText
    mov rsi, secondText         ; *source
    mov rdi, name               ; *dest
    add rdi, rax                ; Set pointer one byte behind the real name
    mov rcx, secondTextLength   ; Count of bytes to copy
    lea rbx, [rax + rcx]        ; Save the total length of the string
    rep movsb                   ; Copy RCX bytes from [RSI] to [RDI]

    ; Print name (input + second message)
    mov rax, 1                  ; SYS_WRITE
    mov rdi, 1                  ; fd = STDOUT
    mov rsi, name               ; *buf
    mov rdx, rbx                ; Count of bytes to write (RBX was saved above)
    syscall                     ; Call Linux

    ; Exit (0)
    mov rax, 60                 ; SYS_EXIT
    mov rdi, 0                  ; Exitcode
    syscall                     ; Call Linux / no return