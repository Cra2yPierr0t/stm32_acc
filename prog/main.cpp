#include "mbed.h"

SPI spi(A6, A5, A4);
DigitalOut cs(A3)

Serial pc(USBTX, USBRX);

int main(){
    spi.format(16, 0);
    spi.frequency(1000000);

    int buf;
    cs = 0;
    spi.write(0x2222);
    buf = spi.write(0x0000)
    cs = 1;
    pc.printf("buf is 0x%x\n", buf);
}
