#define __MAP_DATA__

.namespace map_data{
    // Generated by CharPad 2. Assemble with 64TASS or similar.
    // General constants:-
    .label TRUE = 1
    .label FALSE = 0
    .label COLRMETH_GLOBAL = 0
    .label COLRMETH_PERTILE = 1
    .label COLRMETH_PERCHAR = 2

    // Project constants:-
    .label COLOURING_METHOD = COLRMETH_GLOBAL
    .label CHAR_MULTICOLOUR_MODE = TRUE
    .label COLR_SCREEN = 9
    .label COLR_CHAR_DEF = 3
    .label COLR_CHAR_MC1 = 0
    .label COLR_CHAR_MC2 = 1
    .label CHAR_COUNT = 4
    .label TILE_COUNT = 4
    .label TILE_WID = 4
    .label TILE_WID_L2 = 2
    .label TILE_HEI = 4
    .label TILE_HEI_L2 = 2
    .label MAP_WID = 2
    .label MAP_WID_L2 = 1
    .label MAP_HEI = 2
    .label MAP_HEI_L2 = 1
    .label MAP_WID_CHRS = 8
    .label MAP_HEI_CHRS = 8
    .label MAP_WID_PXLS = 64
    .label MAP_HEI_PXLS = 64

    // Data block sizes (in bytes):-
    .label SZ_CHARSET_DATA        = 32
    .label SZ_CHARSET_ATTRIB_DATA = 4
    .label SZ_TILESET_DATA        = 64
    .label SZ_MAP_DATA            = 4

    // Data block addresses (dummy values):-
    .label ADDR_CHARSET_DATA        = $1000   // nb. label = 'charset_data'        (block size = $20).
    .label ADDR_CHARSET_ATTRIB_DATA = $2000   // nb. label = 'charset_attrib_data' (block size = $4).
    .label ADDR_TILESET_DATA        = $3000   // nb. label = 'tileset_data'        (block size = $40).
    .label ADDR_MAP_DATA            = $5000   // nb. label = 'map_data'            (block size = $4).

    // CHAR SET DATA : 4 (8 byte) chars : total size is 32 ($20) bytes.
    * = ADDR_CHARSET_DATA
    charset_data:
        .byte $00,$08,$18,$08,$08,$08,$1c,$00,$00,$18,$24,$04,$08,$10,$3c,$00
        .byte $00,$3c,$04,$08,$18,$04,$3c,$00,$00,$08,$18,$28,$7c,$08,$08,$00

    // CHAR SET ATTRIBUTE DATA : 4 attributes : total size is 4 ($4) bytes.
    // nb. Upper nybbles = Material, Lower nybbles = Colour.
    * = ADDR_CHARSET_ATTRIB_DATA
    charset_attrib_data:
        .byte $00,$00,$00,$00

    // TILE SET DATA : 4 (4x4) tiles : total size is 64 ($40) bytes.
    * = ADDR_TILESET_DATA
    tileset_data:
        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
        .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
        .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    tileset_addresses:
        .lohifill TILE_COUNT, 0
        /* 
            eq. to:
                tileset_addresses.lo: .fill TILE_COUNT, 0
                tileset_addresses.hi: .fill TILE_COUNT, 0
        */

    // MAP DATA : 1 (2x2) map : total size is 4 ($4) bytes.
    * = ADDR_MAP_DATA
    map_data:
        .byte $00,$01
        .byte $02,$03
    map_addresses:
        .lohifill SZ_MAP_DATA, 0
}