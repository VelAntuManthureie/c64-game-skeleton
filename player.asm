#define __PLAYER__

#importif !__CONFIGURATION__ "configuration.asm"
#importif !__CONTROLS_JOYSTICK__ "controls/joystick.asm"

.namespace player{
    .label PLR_WALK_LEFT = 1
    .label PLR_WALK_RIGHT = 2
    .label PLR_WALK_UP = 4
    .label PLR_WALK_DOWN = 8
    .label PLR_DEAD = 16

    stamina:
        .byte 0
    position_x:
        .byte 0
    position_y:
        .byte 0
    heading_x:
        .byte 0
    heading_y:
        .byte 0
    is_firing:
        .byte 0
    state_id:
        .byte PLR_DEAD
    state-offset:
        .byte 0

    .macro @player_update(){
        :read_joystick()
    update_position_x:    
        lda position_x
        tax
        //update x-position with respect to control data
        clc
        adc heading_x
        sta position_x
    update_wlk_lr:
        //update walking state (right or left)
        txa
        bmi !+
        lda #PLR_WALK_RIGHT
        jmp !++ 
    !:
        lda #PLR_WALK_LEFT
    !:
        sta update__state
    update_position_y:
        lda position_y
        tax
        //update y-position with respect to control data
        clc
        adc heading_y
        sta position_y
    update_wlk_ud:
        //update walking state (down or up)
        txa
        bmi !+
        lda #PLR_WALK_DOWN
        jmp !++ 
    !:
        lda #PLR_WALK_UP
    !:
        sta update__state

    check_player_dead:
        //check stamina: if zero => set DEAD state
        lda stamina
        beq update_state
        //check if position 'is deadly'
        ldx player.position_x
        ldy player.position_y
        :map_is_position_deadly()
        beq update_state
    set_player_dead:
        lda #PLR_DEAD
        sta update__state

    update_state:
        jsr update

    check_player_firing:
        lda player.is_firing
        bne check_player_firing_ok
    check_player_firing_ko:
        jmp !+
    check_player_firing_ok:
        jsr player.on_firing
    !:
    }

    //get info from controls
    .macro read_joystick(){
        //read actual game_port from configuration
        lda configuration.GAME_PORT
        //set as joystick read subroutine parameter
        sta controls_joystick.read__selected_port
        //invoke subroutine
        jsr controls_joystick.read
        lda controls_joystick.read__dx
        //set player heading
        sta player.heading_x
        lda controls_joystick.read__dy
        sta player.heading_y
        //set fire state
        lda controls_joystick.read__fire_pressed
        sta player.is_firing
    }

    //update_state subroutine
    update__state:
        .byte 0         //input
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
    
    //handle player fire
    on_firing:
        rts
}