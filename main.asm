/**
    game skeleton v0.1
        - 1 player
        - maze-like 
            * no platforms
            * no physics
        - 1 life only 
            * no stamina
            * game over if dead
        - no tile-based (for now) 
        - horizontal scrolling
            * VSP implementation
        - no sprite multiplexing (for now)
        - no music (for now)
*/

//import
#import "configuration.asm"
#import "controls/joystick.asm"
#import "player.asm"
#import "npc/actors.asm"

//start: label as entry point for game
:BasicUpstart2(start)

start:
    //setup
    jsr configure
    //intro
    jsr show_intro
//game loop
game_loop:
    :player_update()
    jsr npc_actors.express_behaviour
    jsr update_map
    jsr render
    jsr must_finish
    lda must_finish__ok
    beq game_loop
end:
    jsr show_outro
    jmp start



show_intro:
    rts

configure:
    rts

update_map:
    rts

render:
render_player:
    //render sprite
    // - 
    rts

must_finish__ok:
    .byte 0
must_finish:
    jsr player.check_is_dead
    lda player.is_dead
    sta must_finish__ok
    rts

show_outro:
    rts
