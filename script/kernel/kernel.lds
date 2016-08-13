OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_kernel_start)
SECTIONS {
    . = 0x00000000;

    . = ALIGN(4);
    __text_start = .;
    .text : { head.o *(.text) }
    __text_end = .;
    _etext = .;

    . = ALIGN(4);
    .rodata : { *(.rodata) }
    __rodata_end = .;

    . = ALIGN(4);
    __data_start = .;
    .data : { *(.data) }
    __data_end = .;

    . = ALIGN(4);
    __bss_start = .;
    .bss : {
        *(.bss)
    }
    __bss_end = .;
}
