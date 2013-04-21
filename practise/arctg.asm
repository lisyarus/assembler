; arctg
; x - x^3/3 + x^5/5 - x^7/7 + x^9/9 + ...

section .data
    align 16
    _eights: dd 8.0, 8.0, 8.0, 8.0
    _inits: dd 1.0, 3.0, 5.0, 7.0
    _ones: dd 1.0, 1.0, 1.0, 1.0
    _signs: dd 0, 0x80000000, 0, 0x80000000

section .text
global my_arctg

; float arctg (float x)
my_arctg:    
    push dword [esp + 4]
    push 1.0
    push 1.0
    push 1.0
    
    movups xmm2, [esp]
    add esp, 16
    
    mulps xmm2, xmm2
    
    ; xmm2 = [x^2 1 1 1]
    
    movss xmm1, [esp + 4]
    pshufd xmm1, xmm1, 0
    
    ; xmm1 = [x x x x]
    
    mulps xmm1, xmm2
    pshufd xmm2, xmm2, 256 - 7
    mulps xmm1, xmm2
    pshufd xmm2, xmm2, 256 - 7
    mulps xmm1, xmm2
    pshufd xmm2, xmm2, 256 - 7
    
    mulps xmm2, xmm2
    mulps xmm2, xmm2
    
    xorps xmm1, [_signs]
    
    ; xmm1 = [-x^7 x^5 -x^3 x]
    ; xmm2 = [x^8 x^8 x^8 x^8]
    
    movaps xmm3, [_inits]
    movaps xmm4, [_eights]
    
    ; xmm3 = [7 5 3 1]
    ; xmm4 = [8 8 8 8]
    
    xorps xmm0, xmm0
    
    mov ecx, 1000000
    _loop:
    
        movaps xmm5, xmm1
        divps xmm5, xmm3
        haddps xmm5, xmm5
        haddps xmm5, xmm5
        addps xmm0, xmm5
        
        mulps xmm1, xmm2
        addps xmm3, xmm4
        loop _loop, ecx
        
    movss [esp - 4], xmm0
    fld dword [esp - 4]    
    ret
