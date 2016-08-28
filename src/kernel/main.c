#include "kernel.h"

void kmain(void)
{
    uart_puts("\nkmain: ");
    uart_puthexnl((unsigned int)kmain);

    uart_puts("pc: ");
    uart_puthexnl((unsigned int)get_pc());

    uart_puts("sp: ");
    uart_puthexnl((unsigned int)get_sp());

    while (1);
}
