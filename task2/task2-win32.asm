section .data
    align 16
    cos_m resd 64
    cos_mt resd 64
    temp resd 64
    
    time dd 0

section .rodata
    eight dd 8.0
    half dd 0.5
    isqrt2 dd 0.707107

section .text
global _fdct, _idct

prepare_cos_matrix:
    mov esi, cos_m ; forward matrix
    mov ecx, 0 ; row index
    pcm_loop_row:
        lea edi, [cos_mt + 4 * ecx] ; inverse matrix
        mov edx, 0 ; column index
        pcm_loop_column:
        
            fldpi
            fdiv dword [eight]
            
            push ecx
            fild dword [esp]
            add esp, 4
            fmulp st1, st0
            
            push edx
            fild dword [esp]
            add esp, 4
            fld dword [half]
            faddp st1, st0
            fmulp st1, st0
            
            fcos
            
            fmul dword [half]
            test ecx, ecx
            jnz pcm_not_zero
                fmul dword [isqrt2]
            pcm_not_zero:
            
            fst dword [esi]
            fstp dword [edi]
            add esi, 4
            add edi, 4 * 8
            
        inc edx
        cmp edx, 8
        jb pcm_loop_column
    inc ecx
    cmp ecx, 8
    jb pcm_loop_row
    ret

; void fdct (float * src, float * dst, int count)
_fdct:
    call prepare_cos_matrix
    
    f_loop0:
    
    mov eax, [esp + 12] ; count
    test eax, eax
    jz f_end
    dec eax
    mov [esp + 12], eax
    
    shl eax, 8 ; eax *= 64 * 4
        
    mov esi, [esp + 4] ; src
    lea esi, [esi + eax] ; src[i]
    mov ecx, 0 ; row index
    f_loop1_row:
        mov edi, cos_m
        mov edx, 0 ; column index
        f_loop1_column:
            
            movups xmm0, [esi]
            movups xmm1, [edi]
            mulps xmm0, xmm1
            
            movups xmm1, [esi + 16]
            movups xmm2, [edi + 16]
            mulps xmm1, xmm2
            
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            
            lea eax, [edx * 8]
            lea eax, [eax * 4]
            movss [eax + ecx * 4 + temp], xmm0
        
        add edi, 32
        inc edx
        cmp edx, 8
        jb f_loop1_column
    add esi, 32
    inc ecx
    cmp ecx, 8
    jb f_loop1_row
    
    mov eax, [esp + 12]
    shl eax, 8
    
    mov ebx, [esp + 8] ; dst
    lea ebx, [ebx + eax]
    mov esi, cos_m
    mov ecx, 0 ; row index
    f_loop2_row:
        mov edi, temp
        mov edx, 0 ; column index
        f_loop2_column:
            
            movups xmm0, [esi]
            movaps xmm1, [edi]
            mulps xmm0, xmm1
            
            movups xmm1, [esi + 16]
            movaps xmm2, [edi + 16]
            mulps xmm1, xmm2
            
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            
            movss xmm1, [eight]
            divss xmm0, xmm1
            movss [ebx], xmm0
            
            add ebx, 4
                    
        add edi, 32
        inc edx
        cmp edx, 8
        jb f_loop2_column
    add esi, 32
    inc ecx
    cmp ecx, 8
    jb f_loop2_row
    
    jmp f_loop0
    
    f_end:
    
    ret

; void idct (float * src, float * dst, int count)
_idct:
    call prepare_cos_matrix
    
    i_loop0:
    
    mov eax, [esp + 12] ; count
    test eax, eax
    jz i_end
    dec eax
    mov [esp + 12], eax
    
    shl eax, 8 ; eax *= 64 * 4
        
    mov esi, [esp + 4] ; src
    lea esi, [esi + eax] ; src[i]
    mov ecx, 0 ; row index
    i_loop1_row:
        mov edi, cos_mt
        mov edx, 0 ; column index
        i_loop1_column:
            
            movups xmm0, [esi]
            movups xmm1, [edi]
            mulps xmm0, xmm1
            
            movups xmm1, [esi + 16]
            movups xmm2, [edi + 16]
            mulps xmm1, xmm2
            
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            
            lea eax, [edx * 8]
            lea eax, [eax * 4]
            movss [eax + ecx * 4 + temp], xmm0
        
        add edi, 32
        inc edx
        cmp edx, 8
        jb i_loop1_column
    add esi, 32
    inc ecx
    cmp ecx, 8
    jb i_loop1_row
    
    mov eax, [esp + 12]
    shl eax, 8
    
    mov ebx, [esp + 8] ; dst
    mov esi, cos_mt
    mov ecx, 0 ; row index
    i_loop2_row:
        mov edi, temp
        mov edx, 0 ; column index
        i_loop2_column:
            
            movups xmm0, [esi]
            movaps xmm1, [edi]
            mulps xmm0, xmm1
            
            movups xmm1, [esi + 16]
            movaps xmm2, [edi + 16]
            mulps xmm1, xmm2
            
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            haddps xmm0, xmm1
            
            movss xmm1, [eight]
            mulss xmm0, xmm1
            movss [ebx], xmm0
            
            add ebx, 4
                    
        add edi, 32
        inc edx
        cmp edx, 8
        jb i_loop2_column
    add esi, 32
    inc ecx
    cmp ecx, 8
    jb i_loop2_row
    
    jmp i_loop0
    
    i_end:
    
    ret
