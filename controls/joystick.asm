#define __CONTROLS_JOYSTICK__

.namespace controls_joystick{
    .const PORT_BASE = $dc00
    /**
      read subroutine
      @see https://codebase64.org/doku.php?id=base:joystick_input_handling
    */
    // input (0 => port 1, 1 => port 2)
    read__selected_port:
        .byte $00     
    //output
    read__dx:
        .byte 0
    read__dy:
        .byte 0
    read__fire_pressed:
        .byte 0
    read:
        djrr:
            ldx read__selected_port
            lda PORT_BASE, x //read port 'x' state () into accumulator
        djrrb:
            ldy #0        // this routine reads and decodes the
            ldx #0        // joystick/firebutton input data in
            lsr           // the accumulator. this least significant
            bcs djr0      // 5 bits contain the switch closure
            dey           // information. if a switch is closed then it
        djr0:
            lsr           // produces a zero bit. if a switch is open then
            bcs djr1      // it produces a one bit. The joystick dir-
            iny           // ections are right, left, forward, backward
        djr1:
            lsr           // bit3=right, bit2=left, bit1=backward,
            bcs djr2      // bit0=forward and bit4=fire button.
            dex           // at rts time dx and dy contain 2's compliment
        djr2:
            lsr           // direction numbers i.e. $ff=-1, $00=0, $01=1.
            bcs djr3      // dx=1 (move right), dx=-1 (move left),
            inx           // dx=0 (no x change). dy=-1 (move up screen),
        djr3:
            lsr           // dy=1 (move down screen), dy=0 (no y change).
            stx read__dx  // the forward joystick position corresponds
            sty read__dy  // to move up the screen and the backward
                          // position to move down screen.
            lda #0
            sta read__fire_pressed
            bcs !+        // The carry flag contains the fire
                          // button state. if c=1 then button not pressed.
                          // if c=0 then pressed.
        set_fp:
            inc read__fire_pressed
        !:
            clc
            rts
}
 