OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)
SECTIONS {
    . = 0x40010000;

    __text_start = .;
    .text : { *(.text) }
    __text_end = .;
    _etext = .;

    .rodata : { *(.rodata) }
    __rodata_end = .;

    __data_start = .;
    .data : { *(.data) }
    __data_end = .;

    __bss_start = .;
    .bss : {
        *(.bss)
    }
    __bss_end = .;
}
