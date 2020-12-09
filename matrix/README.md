# TOY_Accelerator

SPIで制御できる行列-ベクトル乗算器

# Features
    
 * 通信速度 : 大体10Mbps

# Usage

基本的に コマンド送信 -> データ送信 で操作する.

| command | description |
| --- | --- |
| 0x1001 | ベクトルのサイズ入力 |
| 0x1002 | 行列の列のサイズ入力 |
| 0x2000 | リセット(未実装) |
| 0x3000 | 計算開始 |
| 0x4000 | ベクトルデータ入力開始 |
| 0x5000 | 行列データ入力開始(列優先) |
| 0x6000 | 計算結果読み出し開始 |

ライブラリはいつか作る.

# Example

以下のコードは2x3行列の乗算を行っている.

```Cpp
#include "mbed.h"
SPI spi(A6, A5, A4);
DigitalOut cs(A3);
Serial pc(USBTX, USBRX);

int main(){
    cs = 1;
    spi.format(16, 0);
    spi.frequency(5000000);
    int d1, d2, d3;

    int buf;
    cs = 0;
    spi.write(0x1001); // write vector size
    spi.write(0x0002); // size 2
    spi.write(0x1002); // write matrix column size
    spi.write(0x0003); // size 3
    spi.write(0x4000); // start input vector data
    spi.write(0x0003);
    spi.write(0x0004);
    spi.write(0x5000); // start input matrix data
    spi.write(0x0003);      //
    spi.write(0x0005);      // +-   -+   +- -+
    spi.write(0x0002);      // | 3 4 |   | 3 |
    spi.write(0x0004);      // | 5 7 | x |   |
    spi.write(0x0007);      // | 2 1 |   | 4 |
    spi.write(0x0001);      // +-   -+   +- -+
                            //
    spi.write(0x3000); // start calculation
    spi.write(0x6000); // read result
    d1 = spi.write(0x0000);
    d2 = spi.write(0x0000);
    d3 = spi.write(0x0000);
    cs = 1;
    printf("d1 is 0x%04x\n\r", d1);
    printf("d2 is 0x%04x\n\r", d2);
    printf("d3 is 0x%04x\n\r", d3);
}
```
