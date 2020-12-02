#include "mbed.h"

SPI spi(A6, A5, A4);

int main(){
    spi.format(8, 0);
    spi.frequency(1000000);
    spi.write(0x55);
}
