OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)
SECTIONS {
    . = 0x40010000;

    . = ALIGN(4);
    __text_start = .;
    .text : { start.o(.text) *(.text) }
    __text_end = .;
    _etext = .;

    . = ALIGN(4);
    .rodata : { *(.rodata) }
    __rodata_end = .;

    . = ALIGN(4);
    __data_start = .;
    .data : { *(EXCLUDE_FILE(kernel.bin.o).data) }
    __data_end = .;

    . = ALIGN(4);
    __bss_start = .;
    .bss : {
        *(.bss)
    }
    __bss_end = .;

    . = ALIGN(4);
    __kernel_start = .;
    .kernel : {kernel.bin.o}
    . = ALIGN(4);
    __kernel_end = .;
}
