.global _start
.extern _main
.text
_start: 
ResetEntry   : b _reset
UndefEntry   : ldr     pc, _undefined_instruction
SwiEntry     : ldr     pc, _software_interrupt
IAboartEntry : ldr     pc, _prefetch_abort
DAboartEntry : ldr     pc, _data_abort
NotUsedEntry : ldr     pc, _not_used
IrqEntry     : ldr     pc, _irq
FiqEntry     : ldr     pc, _fiq
_undefined_instruction: .word undefined_instruction
_software_interrupt:    .word software_interrupt
_prefetch_abort:        .word prefetch_abort
_data_abort:            .word data_abort
_not_used:              .word not_used
_irq:                   .word irq
_fiq:                   .word fiq
__TABLE_END__:
_reset:
    bl    _main
    b    .
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
