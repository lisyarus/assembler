extern _puts, _putchar, _malloc, _free

section .data
    usage_msg db "Usage: task1 format number", 0
    unknown_flag_msg db "Unknown flag 'x'", 0
    unknown_flag_pos equ 14
    decimal_number_expected_msg db "Expected a decimal number, got 'x'", 0
    decimal_number_expected_pos equ 32
    hex_number_expected_msg db "Expected a hexadecimal number, got 'x'", 0
    hex_number_expected_pos equ 36
    big_length_msg db "The length must not exceed 50", 0
    long_argument_msg db "Argument too long: the number must not exceed 128 bits", 0

    minus db "-", 0

    flag_space equ 0xff
    flag_plus equ 0xffff
    flag_zero equ 0xff0000
    flag_minus equ 0xffff0000

section .text
global _main

unknown_flag:
    mov [unknown_flag_msg + unknown_flag_pos], dl
    push unknown_flag_msg
    call _puts
    add esp, 4
    ret

decimal_number_expected:
    mov [decimal_number_expected_msg + decimal_number_expected_pos], dl
    push decimal_number_expected_msg
    call _puts
    add esp, 4
    ret

hex_number_expected:
    mov [hex_number_expected_msg + hex_number_expected_pos], dl
    push hex_number_expected_msg
    call _puts
    add esp, 4
    ret

big_length:
    push big_length_msg
    call _puts
    add esp, 4
    ret

long_argument:
    push long_argument_msg
    call _puts
    add esp, 4
    ret

_main:

    mov ecx, [esp + 4]
    cmp ecx, 3
    je arguments_count_good

    push usage_msg
    call _puts
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
        cmp dl, '0'
        je set_flag_zero
        cmp dl, '-'
        je set_flag_minus

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

        set_flag_zero:
            or eax, flag_zero
            jmp read_flags

        set_flag_minus:
            or eax, flag_minus
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

    start_read_number:
        push 32
        call _malloc
        xor ecx, ecx ; the number's length
        
        mov dword [esp], 0 ; will be true if the number starts from a minus
        ; edi is argv
        mov esi, [edi + 8]; esi = argv[2]
        mov edi, eax ; edi is the result of malloc
        push edi ; for later use
        mov dl, [esi]
        cmp dl, '-'
        jne read_number

        mov dword [esp + 4], 0xffffffff
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
        add esp, 16
        ret

        read_number_long_argument:
        call long_argument
        add esp, 16
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

        mov eax, [esp + 4]
        not eax
        mov [esp + 4], eax

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

    push ecx
    push 64
    call _malloc
    add esp, 4
    mov ecx, [esp]
    
    mov [esp], eax ; result string

    mov byte [eax + 63], 0 ; result string end
    lea ebx, [eax + 62]

    ; stack by now:
    ; [esp] result string addr
    ; [esp + 4] hex number addr
    ; [esp + 8] positive/negative
    ; [esp + 12] length
    ; [esp + 16] flag set
    ; [esp + 20] return address

    ; registers:
    ; ecx = (hex number length)
    ; edi = (hex number) + ecx {after the lowest digit}
    ; ebx = {resulting string lowest digit}

    convert:

        mov esi, edi
        sub esi, ecx
        xor edx, edx
        xor eax, eax

        convert_check:
            cmp esi, edi
            je convert_end
            mov dl, [esi]
            test dl, dl
            jnz convert_div
            inc esi
            jmp convert_check

        convert_div:
            cmp esi, edi
            jae convert_div_end
            shl eax, 4
            mov dl, [esi]
            add eax, edx
            xor edx, edx
            push ecx
            mov cx, 10
            div cx
            pop ecx
            mov [esi], al
            mov eax, edx
            inc esi
            jmp convert_div

        convert_div_end

        add al, '0'
        mov [ebx], al
        dec ebx

        jmp convert

    convert_end:

    inc ebx
    ; check for zero
    mov dl, [ebx]
    test dl, dl
    jnz check_not_zero
    dec ebx
    mov byte [ebx], '0'
    mov dword [esp + 8], 0 ; zero is positive

    check_not_zero:

    pop edi
    call _free
    mov [esp], edi

    lea ecx, [edi + 63]
    sub ecx, ebx

    ; [esp + 4] sign
    ; [esp + 8] output length
    ; [esp + 12] flag set

    mov eax, [esp + 4]
    test eax, eax
    jnz add_one_to_length

    mov eax, [esp + 12]
    and eax, flag_plus
    test eax, eax
    jnz add_one_to_length

    jmp not_add_one_to_length

    add_one_to_length:
    inc ecx

    not_add_one_to_length:

    mov eax, [esp + 12]
    and eax, flag_minus
    cmp eax, flag_minus
    jne align_right

    ; align left
    jmp no_align
   
    align_right:

    mov eax, [esp + 12]
    and eax, flag_zero
    cmp eax, flag_zero
    jne align_spaces

    ; align zeroes
    mov edi, [esp + 8]
    sub edi, ecx
    jl no_align
    call put_sign
    push edi
    push dword '0'
    call put_filler
    mov [esp], ebx
    call _puts
    add esp, 8
    jmp end

    align_spaces:

    mov edi, [esp + 8]
    sub edi, ecx
    jl no_align
    push edi
    push dword ' '
    call put_filler
    add esp, 8
    call put_sign
    push ebx
    call _puts
    add esp, 4
    jmp end

    no_align:
    call put_sign
    push ebx
    call _puts
    add esp, 4

    end:

    call _free
    add esp, 16
    ret

; [esp + 8] sign
; [esp + 16] flags
put_sign:
    mov eax, [esp + 8]
    test eax, eax
    jz put_sign_positive

    push dword '-'
    jmp put_sign_do

    put_sign_positive:

    mov eax, [esp + 16]
    and eax, flag_plus
    cmp eax, flag_plus
    je put_sign_plus
    cmp eax, flag_space
    je put_sign_space

    ret

    put_sign_plus:
    push dword '+'
    jmp put_sign_do

    put_sign_space:
    push dword ' '

    put_sign_do:
    call _putchar
    add esp, 4
    ret

; [esp + 4] filler
; [esp + 8] count
put_filler:
    mov ecx, [esp + 8]
    test ecx, ecx
    jz put_filler_end
    dec ecx
    mov [esp + 8], ecx
    push dword [esp + 4]
    call _putchar
    add esp, 4
    jmp put_filler
    put_filler_end:
    ret
