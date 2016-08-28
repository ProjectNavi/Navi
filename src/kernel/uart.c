#include "kernel.h"

void uart_init() {
}

void uart_putc(char ch) {
    typedef struct {
        volatile unsigned long ULCON;
        volatile unsigned long UCON;
        volatile unsigned long UFCON;
        volatile unsigned long UMCON;
        volatile unsigned long UTRSTAT;
        volatile unsigned long UERSTAT;
        volatile unsigned long UFSTAT;
        volatile unsigned long UMSTAT;
        volatile unsigned char UTXH;
        volatile unsigned char res1[3];
        volatile unsigned char URXH;
        volatile unsigned char res2[3];
        volatile unsigned long UBRDIV;
    } S5PC11X_UART;

    S5PC11X_UART *const uart = (S5PC11X_UART *)0xF3800000;
    //S5PC11X_UART *const uart = (S5PC11X_UART *)0x13800000;

    while (!(uart->UTRSTAT & 0x2));

    uart->UTXH = ch;

    if (ch == '\n') {
        while (!(uart->UTRSTAT & 0x2));
        uart->UTXH = '\r';
    }
}

void uart_puts(const char* s) {
    while (*s)
        uart_putc(*s++);
}

void uart_puthex(const unsigned int value) {
    char ch;
    int i;
    char buffer[11];

    buffer[0] = '0';
    buffer[1] = 'x';

    for (i = 7; i >= 0; i--) {
        ch = (char)((value >> (i * 4)) & 0x0f);
        if (ch > 9) ch = (ch - 10) + 'a';
        else ch = ch + '0';
        buffer[9 - i] = ch;
    }
    buffer[10] = '\0';
    uart_puts(buffer);
}

void uart_puthexnl(const unsigned int value) {
    uart_puthex(value);
    uart_putc('\n');
}
