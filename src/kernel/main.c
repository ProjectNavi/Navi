#include "kernel.h"

extern void uart_putc(char ch);

char str[]="Hello World!!\n\r";

void kmain(void)
{
    int i = 0;
    while (str[i]) {
        uart_putc(str[i]);
        i++;
    }

    while (1);
}
