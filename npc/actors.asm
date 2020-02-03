#define __NPC_ACTORS__

#importif !__SYSTEM_ROUTINES__ "/../system/routines.asm"
#importif !__NPC_BEHAVIOURS__ "behaviours.asm"

.namespace npc_actors{
    .const NUMBER = 8
    number:
        .byte NUMBER
    type:
        .fill NUMBER, 0
    behaviour_index:    //depends on type, like a dictionary (low / high)
        .lohifill NUMBER, 0 
    is_dead:
        .fill NUMBER, 0
    position_x:
        .byte NUMBER, 0
    position_y:
        .byte NUMBER, 0
    heading_x:
        .byte NUMBER, 0
    heading_y:
        .byte NUMBER, 0
    is_firing:
        .byte NUMBER, 0
    state_id:
        .byte NUMBER, 0
    state_offset:
        .byte NUMBER, 0

    //check_is_dead subroutine
    check_is_dead__index:
        .byte 0 //input
    check_is_dead:  
        ldx check_is_dead__index
        lda #0  //TO DO
        sta is_dead, x
        rts

    //update subroutine 
    update__state:
        .byte 0     //input 
    update:
        lda update__state
        cmp state_id
        bne new_state
    same_state:
        inc state_offset
        cmp #8
        beq reset_offset
        jmp state_updated
    new_state:
        sta state_id
    reset_offset:
        lda #0
        sta state_offset
    state_updated:
        rts
    
    on_firing:
        lda #(65 + 6)   //"F"
        jsr system_routines.CHROUT 
        rts
    
    express_behaviour:
        ldx #0
        !:
            lda behaviour_index.lo, x
            sta behaviour_fp + 1, x
            lda behaviour_index.hi, x
            sta behaviour_fp + 2, x
            txa 
            sta npc_behaviours.actor_index
            //SELF-MODIFYING CODE
        behaviour_fp:
            .byte $20   //JSR OPCODE
            .byte 0     //BEHAVIOUR ADDRESS (LO)
            .byte 0     //BEHAVIOUR ADDRESSS (HI)
            inx
            cpx #NUMBER
            bne !-
            rts
    
    .macro move_to(actor_index){}
    
}       