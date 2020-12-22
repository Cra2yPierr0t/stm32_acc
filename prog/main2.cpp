#include "mbed.h"

#define SIZE 32
Timer tm;

int main(){
    unsigned int A[SIZE][SIZE];
    unsigned int B[SIZE][SIZE];
    unsigned int C[SIZE][SIZE];
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            A[i][j] = j;
            B[i][j] = i;
        }
    }
    // ---- run on cpu ----
    tm.start();
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            C[i][j] = 0;
        }
    }
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            for(int k = 0; k < SIZE; k++){
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    tm.stop();
    printf("The time taken was %d us\n\r", tm.read_us());
    printf("The time taken was %d ms\n\r", tm.read_ms());
    
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            printf("%d ", C[i][j]);
        }
        printf("\n");
    }
}
