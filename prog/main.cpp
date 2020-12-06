#include "mbed.h"

SPI spi(A6, A5, A4);
DigitalOut cs(A3)

Serial 

int main(){
    spi.format(16, 0);
    spi.frequency(1000000);

    int buf;
    cs = 0;
    spi.write(0x2222);
    buf = spi.write(0x0000)
    cs = 1;
}
