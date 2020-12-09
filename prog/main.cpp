#include "mbed.h"
SPI spi(A6, A5, A4);
DigitalOut cs(A3);

Serial pc(USBTX, USBRX);
Timer tm;

int main(){
    cs = 1;

    int t = 33;
    spi.format(16, 0);
    spi.frequency(1000000);
    unsigned int A[34][34], B[34], C_1[34], C_2[34];
    for(int i = 0; i < t; i++){
        for(int j = 0; j < t; j++){
            A[i][j] = j;
        }
        B[i] = i;
    }
    cs = 0;
    tm.start();
    spi.write(0x1001); // write vector size
    spi.write(t); // size 32
    spi.write(0x1002); // write matrix column size
    spi.write(t); // size 32
    spi.write(0x4000); // start input vector data
    for(int i = 0; i < t; i++){
        spi.write(B[i]);
    }
    spi.write(0x5000); // start input matrix data
    for(int i = 0; i < t; i++){
        for(int j = 0; j < t; j++){
            spi.write(A[j][i]);
        }
    }
    spi.write(0x3000); // start calculation
    spi.write(0x6000); // read result
    for(int i = 0; i < t; i++){
        C_1[i] = spi.write(0x0000);
    }
    tm.stop();
    cs = 1;
    printf("The time taken was %d us\n\r", tm.read_us());
    printf("The time taken was %d ms\n\r", tm.read_ms());
    for(int i = 0; i < t; i++){
        printf("C_1[%d] = 0x%04x\n\r", i, C_1[i]);
    }
    //----------------
    tm.reset();
    tm.start();
    for(int i = 0; i < t; i++){
        C_2[i] = 0;
    }
    for(int i = 0; i < t; i++){
        for(int j = 0; j < t; j++){
            C_2[i] += A[i][j] * B[j];
        }
    }
    tm.stop();
    printf("The time taken was %d us\n\r", tm.read_us());
    printf("The time taken was %d ms\n\r", tm.read_ms());
    
    for(int i = 0; i < t; i++){
        printf("C_2[%d] = 0x%04x\n\r", i, C_2[i]);
    }
}
