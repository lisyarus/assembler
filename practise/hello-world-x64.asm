extern printf

section .data
    hw_string db "Hello, world!", 10, 0

section .text

global main

main:
    ; frame pointer
    push rbp
    mov rbp, rsp
    
    ; allignment
    and rsp, -16
    
    ; prepare arguments
    mov rdi, hw_string
    mov rax, 1
    
    ; call
    call printf
    
    ; restore rsp & rbp
    mov rsp, rbp
    pop rbp
    ret
