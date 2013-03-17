extern puts, alloc, free, printf

section .data
    usage_msg db "Usage: task1 format number", 0
    unknown_flag_msg db "Unknown flag 'x'", 0
    unknown_flag_pos equ 14
    number_expected_msg db "Expected a number, got 'x'", 0
    number_expected_pos equ 24

    int_format db "%i", 10, 0

    flag_space equ 0xff
    flag_plus equ 0xffff
    flag_minus equ 0xff0000
    flag_zero equ 0xffff0000

section .text
global main

unknown_flag:
    mov [unknown_flag_msg + unknown_flag_pos], dl
    push unknown_flag_msg
    call puts
    add esp, 4
    ret

number_expected:
    mov [number_expected_msg + number_expected_pos], dl
    push number_expected_msg
    call puts
    add esp, 4
    ret

main:

    mov ecx, [esp + 4]
    cmp ecx, 3
    je arguments_count_good

    push usage_msg
    call puts
    add esp, 4
    ret

arguments_count_good:

    mov edi, [esp + 8] ; edi = argv
    mov esi, [edi + 4] ; esi = argv[1]

    push 0 ; here we'll save the flags
    ; now, [esp] is the flag set

    xor eax, eax
    xor edx, edx; usefull for the algorithm
    read_flags:
        mov dl, [esi]
        inc esi

        cmp dl, ' '
        je set_flag_space
        cmp dl, '+'
        je set_flag_plus
        cmp dl, '-'
        je set_flag_minus
        cmp dl, '0'
        je set_flag_zero

        cmp dl, '0'
        jl read_flags_unknown_flag
        cmp dl, '9'
        jg read_flags_unknown_flag

        dec esi ; we'll read it again
        mov [esp], eax ; save the flags
        xor eax, eax ; length will be here
        jmp read_length

        set_flag_space:
            or eax, flag_space
            jmp read_flags

        set_flag_plus:
            or eax, flag_plus
            jmp read_flags

        set_flag_minus:
            or eax, flag_minus
            jmp read_flags

        set_flag_zero:
            or eax, flag_zero
            jmp read_flags

        read_flags_unknown_flag:
            call unknown_flag
            add esp, 4
            ret

    read_length:

        xor edx, edx ; just in case
        mov dl, [esi]
        inc esi

        test dl, dl
        jz end_read_flags

        cmp dl, '0'
        jl read_length_number_expected
        cmp dl, '9'
        jg read_length_number_expected 

        ; magic
        lea eax, [eax + 4 * eax]
        lea eax, [2 * eax + edx - '0']
        

        ; do something

        jmp read_length
        
        read_length_number_expected:
            call number_expected 
            add esp, 4
            ret

    end_read_flags:
        test eax, eax
        jnz length_not_zero

        mov eax, 1

    length_not_zero:
        push eax

    ; by bow:
    ; [esp] length
    ; [esp + 4] flags

    ; DEBUG BEGIN
    ; print length and flags

        push dword [esp]
        push int_format
        call printf
        add esp, 8

        mov eax, [esp + 4]
        and eax, 0x01010101
        add eax, 0x30303030
        push 0
        push eax
        push esp
        call puts

        add esp, 12

    ; DEBUG END
    add esp, 8
    
    ret
