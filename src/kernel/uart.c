#include "kernel.h"

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
}
