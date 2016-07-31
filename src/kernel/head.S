.global _kernel_start
_kernel_start:
stack_setup:
    ldr r0, =_kernel_start
    sub sp, r0, #4
    ldr pc, =kmain
