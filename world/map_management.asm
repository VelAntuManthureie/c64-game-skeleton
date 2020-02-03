#define __MAP_MGMT__

#importif ! __SYSTEM_MEMORY__ "../system/memory.asm"
#importif ! __MAP_DATA__ "map_data.asm"  

.namespace map_management{
    /*
        position_to_map_info subroutine:
        description:
            - converts logical (x, y) position on map to tile reference in form (tile_index, offset_x, offset_y)
        input: 
            - x: logical x-position
            - y: logical y-position 
        output: 
            - map_x: tile x-coordinate in map 
            - map_y: tile y-coordinate in map
            - offset_x: x-offset in tile
            - offset_y: y-offset in tile
            - tile_index: index in tileset
            - tile_offset: offset in tileset
    */
    .label TILE_WIDTH = map_data.TILE_WID
    .label TILE_WIDTH_L2 = map_data.TILE_WID_L2
    .label TILE_HEIGTH = map_data.TILE_HEI
    .label TILE_HEIGTH_L2 = map_data.TILE_HEI_L2
    .label MAP_WIDTH_L2 = map_data.MAP_WID_L2
    position_to_map_info: {
        lda input.x
        clc
        .for (var i = 0; i < TILE_WIDTH_L2; i++){
            lsr
        }
        sta output.map_x
        txa
        and #(TILE_WIDTH - 1)
        sta output.offset_x
        lda input.y
        clc
        .for (var i = 0; i < TILE_WIDTH_L2; i++){
            lsr
        }
        sta output.map_y
        txa
        and #(TILE_WIDTH - 1)
        sta output.offset_y
        lda output.map_y
        .for (var i = 0; i < MAP_WIDTH_L2; i++){
            asl
        }
        clc 
        adc output.map_x
        tax
        lda map_data.map_data, x
        sta output.tile_index
        lda output.offset_y
        .for (var i = 0; i < TILE_WIDTH_L2; i++){
            asl
        }
        clc
        adc output.offset_x
        sta output.tile_offset
        lda output.tile_index
        .for (var i = 0; i < TILE_WIDTH_L2 + TILE_HEIGTH_L2; i++){
            asl
        }
        clc
        adc output.tile_offset
        sta output.char_offset
        lda #<output
        sta output.pointer
        lda #>output
        sta output.pointer + 1
        rts
        //params
        input: {
            x:
                .byte 0
            y:
                .byte 0
        }
        output: {
            map_x:
                .byte 0
            offset_x:
                .byte 0
            map_y:
                .byte 0
            offset_y:
                .byte 0
            tile_index:
                .byte 0
            tile_offset:
                .byte 0
            char_offset:
                .byte 0
            pointer:
                .word 0
        }
    }
    /*
        get_char_index subroutine:
        input: 
            - map_x: tile x-coordinate in map 
            - map_y: tile y-coordinate in map
            - offset_x: x-offset in tile
            - offset_y: y-offset in tile
            - tile_offset: offset in tileset
        output:
            - index: char index in charset
    */
    .label MAP_POINTER = memory.ZP_4
    .label TILESET_POINTER = memory.ZP_5
    .label TILE_SIZE_L2 = map_data.MAP_WID_L2 + map_data.MAP_HEI_L2;
    get_char_index:{
        get_tile_index:
            lda #<map_data.map_data
            sta MAP_POINTER
            lda #>map_data.map_data
            sta MAP_POINTER + 1
            lda #<map_data.tileset_data
            sta TILESET_POINTER
            lda #>map_data.tileset_data + 1
            sta TILESET_POINTER + 1
            lda input.map_y
            .for(var i = 0; i < MAP_WIDTH_L2; i++){
                asl
            }
            clc
            adc input.map_x
            tay
            lda (MAP_POINTER), y  //tile index
            .for(var i = 0; i < TILE_SIZE_L2; i++){
                asl
            }
            adc TILESET_POINTER
            sta TILESET_POINTER 
            bcc !+
            inc TILESET_POINTER + 1 //contains start address of i-th tile
        !:
        get_char_index:
            lda input.offset_y
            clc
            .for(var i = 0; i < TILE_WIDTH_L2; i++){
                asl
            }
            adc input.offset_x
            tay
            lda (TILESET_POINTER), y
            sta output.char_index
        rts
        //params
        input: {
            map_x:
            .byte 0
            offset_x:
                .byte 0
            map_y:
                .byte 0
            offset_y:
                .byte 0
        }
        output: {
            char_index:
                .byte 0
        }
    }
    /*
        get_char_type subroutine:
        input: 
            - char_index : index of char
        output:
            - char_type : type of char
    */
    get_char_type: {
        ldx input.char_index
        lda char_types, x
        sta output.char_type
        rts
        //params
        input: {
            char_index:
                .byte 0
        }
        output: {
            char_type:
                .byte 0
        }
    }
    char_types: { /* TO DO */}


    .pseudocommand @set_map_addresses{
        .for (var i = 0; i < map_data.SZ_MAP_DATA; i++){
            lda #<[map_data.map_data + i]
            sta map_data.map_addresses.lo + i
            lda #>[map_data.map_data + i]
            sta map_data.map_addresses.hi + i
        }
    }
    .pseudocommand @set_tile_addresses{
        .break
        .for (var i = 0; i < map_data.TILE_COUNT; i++){
            lda #<[map_data.tileset_data + i * map_data.TILE_WID * map_data.TILE_HEI]
            sta map_data.tileset_addresses.lo + i
            lda #>[map_data.tileset_data + i * map_data.TILE_WID * map_data.TILE_HEI]
            sta map_data.tileset_addresses.hi + i
        }
    }
/*
    test:{
        * = $c000
        .watch position_to_map_info.output.map_x
        .watch position_to_map_info.output.map_y
        .watch position_to_map_info.output.offset_x
        .watch position_to_map_info.output.offset_y
        .watch position_to_map_info.output.tile_index
        .watch position_to_map_info.output.tile_offset
        .break
        lda #7
        sta position_to_map_info.input.x
        sta position_to_map_info.input.y
        jsr position_to_map_info
        rts
    }
*/
}