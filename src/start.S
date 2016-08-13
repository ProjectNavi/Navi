#include <kernel.h>

.global _start
.text
_start: 
_reset:
    mrs r0, cpsr
    bic r0, r0, #0x1f
    orr r0, r0, #0xd3
    msr cpsr, r0

    bl disable_watchdog
    bl init_cpu
    bl setup_clk
    bl setup_mem
    bl init_uart

    @ copy kernal codes.
    bl load_kernel
    b .

load_kernel:
    ldr r0,_OS_ROM_BASE
    ldr r1,_OS_RAM_BASE
    ldr r2,_OS_END

copy_loop:
    ldr r3,[r0],#4
    str r3,[r1],#4
    cmp r0,r2
    blt copy_loop

jump_kernel:
    ldr pc,_OS_RAM_BASE
    .balign 4

_OS_ROM_BASE:
    .word __kernel_start

_OS_RAM_BASE:
    .word OS_RAM_BASE

_OS_END:
    .word __kernel_end

init_uart:
    /* set GPIO to enable UART */
    @ GPIO setting for UART for UART0/1
    ldr r0, =0x11400000
    ldr r1, =0x22222222
    str     r1, [r0]
    ldr r0, =0x11400020
    ldr r1, =0x222222
    str r1, [r0]

    ldr r0, =EXYNOS4X12_CLOCK_BASE   @0x1003_0000
    ldr r1, =CLK_SRC_PERIL0_VAL     @0x666666
    ldr r2, =CLK_SRC_PERIL0_OFFSET
    str r1, [r0, r2]
    ldr r1, =CLK_DIV_PERIL0_VAL     @0x777777
    ldr r2, =CLK_DIV_PERIL0_OFFSET
    str r1, [r0, r2]

    ldr r0, =ELFIN_UART_CONSOLE_BASE        @0xEC000000
    ldr r1, =0x111
    str r1, [r0, #UFCON_OFFSET]

    mov r1, #0x3
    str r1, [r0, #ULCON_OFFSET]

    ldr r1, =0x3c5
    str r1, [r0, #UCON_OFFSET]

    ldr r1, =UART_UBRDIV_VAL    @0x2B /*  UDIV(43) = ((82,500,000 / 16 / 115200) - 1) */
    str r1, [r0, #UBRDIV_OFFSET]

    ldr r1, =UART_UDIVSLOT_VAL  @0xC /* UFRACVAL(12) = ((((82,500,000 / 16 / 115200) - 1) - 43) * 16) */
    str r1, [r0, #UDIVSLOT_OFFSET]

    @ldr r1, =0x4f4f4f4f
    @str r1, [r0, #UTXH_OFFSET]      @'O'
    mov     pc, lr

disable_watchdog:
    ldr r0, =EXYNOS4X12_WATCHDOG_BASE
    mov r1, #0x0
    str r1, [r0]

    mov pc, lr

init_cpu:
    mrs r0, cpsr
    bic r0, r0, #0x1f
    orr r0, r0, #0xd3
    msr cpsr, r0

    /* disable mmu */
    mrc p15, 0, r0, c1 ,c0 ,0
    bic r0, r0, #(1 << 0)
    mcr p15, 0, r0, c1, c0, 0

    /* enable    I-C2che */
    mrc p15, 0, r0, c1, c0, 0
    orr r0, r0, #(1 << 12)
    mcr p15, 0, r0, c1, c0, 0

    /* enable coprocessors */
    ldr r0, =0xffffffff
    mcr p15, 0, r0, c1, c0, 2

    /* enable branch prediction */
    mrc p15, 0, r0, c1, c0, 0
    orr r0, r0, #(1 << 11)
    mcr p15, 0, r0, c1, c0, 0

    mov pc, lr

setup_mem:
    @ Async bridge configuration at CPU_core
    @ 1: half_sync
    @ 0: full_sync
    ldr r0, =0x10010350
    mov r1, #1
    str r1, [r0]

    ldr r0, =EXYNOS4X12_DMC_CTRL_BASE

    ldr	r1, =0x20001507
    str	r1, [r0, #MIU_INTLV_CONFIG]
    ldr	r1, =0x40000000
    str	r1, [r0, #MIU_INTLV_START_ADDR]
    ldr	r1, =0xbfffffff
    str	r1, [r0, #MIU_INTLV_END_ADDR]
    ldr	r1, =0x00000001
    str	r1, [r0, #MIU_MAPPING_UPDATE]

    @ DREX0

    ldr	r0, =APB_DMC_0_BASE

    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]

    ldr	r1, =0xE3855703
    str	r1, [r0, #DMC_PHYZQCONTROL]

    mov	r2, #0x100000
1:
    subs r2, r2, #1
    bne	1b

    ldr	r1, =0xe000008e
    str	r1, [r0, #DMC_PHYCONTROL1]
    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]

    ldr	r1, =0x71101008
    str	r1, [r0, #DMC_PHYCONTROL0]
    ldr	r1, =0x7110100A
    str	r1, [r0, #DMC_PHYCONTROL0]
    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]
    ldr	r1, =0x7110100B
    str	r1, [r0, #DMC_PHYCONTROL0]

    ldr	r1, =0x00000000
    str	r1, [r0, #DMC_PHYCONTROL2]

    ldr	r1, =0x0FFF301A
    str	r1, [r0, #DMC_CONCONTROL]
    ldr	r1, =0x00312640
    str	r1, [r0, #DMC_MEMCONTROL]

    ldr	r1, =0x20e01323
    str	r1, [r0, #DMC_MEMCONFIG0]
    ldr	r1, =0x40e01323
    str	r1, [r0, #DMC_MEMCONFIG1]

    ldr	r1, =0xff000000
    str	r1, [r0, #DMC_PRECHCONFIG]

    ldr	r1, =0x000000BB
    str	r1, [r0, #DMC_TIMINGAREF] @TimingAref

    ldr	r1, =0x4046654f
    str	r1, [r0, #DMC_TIMINGROW] @TimingRow
    ldr	r1, =0x46400506
    str	r1, [r0, #DMC_TIMINGDATA] @TimingData
    ldr	r1, =0x52000a3c
    str	r1, [r0, #DMC_TIMINGPOWER] @TimingPower

    ldr	r1, =0x07000000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
2:
    subs r2, r2, #1
    bne	2b

    ldr	r1, =0x00020000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00030000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00010002
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00000328
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
3:
    subs r2, r2, #1
    bne	3b

    ldr	r1, =0x0a000000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
4:
    subs r2, r2, #1
    bne	4b

    ldr	r1, =0x07100000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
5:
    subs r2, r2, #1
    bne	5b

    ldr	r1, =0x00120000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00130000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00110002
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00100328
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
6:
    subs r2, r2, #1
    bne	6b

    ldr	r1, =0x0a100000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
7:
    subs r2, r2, #1
    bne	7b

    ldr	r1, =0xe000008e
    str	r1, [r0, #DMC_PHYCONTROL1]
    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]

    mov	r2, #0x100000
8:
    subs r2, r2, #1
    bne	8b

    @ DREX1

    ldr	r0, =APB_DMC_1_BASE

    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]

    ldr	r1, =0xE3855703
    str	r1, [r0, #DMC_PHYZQCONTROL]

    mov	r2, #0x100000
1:
    subs r2, r2, #1
    bne	1b

    ldr	r1, =0xe000008e
    str	r1, [r0, #DMC_PHYCONTROL1]
    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]

    ldr	r1, =0x71101008
    str	r1, [r0, #DMC_PHYCONTROL0]
    ldr	r1, =0x7110100A
    str	r1, [r0, #DMC_PHYCONTROL0]
    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]
    ldr	r1, =0x7110100B
    str	r1, [r0, #DMC_PHYCONTROL0]

    ldr	r1, =0x00000000
    str	r1, [r0, #DMC_PHYCONTROL2]

    ldr	r1, =0x0fff301a
    str	r1, [r0, #DMC_CONCONTROL]
    ldr r1, =0x00312640
    str	r1, [r0, #DMC_MEMCONTROL]

    ldr	r1, =0x20e01323
    str	r1, [r0, #DMC_MEMCONFIG0]
    ldr	r1, =0x40e01323
    str	r1, [r0, #DMC_MEMCONFIG1]

    ldr	r1, =0xff000000
    str	r1, [r0, #DMC_PRECHCONFIG]

    ldr	r1, =0x000000BC
    str	r1, [r0, #DMC_TIMINGAREF] @TimingAref

    ldr	r1, =0x4046654f
    str	r1, [r0, #DMC_TIMINGROW] @TimingRow
    ldr	r1, =0x46400506
    str	r1, [r0, #DMC_TIMINGDATA] @TimingData
    ldr	r1, =0x52000a3c
    str	r1, [r0, #DMC_TIMINGPOWER] @TimingPower

    ldr	r1, =0x07000000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
2:
    subs r2, r2, #1
    bne	2b

    ldr	r1, =0x00020000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00030000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00010002
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00000328
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
3:
    subs r2, r2, #1
    bne	3b

    ldr	r1, =0x0a000000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
4:
    subs r2, r2, #1
    bne	4b

    ldr	r1, =0x07100000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
5:
    subs r2, r2, #1
    bne	5b

    ldr	r1, =0x00120000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00130000
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00110002
    str	r1, [r0, #DMC_DIRECTCMD]
    ldr	r1, =0x00100328
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
6:
    subs r2, r2, #1
    bne	6b

    ldr	r1, =0x0a100000
    str	r1, [r0, #DMC_DIRECTCMD]

    mov	r2, #0x100000
7:
    subs r2, r2, #1
    bne	7b

    ldr	r1, =0xe000008e
    str	r1, [r0, #DMC_PHYCONTROL1]
    ldr	r1, =0xe0000086
    str	r1, [r0, #DMC_PHYCONTROL1]

    mov	r2, #0x100000
8:
    subs r2, r2, #1
    bne	8b

    @ turn on DREX0, DREX1

    ldr	r0, =APB_DMC_0_BASE
    ldr	r1, =0x0FFF303a
    str	r1, [r0, #DMC_CONCONTROL]

    ldr	r0, =APB_DMC_1_BASE
    ldr	r1, =0x0FFF303a
    str	r1, [r0, #DMC_CONCONTROL]

    mov pc, lr

setup_clk:
    ldr r0, =EXYNOS4X12_CLOCK_BASE   @0x1003_0000

    @ CMU_CPU MUX / DIV
    ldr r1, =0x0
    ldr r2, =CLK_SRC_CPU_OFFSET
    str r1, [r0, r2]

    @ wait ?us
    mov r1, #0x10000
1:  subs    r1, r1, #1
    bne 1b

    ldr r1, =CLK_DIV_CPU0_VAL
    ldr r2, =CLK_DIV_CPU0_OFFSET
    str r1, [r0, r2]
    ldr r1, =CLK_DIV_CPU1_VAL
    ldr r2, =CLK_DIV_CPU1_OFFSET
    str r1, [r0, r2]

    @ CMU_DMC MUX / DIV
    ldr r1, =0x10000
    ldr r2, =CLK_SRC_DMC_OFFSET
    str r1, [r0, r2]

    @ wait ?us
    mov r1, #0x10000
2:  subs    r1, r1, #1
    bne 2b

    ldr r1, =CLK_DIV_DMC0_VAL
    ldr r2, =CLK_DIV_DMC0_OFFSET
    str r1, [r0, r2]
    ldr r1, =CLK_DIV_DMC1_VAL
    ldr r2, =CLK_DIV_DMC1_OFFSET
    str r1, [r0, r2]

    @ CMU_TOP MUX / DIV
    ldr r1, =CLK_SRC_TOP0_VAL
    ldr r2, =CLK_SRC_TOP0_OFFSET
    str r1, [r0, r2]
    ldr r1, =CLK_SRC_TOP1_VAL
    ldr r2, =CLK_SRC_TOP1_OFFSET
    str r1, [r0, r2]

    @ wait ?us
    mov r1, #0x10000
3:  subs    r1, r1, #1
    bne 3b

    ldr r1, =CLK_DIV_TOP_VAL
    ldr r2, =CLK_DIV_TOP_OFFSET
    str r1, [r0, r2]

    @ CMU_LEFTBUS MUX / DIV
    ldr r1, =CLK_SRC_LEFTBUS_VAL
    ldr r2, =CLK_SRC_LEFTBUS_OFFSET
    str r1, [r0, r2]

    @ wait ?us
    mov r1, #0x10000
4:  subs    r1, r1, #1
    bne 4b

    ldr r1, =CLK_DIV_LEFTBUS_VAL
    ldr r2, =CLK_DIV_LEFTBUS_OFFSET
    str r1, [r0, r2]

    @ CMU_RIGHTBUS MUX / DIV
    ldr r1, =CLK_SRC_RIGHTBUS_VAL
    ldr r2, =CLK_SRC_RIGHTBUS_OFFSET
    str r1, [r0, r2]

    @ wait ?us
    mov r1, #0x10000
5:  subs    r1, r1, #1
    bne 5b

    ldr r1, =CLK_DIV_RIGHTBUS_VAL
    ldr r2, =CLK_DIV_RIGHTBUS_OFFSET
    str r1, [r0, r2]

    @ Set PLL locktime
    ldr r1, =PLL_LOCKTIME
    ldr r2, =APLL_LOCK_OFFSET
    str r1, [r0, r2]
    ldr r1, =PLL_LOCKTIME
    ldr r2, =MPLL_LOCK_OFFSET
    str r1, [r0, r2]
    ldr r1, =PLL_LOCKTIME
    ldr r2, =EPLL_LOCK_OFFSET
    str r1, [r0, r2]
    ldr r1, =PLL_LOCKTIME
    ldr r2, =VPLL_LOCK_OFFSET
    str r1, [r0, r2]

    @ Set PLL P,M,S ON
    ldr r1, =APLL_CON1_VAL
    ldr r2, =APLL_CON1_OFFSET
    str r1, [r0, r2]

    @ Set APLL
    ldr r1, =APLL_CON0_VAL
    ldr r2, =APLL_CON0_OFFSET
    str r1, [r0, r2]

    @ Set MPLL
    ldr r1, =MPLL_CON1_VAL
    ldr r2, =MPLL_CON1_OFFSET
    str r1, [r0, r2]
    ldr r1, =MPLL_CON0_VAL
    ldr r2, =MPLL_CON0_OFFSET
    str r1, [r0, r2]

    @ Set EPLL
    ldr r1, =EPLL_CON1_VAL
    ldr r2, =EPLL_CON1_OFFSET
    str r1, [r0, r2]
    ldr r1, =EPLL_CON0_VAL
    ldr r2, =EPLL_CON0_OFFSET
    str r1, [r0, r2]

    @ Set VPLL
    ldr r1, =VPLL_CON1_VAL
    ldr r2, =VPLL_CON1_OFFSET
    str r1, [r0, r2]
    ldr r1, =VPLL_CON0_VAL
    ldr r2, =VPLL_CON0_OFFSET
    str r1, [r0, r2]

    @ wait ?us
    mov r1, #0x30000
6:  subs    r1, r1, #1
    bne 6b

    ldr r1, =CLK_SRC_CPU_VAL
    ldr r2, =CLK_SRC_CPU_OFFSET
    str r1, [r0, r2]

    @ wait ?us
    mov r1, #0x10000
7:  subs    r1, r1, #1
    bne 7b

    mov     pc, lr
