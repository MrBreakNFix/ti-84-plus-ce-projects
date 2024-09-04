include 'include/ez80.inc'
include 'include/tiformat.inc'
include 'include/ti84pceg.inc'

format ti archived executable protected program 'CLOCK'

main:
    call ti.ChkFindSym  
    call ti.ChkInRam    ;   Check to see whether the current value in DE resides in the RAM location of the calculator. This has replaced the usual archive check for ChkFindSym, so use this instead.
    call z,ti.Arc_Unarc
    call ti.ChkFindSym

    ; find the start of the hook
    sbc hl,hl                ; clear hl
    ld l,c                   ; l = c
    add hl,de                ; hl = hl + de
    ld de, 14 + hook - main  ; de = 13 + hook - main, 13 is needed because of the asm header token before main
    add hl,de                ; hl = hl + de

    call ti.SetGetCSCHook ; enable the hook
    ret

hook: 
    db $83 
    cp a,$1a 
    ld a,b
    ret nz 
    
    ; prints time

    ld de, ti.OP6
    push de

    set ti.useTokensInString, (iy + ti.clockFlags) ; use charachters instead of tokens when displaying clock as string
    call ti.FormTime


    ;   .sis indicates a 16-bit (short) mode instruction with a 16-bit parameter
    ld.sis de, (ti.statusBarBGColor - ti.ramStart)  ; puts the current background color of the status bar in de
    ld.sis (ti.drawBGColor - ti.ramStart), de ; puts de as the background color of the clock, 

    ld hl, 2       ; set column to 260 (fits within 16 bit register)
    ld (ti.penCol), hl  ; penCol is 
    ld a, 16        ; set row to 16 (fits within 8 bit register)
    ld (ti.penRow), a

    ; save value of drawFGColor, so we can restore it  

    ld de, (ti.drawFGColor - ti.ramStart)

    ld hl, $FFFF    ; set drawFGColor to white
    ld.sis (ti.drawFGColor - ti.ramStart), hl  

    pop hl
    call ti.VPutS
    call ti.SetWhiteDrawBGColor

    ld.sis (ti.drawFGColor - ti.ramStart), de    ; restore drawFGColor
    ; end prints times

    ld a,$1a 
    or a 
    ret
