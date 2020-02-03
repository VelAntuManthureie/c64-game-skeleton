#define __VIC__

.namespace vic{
    .label VIC = $d000 
    .label SPRITE_0_X           = VIC + $00 
    .label SPRITE_0_Y           = VIC + $01 
    .label SPRITE_1_X           = VIC + $02 
    .label SPRITE_1_Y           = VIC + $03 
    .label SPRITE_2_X           = VIC + $04 
    .label SPRITE_2_Y           = VIC + $05 
    //... etc
    .label BACKGROUND_COLOR     = VIC + $20
    .label BORDER_COLOR     = VIC + $21
}