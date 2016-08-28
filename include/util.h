#define get_pc()              \
({                            \
    unsigned long pc;         \
    __asm__ __volatile__ (    \
        "mov %0, pc"          \
        :"=r" (pc):);         \
    pc;                       \
})

#define get_sp()              \
({                            \
    unsigned long sp;         \
    __asm__ __volatile__ (    \
        "mov %0, sp"          \
        :"=r" (sp):);         \
    sp;                       \
})
