; 2022 ��� ����
; ������� ������ 1���-49�
; ����������: ���������������� �����������������
; ���������������: ������� ����� SDK 1.1
;

$Mod812 ; �������� ����, ���������� ������� ����������������
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;
; ����� ������������� �������, ������������ �������������
calwr equ 0a0h
calrd equ 0a1h
i2cack equ 0

; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;
        LJMP START ; ������� �� ������ ���������
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;
        
        ; ����� ������������� ����������� ����������
        
        
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;
        ORG 80h ; ����� ������ ���������
START:  ; ����� ������ ���������
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;

        ; ����� ������������� ���������� ��������� ���������
        ; ����� ������, �������� ��� ����� ����� !!!
mov dpp, #8
mov dph, #0
mov dpl, #0
mov i2ccon, #0c8h

mov r3, #0
mov r4, #0

loop:
    mov a, #0feh
    movx @dptr, a
    movx a, @dptr
    anl a, #010h
    jz pressed_1
    mov a, #0fch
    movx @dptr, a
    movx a, @dptr    
    anl a, #010h
    jz pressed_2
    sjmp loop

pressed_1:
    lcall read_cal
    mov a, r3
    anl a, #03fh
    cjne a, #031h, mark
    sjmp loop
mark:
    mov a, r3
    anl a, #00fh
    cjne a, #09h, mark2
    mov a, r3
    add a, #07h
    mov r3, a
    sjmp final
mark2:
    inc r3
final:
    lcall write_cal
    sjmp loop
    
pressed_2:
    lcall read_cal
    mov a, r3
    anl a, #03fh
    cjne a, #01h, mark3
    sjmp loop
mark3:
    mov a, r3
    anl a, #00fh
    jnz mark4
    mov a, r3
    subb a, #07h
    mov r3, a
    sjmp final2
mark4:
    dec r3
final2:
    lcall write_cal
    sjmp loop

read_cal:
    lcall i2cstart
    mov a, #calwr
    lcall i2cputa
    mov a, #5
    lcall i2cputa
    lcall i2cstart
    mov a, #calrd
    lcall i2cputa
    lcall i2cgeta
    mov r3, a
    lcall i2csetk1
    lcall i2cstop
    ret

write_cal:
    lcall i2cstart
    mov a, #calwr
    lcall i2cputa
    mov a, #5
    lcall i2cputa
    mov a, r3
    lcall i2cputa
    lcall i2cstop
    ret

i2cstart:
    setb mdo
    lcall d6mcs
    setb mco
    lcall d6mcs
    clr mdo
    lcall d6mcs
    clr mco
    lcall d6mcs
    ret

i2cstop:
    clr mdo
    lcall d6mcs
    setb mco
    lcall d6mcs
    setb mdo
    lcall d6mcs
    clr mco
    lcall d6mcs
    ret

i2cputa:
    mov r6, #8
i2cputa1:
    rlc a
    mov mdo, c
    lcall d6mcs
    setb mco
    lcall d6mcs
    clr mco
    lcall d6mcs
    djnz r6, i2cputa1
    clr mde
    lcall d6mcs
    setb mco
    lcall d6mcs
    mov c, mdi
    mov i2cack, c
    lcall d6mcs
    clr mco
    lcall d6mcs
    setb mde
    mov c, i2cack
    ret

i2cgeta:
    mov r6, #8
    clr mde
i2cgeta1:
    setb mco
    lcall d6mcs
    mov c, mdi
    rlc a
    clr mco
    lcall d6mcs
    djnz r6, i2cgeta1
    setb mde
    ret

i2csetk0:
    clr mdo
    lcall d6mcs
    setb mco
    lcall d6mcs
    clr mco
    lcall d6mcs
    ret

i2csetk1:
    setb mdo
    lcall d6mcs
    setb mco
    lcall d6mcs
    clr mco
    lcall d6mcs
    ret

d6mcs:
    MOV     R0, #1
    DJNZ    R0, $
    RET


; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;
        SJMP $ ; ��������� ����������� ����
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;

        ; XXXXXX - ������������ - XXXXXX ;

; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;
; ������������ �������� �� 250000 ���
D250:
        
        
        
        RET ; ������������ ������� ���������� ������������
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ;
        END ; ������������ ������� ���������� ������
