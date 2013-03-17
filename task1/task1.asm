extern puts, malloc, free, printf

section .data
    usage_msg db "Usage: task1 format number", 0
    unknown_flag_msg db "Unknown flag 'x'", 0
    unknown_flag_pos equ 14
    decimal_number_expected_msg db "Expected a decimal number, got 'x'", 0
    decimal_number_expected_pos equ 24
    hex_number_expected_msg db "Expected a hexadecimal number, got 'x'", 0
    hex_number_expected_pos equ 36
    big_length_msg db "The length must not exceed 50", 0
    long_argument_msg db "Argument too long: the number must not exceed 128 bits", 0

    minus db "-", 0
    newline db 10, 0

    int_format db "%i", 10, 0
    hex_format db "%x", 0

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

decimal_number_expected:
    mov [decimal_number_expected_msg + decimal_number_expected_pos], dl
    push decimal_number_expected_msg
    call puts
    add esp, 4
    ret

hex_number_expected:
    mov [hex_number_expected_msg + hex_number_expected_pos], dl
    push hex_number_expected_msg
    call puts
    add esp, 4
    ret

big_length:
    push big_length_msg
    call puts
    add esp, 4
    ret

long_argument:
    push long_argument_msg
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

        test dl, dl
        jz read_flags_proceed_read_length

        cmp dl, '0'
        jl read_flags_unknown_flag
        cmp dl, '9'
        jg read_flags_unknown_flag

        read_flags_proceed_read_length:

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
            call decimal_number_expected 
            add esp, 4
            ret

    end_read_flags:
        test eax, eax
        jnz length_not_zero

        mov eax, 1

    length_not_zero:
        cmp eax, 50
        jle valid_length

        call big_length
        add esp, 4
        ret

    valid_length
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
 
    start_read_number:

        xor ecx, ecx ; the number's length
        push 32
        call malloc
        
        mov dword [esp], 0 ; will be true if the number starts from a minus
        ; edi is argv
        mov esi, [edi + 8]; esi = argv[2]
        mov edi, eax ; edi is the result of malloc
        mov dl, [esi]
        cmp dl, '-'
        jne read_number

        mov dword [esp], 0xffffffff
        inc esi

    read_number:
        mov dl, [esi]
        inc esi
        
        test dl, dl
        jz end_read_number
 
        inc ecx
        cmp ecx, 32
        jg read_number_long_argument


        ; check that it's a hex digit
        
        ; maybe a decimal digit? 0..9
        cmp dl, '0'
        jl read_number_not_a_decimal_digit
        cmp dl, '9'
        jg read_number_not_a_decimal_digit
        ; yes, a decimal digit
        sub dl, '0'
        jmp read_number_end_check

        read_number_not_a_decimal_digit:
        
        ; maybe a capital hex digit? A..F
        cmp dl, 'A'
        jl read_number_not_a_capital_hex_digit
        cmp dl, 'F'
        jg read_number_not_a_capital_hex_digit
        ; yes, a capital hex digit
        sub dl, 'A' - 10
        jmp read_number_end_check

        read_number_not_a_capital_hex_digit:

        ; maybe a small hex digit? a..f
        cmp dl, 'a'
        jl read_number_bad_digit
        cmp dl, 'f'
        jg read_number_bad_digit
        ; yes, a small hex digit
        sub dl, 'a' - 10
        jmp read_number_end_check

        read_number_bad_digit:
        call hex_number_expected
        add esp, 12
        ret

        read_number_long_argument:
        call long_argument
        add esp, 12
        ret

        read_number_end_check:

        mov [edi], dl
        inc edi
        jmp read_number

    end_read_number:
       
        cmp ecx, 32
        jl no_need_to_negate

        mov dl, [edi - 32]
        test dl, 8
        jz no_need_to_negate

        mov eax, [esp]
        not eax
        mov [esp], eax

        ; negate the value
        ; -x = (not x) + 1

        lea esi, [edi - 32]
        
        read_number_do_not:
            mov dl, [esi]
            xor dl, 0xf
            mov [esi], dl
            inc esi
            cmp esi, edi
            jb read_number_do_not

        read_number_do_add_one:
            dec esi
            mov dl, [esi]
            add dl, 1
            mov al, dl

            and dl, 0xf
            mov [esi], dl
            and al, 0x10
            test al, al
            jnz read_number_do_add_one

    no_need_to_negate:

    ; DEBUG BEGIN
    ; print the number in hex

        mov eax, [esp]
        test eax, eax
        jz debug_start_print_hex

        push ecx
        push minus
        call printf
        add esp, 4
        pop ecx

        debug_start_print_hex:
        
        mov esi, edi
        sub esi, ecx
        
        xor edx, edx
        debug_print_hex:
            mov dl, [esi]
            push ecx
            push edx
            push hex_format
            call printf
            add esp, 8
            pop ecx
            inc esi
            cmp esi, edi
            jl debug_print_hex

        push newline
        call puts
        add esp, 4

    ; DEBUG END

    add esp, 12

    ret
