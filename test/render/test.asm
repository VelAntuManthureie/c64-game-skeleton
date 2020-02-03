#import "map_data.asm"

* = $c000
main:{
    lda #1
    sta test_map.get_char__map_x
    lda #0
    sta test_map.get_char__map_y
    lda #0
    sta test_map.get_char__offset_x
    lda #0
    sta test_map.get_char__offset_y
    jsr test_map.get_char
    lda test_map.get_char__char
    stop:
        jmp stop
    rts
}
test_map:{
    .label MAP_L2 = map.MAP_WID >> 1
    .label TILE_L2 = (map.TILE_WID * map.TILE_HEI) >> 2
    .label CHAR_L2 = map.TILE_WID >> 1
    .label ZP0 = $fb
    .label ZP1 = ZP0 + 2
    .label MAP_POINTER = ZP0
    .label TILESET_POINTER = ZP1

    get_char__map_x:
        .byte 0
    get_char__offset_x:
        .byte 0
    get_char__map_y:
        .byte 0
    get_char__offset_y:
        .byte 0
    get_char__char_index:
        .byte 0
    get_char:
        get_tile_index:
            lda #<map.map_data
            sta MAP_POINTER
            lda #>map.map_data
            sta MAP_POINTER + 1
            lda #<map.tileset_data
            sta TILESET_POINTER
            lda #>map.tileset_data + 1
            sta TILESET_POINTER + 1
            lda get_char__map_y
            .for(var i = 0; i < MAP_L2; i++){
                asl
            }
            clc
            adc get_char__map_x
            tay
            lda (MAP_POINTER), y  //tile index
            .for(var i = 0; i < TILE_L2; i++){
                asl
            }
            adc TILESET_POINTER
            sta TILESET_POINTER 
            bcc !:
            inc TILESET_POINTER + 1 //contains start address of i-th tile
        !:
        get_char_index:
            lda get_char__offset_y
            clc
            .for(var i = 0; i < CHAR_L2; i++){
                asl
            }
            adc get_char__offset_x
            tay
            lda (TILESET_POINTER), y
            sta get_char__char_index
        rts
}