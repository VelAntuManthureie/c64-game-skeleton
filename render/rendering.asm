#define __RENDERING__

#importif !__SYSTEM_MEMORY__ "../system/memory.asm"
#importif !__MAP_MGMT__ "../world/map_management.asm"
#importif !__MAP_DATA__ "../world/map_data.asm"

.namespace rendering{
    .label VIEWPORT_H = 0
    .label VIEWPORT_V = 0
    .label VIEWPORT_WIDTH = 4
    .label VIEWPORT_HEIGTH = 4

    /*
        render_viewport subroutine:
            - input:
                - center_x:
                - center_y:
            - output:
                to video buffer
    */
    render_viewport: {
        // get uppermost left coords
        lda input.center_x
        sec
        sbc #(VIEWPORT_WIDTH / 2)
        sta map_management.position_to_map_info.input.x
        lda input.center_y
        sec
        sbc #(VIEWPORT_HEIGTH / 2)
        sta map_management.position_to_map_info.input.y
        jsr map_management.position_to_map_info
        // copy result to mi_from
        ldx #0
        !:
        lda map_management.position_to_map_info.output, x
        sta render_tiles.input.mi_from, x
        inx
        cpx #9
        bne !-
        // get lowermost right coords
        lda input.center_x
        clc
        adc #(VIEWPORT_WIDTH / 2)
        sta map_management.position_to_map_info.input.x
        lda input.center_y
        clc
        adc #(VIEWPORT_HEIGTH / 2)
        sta map_management.position_to_map_info.input.y
        jsr map_management.position_to_map_info
        // copy result to mi_to
        ldx #0
        !:
        lda map_management.position_to_map_info.output, x
        sta render_tiles.input.mi_to, x
        inx
        cpx #9
        bne !-
        // invoke render_tiles
        jsr render_tiles
        rts   
        //params
        input: {
            center_x:
                .byte 0
            center_y:
                .byte 0
        }
    }
    /*
        render_tiles subroutine:
            - input:
                - mi_from:
                - mi_to:
            - output:
                to video buffer
    */
    .label TILE_BUFFER_POINTER = memory.ZP_4
    .label VIDEO_BUFFER_POINTER =  memory.ZP_5
    .label TILE_WIDTH = map_data.TILE_WID
    .label TILE_WIDTH_L2 = map_data.TILE_WID_L2
    .label TILE_HEIGTH = map_data.TILE_HEI
    .label TILE_HEIGTH_L2 = map_data.TILE_HEI_L2
    render_tiles:{
        lda #0
        sta current_col
        sta current_row
        //copy mi_from to mi_current (cursor over map structure)
        ldx #0
        !:
        lda input.mi_from, x
        sta mi_current, x
        inx
        cpx #9
        bne !-
        lda #TILE_WIDTH
        sta mi_current.x_steps
        lda #TILE_HEIGTH
        sta mi_current.y_steps
        set_tile_for_render:
        set_tile_buffer_pointer:
            lda #<map_data.tileset_data
            clc
            adc mi_current.char_offset
            sta TILE_BUFFER_POINTER
            lda #>map_data.tileset_data
            sta TILE_BUFFER_POINTER + 1
            bcc set_video_buffer_pointer
            inc TILE_BUFFER_POINTER + 1
        set_video_buffer_pointer:
            lda current_col
            clc
            adc current_row 
            sta VIDEO_BUFFER_POINTER
            lda VIDEO_BUFFER_POINTER + 1
            clc
            adc current_row + 1
            sta VIDEO_BUFFER_POINTER + 1
        render_tile: { 
            ldy mi_current.offset_x
            ldx mi_current.offset_y
            do_render:
                lda (TILE_BUFFER_POINTER), y
                sta (VIDEO_BUFFER_POINTER), y
            //increment column count
            traverse_column:
                iny
                cpy mi_current.x_steps //(TILE_WIDTH - mi_current.offset_x)
                bne do_render
            //increment row (tile buffer and video buffer)
            traverse_row:
                // reset offset_x
                ldy mi_current.offset_x
                //(tile buffer - with carry)
                clc
                lda TILE_BUFFER_POINTER
                adc #TILE_WIDTH
                sta TILE_BUFFER_POINTER
                bcc !+
                inc TILE_BUFFER_POINTER + 1
                !:
                clc 
                lda VIDEO_BUFFER_POINTER
                adc #40
                sta VIDEO_BUFFER_POINTER
                bcc !+
                inc VIDEO_BUFFER_POINTER + 1
                //increment row count
                !:
                inx
                cpx mi_current.y_steps //(TILE_HEIGTH - mi_current.offset_y)
                bne do_render

        }
        //increment mi_current
        inc_mi_current:{
            h: {
                inc mi_current.map_x
                lda input.mi_to.map_x
                cmp mi_current.map_x
                bmi v
                //beq adjust_with_offset_x
                lda #0
                sta mi_current.offset_x
                lda #TILE_WIDTH
                sta mi_current.x_steps
                //jmp adjust
                //adjust_with_offset_x:
                //lda #TILE_WIDTH
                //sec
                //sbc input.mi_to.offset_x
                //(x_steps = TILE_WIDTH - offset_x)
                //sta mi_current.x_steps
                adjust:
                //adjust tile index
                lda mi_current.map_y
                .for (var i = 0; i < map_management.MAP_WIDTH_L2; i++){
                    asl
                }
                clc
                adc mi_current.map_x
                tax
                lda map_data.map_data, x
                sta mi_current.tile_index
                //adjust tile offset
                lda mi_current.offset_y
                .for(var i = 0; i < map_management.TILE_WIDTH_L2; i++){
                    asl
                }
                clc
                adc mi_current.offset_x
                sta mi_current.tile_offset
                //adjust char_offset
                lda mi_current.tile_index
                .for (var i = 0; i < TILE_WIDTH_L2 + TILE_HEIGTH_L2; i++){
                    asl
                }
                clc
                adc mi_current.tile_offset
                sta mi_current.char_offset
                adjust_next_tile:
                lda current_row
                beq !+
                sbc #(40 * TILE_HEIGTH)
                beq !+
                dec current_row + 1
                !:
                lda current_col
                adc #TILE_WIDTH
                sta current_col
                jmp set_tile_for_render
            }
            v: {
                //.break
                lda #0
                sta mi_current.map_x
                inc mi_current.map_y
                lda input.mi_to.map_y
                cmp mi_current.map_y
                bmi tiles_rendered
                //beq adjust_with_offset_y
                lda #TILE_HEIGTH
                sta mi_current.y_steps
                //jmp adjust
                //adjust_with_offset_y:
                //lda #TILE_HEIGTH
                //sec
                //sbc input.mi_to.offset_y
                //(y_steps = TILE_HEIGTH - offset_y)
                //sta mi_current.y_steps
                adjust:
                //adjust tile index
                lda mi_current.map_y
                .for (var i = 0; i < map_management.MAP_WIDTH_L2; i++){
                    asl
                }
                clc
                adc mi_current.map_x
                tax
                lda map_data.map_data, x
                sta mi_current.tile_index
                //adjust tile offset
                lda mi_current.offset_y
                .for(var i = 0; i < map_management.TILE_WIDTH_L2; i++){
                    asl
                }
                clc
                adc mi_current.offset_x
                sta mi_current.tile_offset
                //adjust char_offset
                lda mi_current.tile_index
                .for (var i = 0; i < TILE_WIDTH_L2 + TILE_HEIGTH_L2; i++){
                    asl
                }
                clc
                adc mi_current.tile_offset
                sta mi_current.char_offset
                lda current_col
                sec
                sbc #TILE_WIDTH
                sta current_col
                lda current_row
                clc
                adc #(40 * TILE_WIDTH)
                sta current_row
                bcc !+
                inc current_row + 1
                !:
                jmp set_tile_for_render
            }
        }
        tiles_rendered:
        rts
        current_col:
            .byte 0
        current_row:
            .byte 0, 0
        mi_current: {
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
                .byte 0, 0
            x_steps:
                .byte 0
            y_steps:
                .byte 0
        }
        input: {
            mi_from: {
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
            mi_to: {
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
    }
    .pseudocommand render_region position_x : position_y {
        
    }
    .pseudocommand render_tile tile_index : col_from : col_to : row_from : row_to {
        .label VIDEO_LINE = 40
        .label ROW_COUNTER = memory.ZP_0
        ldx tile_index
        lda map_data.tileset_addresses.lo, x
        sta TILE_BUFFER_POINTER
        lda map_data.tileset_addresses.hi, x
        sta TILE_BUFFER_POINTER + 1
        lda row_from
        sta ROW_COUNTER
        render_row:
        .for(var i = 0; i < map_data.TILE_HEI_L2; i++){
            asl
        }
        clc
        adc TILE_BUFFER_POINTER
        bcc render_col
        inc TILE_BUFFER_POINTER + 1
        render_col:
        ldy col_from
        !:
        lda (TILE_BUFFER_POINTER), y
        sta (VIDEO_BUFFER_POINTER), y
        iny
        cpy col_to
        bne !-
        lda VIDEO_BUFFER_POINTER
        clc
        adc #VIDEO_LINE
        sta VIDEO_BUFFER_POINTER
        bcc !+
        inc VIDEO_BUFFER_POINTER + 1
        !:
        inc ROW_COUNTER
        lda ROW_COUNTER
        cmp row_to
        bpl end
        jmp render_row 
        end:
    }

    test: {
        .label VIDEO_PAGE = $0400 //video bank 1
        .label SCREEN_START = VIDEO_PAGE + (40 * VIEWPORT_V + VIEWPORT_H) 
        /*
        .watch render_tiles.current_row
        .watch render_tiles.current_row + 1
        .watch render_tiles.current_col
        .for (var i = 0; i < 11; i++){
            .watch render_tiles.mi_current + i
        }
        .for (var i = 0; i < 11; i++){
            .watch render_tiles.input.mi_to + i
        }
        */

        * = $c000
        lda #0
        sta $d020
        sta $d021
        lda #<map_data.tileset_data
        sta TILE_BUFFER_POINTER
        lda #>map_data.tileset_data
        sta TILE_BUFFER_POINTER + 1
        lda #<SCREEN_START
        sta VIDEO_BUFFER_POINTER
        lda #>SCREEN_START
        sta VIDEO_BUFFER_POINTER + 1

        .watch TILE_BUFFER_POINTER
        .watch TILE_BUFFER_POINTER + 1
        .watch VIDEO_BUFFER_POINTER
        .watch VIDEO_BUFFER_POINTER + 1

        .watch map_data.tileset_addresses

        :set_map_addresses
        :set_tile_addresses
        ldx #0
        
    

        :render_tile #0 : #0 : #4 : #0 : #4
        
        /*
        lda #2
        sta render_viewport.input.center_x
        sta render_viewport.input.center_y
        jsr render_viewport
        */
        jmp *
        rts
    }
}

