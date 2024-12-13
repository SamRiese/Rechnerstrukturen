.section .data
.syntax unified
.thumb

// definiert BIT0 bis BIT31
.altmacro
.macro define_bit a
    .equ BIT\a, (1 << \a)
.endm

.set i, 0
.rept 32
    define_bit %i
    .set i,i+1
.endr

.equ RCGC_GPIO_R, 0x400FE608
.equ RCGC_GPIO_PORT_A, BIT0
.equ RCGC_GPIO_PORT_B, BIT1
.equ RCGC_GPIO_PORT_C, BIT2
.equ RCGC_GPIO_PORT_D, BIT3
.equ RCGC_GPIO_PORT_E, BIT4
.equ RCGC_GPIO_PORT_F, BIT5

.equ LED_R, BIT1
.equ LED_B, BIT2
.equ LED_G, BIT3

.equ GPIO_PORT_F_BASE,   0x40025000
.equ GPIO_DATA_OFF,       0x3FC
.equ GPIO_DIR_OFF,        0x400
.equ GPIO_PUR_OFF,        0x510
.equ GPIO_DEN_OFF,        0x51C
.equ GPIO_PORT_F_DATA_R, GPIO_PORT_F_BASE + GPIO_DATA_OFF
.equ GPIO_PORT_F_DIR_R,  GPIO_PORT_F_BASE + GPIO_DIR_OFF
.equ GPIO_PORT_F_PUR_R,  GPIO_PORT_F_BASE + GPIO_PUR_OFF
.equ GPIO_PORT_F_DEN_R,  GPIO_PORT_F_BASE + GPIO_DEN_OFF

.equ ST_BASE,           0xE000E000
.equ ST_CTRL_OFF,       0x10
.equ ST_RELOAD_OFF,     0x14
.equ ST_CURRENT_OFF,    0x18
.equ ST_CTRL_R,         ST_BASE + ST_CTRL_OFF
.equ ST_RELOAD_R,       ST_BASE + ST_RELOAD_OFF
.equ ST_CURRENT_R,      ST_BASE + ST_CURRENT_OFF 
.equ ST_CTRL_ENABLE,    BIT0
.equ ST_CTRL_INTEN,     BIT1
.equ ST_CTRL_CLK_SRC,   BIT2
.equ ST_CTRL_COUNT,     BIT16

s:
.word 0
ms:
.word 0

.section .text
.global main
.global sys_tick_handler
.align

init_hardware:
// here you can init your hardware
    PUSH {r0, r1, r2, LR}

    LDR r0, =RCGC_GPIO_R
    LDR r1, [r0]
    ORR r1, r1, RCGC_GPIO_PORT_F
    STR r1, [r0]

    LDR r0, =GPIO_PORT_F_DIR_R
    LDR r1, [r0]
    ORR r1, r1, #LED_R | LED_B | LED_G
    STR r1, [r0]

    LDR r0, =GPIO_PORT_F_PUR_R
    LDR r1, [r0]
    BIC r1, r1, #LED_R | LED_B | LED_G
    STR r1, [r0] 

    LDR r0, =GPIO_PORT_F_DEN_R
    LDR r1, [r0]
    ORR r1, #LED_R | LED_B | LED_G
    STR r1, [r0]

    LDR r0, =ST_CTRL_R
    LDR r1, [r0]
    ORR r1, r1, #ST_CTRL_ENABLE | ST_CTRL_CLK_SRC
    BIC r1, ST_CTRL_INTEN 
    STR r1, [r0] 

    LDR r0, =ST_RELOAD_R
    LDR r1, [r0]
    LDR r2, =15999
    ORR r1, r1, r2 //16Mhz / 1000 -1
    STR r1, [r0]

    POP {r0, r1, r2, PC}

.thumb_func
sys_tick_handler:
// call this method every millisecond, dictated by the SysTick    
    //pushe benutze register zum Stack LR 
    PUSH {r0, r1, LR}
    LDR r0, =ms
    LDR r1, [r0]
    ADD r1, r1, #1
    STR r1, [r0]

    CMP r1, #1000
    BNE skip_update

    MOV r1, #0
    STR r1, [r0]  

    LDR r0, =s 
    LDR r1, [r0]
    ADD r1, r1, #1
    STR r1, [r0]

    LDR r0, =GPIO_PORT_F_DATA_R
    LDR r1, [r0]

    EOR r1, r1, #LED_R | LED_G | LED_B
    STR r1, [r0]  

skip_update:
    POP {r0, r1, PC}

main: // here the actual program starts; you might want to call init_hardware
    BL init_hardware
    //mov r1, BIT5 | BIT10 // this is a example of how you can use bitwise or operations on the right side; this also works in equ directives

main_loop:
// create an infinite loop here
    LDR r0, =ST_CTRL_R  
    LDR r1, [r0]

    ANDS r1, r1, #ST_CTRL_COUNT
    it ne
    BLNE sys_tick_handler

    B main_loop
.end
