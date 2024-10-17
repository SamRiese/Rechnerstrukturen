.section .data
.syntax unified

.equ RCGC_GPIO_R, 0x400FE608
.equ RCGC_GPIO_PORT_A, 0x01
.equ RCGC_GPIO_PORT_B, 0x02
.equ RCGC_GPIO_PORT_C, 0x04
.equ RCGC_GPIO_PORT_D, 0x08
.equ RCGC_GPIO_PORT_E, 0x10
.equ RCGC_GPIO_PORT_F, 0x20

.equ GPIO_PORT_F_DATA_R, 0x400253FC
.equ GPIO_PORT_F_DEN_R,  0x4002551C
.equ GPIO_PORT_F_DIR_R,  0x40025400
.equ GPIO_PORT_F_PUR_R,  0x40025510

.equ GPIO_PORT_D_DATA_R, 0x400253FC
.equ GPIO_PORT_D_DEN_R,  0x4002551C
.equ GPIO_PORT_D_DIR_R,  0x40025400
.equ GPIO_PORT_D_PUR_R,  0x40025510

.equ PIN0, 0x01
.equ PIN1, 0x02
.equ PIN2, 0x04
.equ PIN3, 0x08
.equ PIN4, 0x10
.equ PIN5, 0x20
.equ PIN6, 0x40
.equ PIN7, 0x80
.equ ALL_PINS, 0xFF

.section .text
.global main
.align

main:   
init_hardware:
    @Konfiguriere GPIO Register siehe 657 / 662 / 338
    
    @Konfiguriere Clock siehe 338 / D=5 und F=3
    LDR r0, =(RCGC_GPIO_PORT_F | RCGC_GPIO_PORT_D) @Kombination durch bitwise OR
    LDR r1, =RCGC_GPIO_R
    STR r0, [r1]

    @Pin F4 = Button SW1 | vermutlich active low button
    @Konfiguriere Pin F4 als digital Pin. Modus 1 oder 0 
    LDR r0, =PIN4
    LDR r1, =GPIO_PORT_F_DEN_R
    STR r0, [r1]
    
    @Konfiguriere Pin F4 als Input 
    LDR r2, #0
    LDR r1, =GPIO_PORT_F_DIR_R
    STR r2, [r1]

    @Konfiguriere Pin F4 | Pullup bzw. Standartwert = 1 | Dokumentation Standartwert -> 0 
    LDR r1, =GPIO_PORT_F_PUR_R
    STR r0, [r1]
    
    @Pin Dx = LED
    @Konfiguriere Pin D2 als digital Pin. Modus 1 oder 0 
    LDR r0, =PIN2 @hier Pin für LED ändern
    LDR r1, =GPIO_PORT_D_DEN_R
    STR r0, [r1]

    @Konfiguriere Pin D2 als Input 
    LDR r1, =GPIO_PORT_D_DIR_R
    STR r0, [r1]   
    

endless_loop:
    LDR r0, #0

    timer:
        ADD r0, #1
        CMP r0, #33000
        BGT timer

    LDR r1, =GPIO_PORT_F_DATA_R @lade pointer
    LDR r2, [r1] @dereference pointer 
    AND r3, r2, =PIN4

    CMP r3 #0
    BEQ handle_btn_pressed

handle_btn_not_pressed:
    LDR r1, #0
    LDR r2, =GPIO_PORT_D_DATA_R
    STR r1, [r2]
    b endless_loop

handle_btn_pressed:
    LDR r1, PIN2
    LDR r2, =GPIO_PORT_D_DATA_R
    STR r1, [r2]
    b endless_loop
.end
