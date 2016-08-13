.equ IRQ32MOD, 0x12
.equ SVC32MOD, 0x13
.equ SYS32MOD, 0x1f
.equ NOINT, 0xc0

.global _kernel_start
_kernel_start:
ResetEntry   : b _reset
UndefEntry   : ldr pc, _undefined_instruction
SwiEntry     : ldr pc, _software_interrupt
IAboartEntry : ldr pc, _prefetch_abort
DAboartEntry : ldr pc, _data_abort
NotUsedEntry : ldr pc, _not_used
IrqEntry     : ldr pc, _irq
FiqEntry     : ldr pc, _fiq

_undefined_instruction: .word undefined_instruction
_software_interrupt:    .word software_interrupt
_prefetch_abort:        .word prefetch_abort
_data_abort:            .word data_abort
_not_used:              .word not_used
_irq:                   .word irq
_fiq:                   .word fiq
_end:

_reset:
    bl mmu_setup
stack_setup:
    mov r0, #0x100000
    sub sp, r0, #4

    msr cpsr_c, #NOINT|IRQ32MOD
    sub sp, r0, #0x1000

    @msr cpsr_c, #NOINT|SYS32MOD
    @ldr sp, =0x408000

    msr cpsr_c, #NOINT|SVC32MOD

    ldr pc, =kmain

undefined_instruction:
    B .
software_interrupt:
    B .
prefetch_abort:
    B .
data_abort:
    B .
not_used:
    B .
irq:
    B .
fiq:
    B .
