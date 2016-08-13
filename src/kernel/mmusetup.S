#define L1PT  0x40000000
#define L2PT1 0x40004000
#define L2PT2 0x40004400
#define L2PT3 0x40004800
#define L2PT4 0x40004C00

#define SFR_BASE_ADDR 0x10000000
#define KERNELBASE (0x40100000 | 0x1 << 4 | 0x2 << 2 | 0x1 << 1)
#define KERNELL2PT (L2PT1 | 0x3 << 5 | 0x1 << 4 | 0x1)
#define SFRSECBASE (SFR_BASE_ADDR | 0x1 << 10 | 0x3 << 5 | 0x1 << 4 | 0x1 << 3 | 0x2)
#define DOMAINVAL  0x00000040

.globl mmu_setup
mmu_setup:
mmu_init_pt:
    ldr r0,=L1PT
    add r1,r0,#0x5000
    mov r2,#0x0
1:
    str r2,[r0],#4
    cmp r0,r1
    blt 1b

mmu_map_kernel:
    ldr r0, =L2PT1
    add r1, r0, #0x400
    ldr r2, =KERNELBASE
2:
    str r2, [r0], #4
    cmp r0, r1
    addlt r2, r2, #0x1000
    blt 2b

    ldr r0, =L1PT
    ldr r2, =KERNELL2PT
    str r2, [r0]

    @0x40100000
    add r0, r0, #0x1000
    add r0, r0, #4
    str r2, [r0]

mmu_map_sfr:
    ldr r1, =L2PT1
    sub r0, r1, #0x400
    ldr r2, =SFRSECBASE
3:
    str r2, [r0], #4
    cmp r0, r1
    addlt r2, r2, #0x100000
    blt 3b

ttbmap:
    ldr r0, =L1PT
    mcr p15, 0, r0, c2, c0, 0

domainset:
    ldr r0, =DOMAINVAL
    mcr p15, 0, r0, c3, c0, 0

controlset:
    mov r0,#0
    mcr p15,0,r0,c7,c7,0
    mcr p15,0,r0,c8,c7,0

    mrc p15,0,r0,c1,c0,0
    bic r0,r0,#0x00002300
    bic r0,r0,#0x00000087
    orr r0,r0,#0x00000002
    orr r0,r0,#0x00001000
    orr r0,r0,#0x00000004
    orr r0,r0,#0x00000001
    mcr p15,0,r0,c1,c0,0

    mov pc,lr
