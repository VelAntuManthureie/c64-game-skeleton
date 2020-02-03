#define __NPC_BEHAVIOURS__

#importif !__PLAYER__ "../player.asm"
#importif !__NPC_ACTORS__ "actors.asm"

.namespace npc_behaviours{
    actor_index:
        .byte 0
behaviours:
    goofy_monster: {
        ldx player.position_x
        ldy player.position_y
        lda actor_index
        sta npc_actors.move_to__index
        jsr npc_actors.move_to
        rts
    }
    clever_monster: {
        rts
    }
    move_to:
        rts
}