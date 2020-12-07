`include "../io/if.sv"
module Systolic_array_tb(
    input logic clk
);
    logic [31:0] cnt = 32'h0000_0000;
    logic [31:0] cnt_w = 32'h0000_0000;
    logic reset = 0;
    logic read = 0;
    logic [15:0] l_d_i;
    logic [15:0] l_d_o;
    logic [15:0] pe_t_w[0:2];

    logic [15:0] l_d[0:2];
    logic [15:0] t_d[0:2][0:2];

    logic [15:0] mem[0:63];

    logic [9:0] pe_t_o_addr[0:2];
    logic [9:0] l_d_o_addr;

    logic [9:0] w_addr;
    logic [9:0] r_addr;
    logic [15:0] w_data;
    logic w_en;

    bus_if  vec_csr_if();
    bus_if  mat_csr_if();
    bus_if  csr_if();
    bus_if  spi_2_bus_if();
    bus_if  bus_2_spi_if();

    /*
    assign l_d_i = (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[l_d_o_addr];
    assign pe_t_w[0] = (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[pe_t_o_addr[0]];
    assign pe_t_w[1] = (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[pe_t_o_addr[1]];
    assign pe_t_w[2] = (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[pe_t_o_addr[2]];
    */
    always_ff @(posedge clk) begin
        l_d_i <= (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[l_d_o_addr];
        pe_t_w[0] <= (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[pe_t_o_addr[0]];
        pe_t_w[1] <= (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[pe_t_o_addr[1]];
        pe_t_w[2] <= (l_d_o_addr == 10'b11_0101_0101) ? '0 : mem[pe_t_o_addr[2]];
        if(w_en) begin
            mem[w_addr] <= l_d_o;
        end
    end

    Systolic_array #(
        .PE_NUMBER(3)
    ) SA (
        .clk    (clk    ),
        .read   (read   ),
        .reset  (reset  ),
        .l_d_i  (l_d_i  ),
        .l_d_o  (l_d_o  ),
        .pe_t_w (pe_t_w )
    );

    Controller #(
        .PE_NUMBER(3),
        .MEM_HEAD_ADDR(0),
        .ZERO_POINT_ADDR(16'h5555)
    ) Controller (
        .clk    (clk    ),
        .read   (read   ),
        .reset  (reset  ),
        .spi_2_bus_if (spi_2_bus_if ),
        .bus_2_spi_if (bus_2_spi_if ),
        .vec_csr_if (vec_csr_if ),
        .mat_csr_if (mat_csr_if ),
        .csr_if (csr_if ),
        .pe_t_o_addr    (pe_t_o_addr    ),
        .l_d_o_addr     (l_d_o_addr     ),
        .w_addr         (w_addr         ),
        .w_en           (w_en           ),
        .w_data         (w_data         ),
        .r_addr         (r_addr         ) 
    );

    assign cnt_w = cnt + 1;
    assign vec_csr_if.data = 2;
    assign mat_csr_if.data = 3;
    assign csr_if.data = 1;

    always_ff @(posedge clk) begin
        cnt = cnt_w;
/* TPU -> マイコンの結果読み出し機構テスト用
        if(cnt <= 2) begin
            vec_csr_if.valid <= 1;
            mat_csr_if.valid <= 1;
        end else begin
            vec_csr_if.valid <= 0;
            mat_csr_if.valid <= 0;
        end
        if(cnt == 3) begin
            csr_if.valid <= 1;
        end else begin
            csr_if.valid <= 0;
        end
        if((3 < cnt) && (cnt < 5)) begin
            spi_2_bus_if.valid <= 0;
        end else if((5 < cnt) && (cnt < 7)) begin
            spi_2_bus_if.data <= 16'h6000;
            spi_2_bus_if.valid <= 1;
        end else if((5 < cnt) && (cnt < 100)) begin
            spi_2_bus_if.valid <= 0;
        end
    end
*/
/* マイコン -> TPUのデータ書き込み機構テスト用
        if(cnt <= 1) begin
            spi_2_bus_if.data <= 16'h4000;
            spi_2_bus_if.valid <= 1;
            vec_csr_if.valid <= 1;
            mat_csr_if.valid <= 1;
        end else if((1 < cnt) && (cnt < 3)) begin
            spi_2_bus_if.valid <= 0;
        end else if((3 < cnt) && (cnt < 5)) begin
            spi_2_bus_if.data <= 16'h1111;
            spi_2_bus_if.valid <= 1;
        end else if((5 < cnt) && (cnt < 7)) begin
            spi_2_bus_if.valid <= 0;
        end else if((8 < cnt) && (cnt < 10)) begin
            spi_2_bus_if.data <= 16'h5555;
            spi_2_bus_if.valid <= 1;
        end else if((11 < cnt) && (cnt < 13)) begin
            spi_2_bus_if.valid <= 0;
        end else if((13 < cnt) && (cnt < 15)) begin
            spi_2_bus_if.data <= 16'h8888;
            spi_2_bus_if.valid <= 1;
        end else if((15 < cnt) && (cnt < 18)) begin
            spi_2_bus_if.valid <= 0;
        end else if((18 < cnt) && (cnt < 20)) begin
            spi_2_bus_if.data <= 16'h5000;
            spi_2_bus_if.valid <= 1;
        end else if((20 < cnt) && (cnt < 22)) begin
            spi_2_bus_if.valid <= 0;
        end else if((22 < cnt) && (cnt < 24)) begin
            spi_2_bus_if.data <= 16'h3333;
            spi_2_bus_if.valid <= 1;
        end else if((24 < cnt) && (cnt < 26)) begin
            spi_2_bus_if.valid <= 0;
        end else if((26 < cnt) && (cnt < 28)) begin
            spi_2_bus_if.data <= 16'h7186;
            spi_2_bus_if.valid <= 1;
        end else if((28 < cnt) && (cnt < 30)) begin
            spi_2_bus_if.valid <= 0;
        end else if((30 < cnt) && (cnt < 32)) begin
            spi_2_bus_if.data <= 16'haaaa;
            spi_2_bus_if.valid <= 1;
        end else if((32 < cnt) && (cnt < 34)) begin
            spi_2_bus_if.valid <= 0;
        end else if((34 < cnt) && (cnt < 36)) begin
            spi_2_bus_if.data <= 16'h4321;
            spi_2_bus_if.valid <= 1;
        end else if((36 < cnt) && (cnt < 38)) begin
            spi_2_bus_if.valid <= 0;
        end else if((38 < cnt) && (cnt < 45)) begin
            spi_2_bus_if.data <= 16'h5555;
            spi_2_bus_if.valid <= 0;
        end else if((45 < cnt) && (cnt < 47)) begin
            spi_2_bus_if.valid <= 1;
        end else if((47 < cnt) && (cnt < 49)) begin
            spi_2_bus_if.valid <= 0;
        end else if((49 < cnt) && (cnt < 51)) begin
            spi_2_bus_if.data <= 16'h89ab;
            spi_2_bus_if.valid <= 1;
        end else if((51 < cnt) && (cnt < 100)) begin
            spi_2_bus_if.valid <= 0;
        end
    end
*/
/* コントローラのテスト用
*/
        if(cnt <= 2) begin
            vec_csr_if.valid <= 1;
            mat_csr_if.valid <= 1;
        end else begin
            vec_csr_if.valid <= 0;
            mat_csr_if.valid <= 0;
        end
        if(cnt == 3) begin
            spi_2_bus_if.data <= 16'h3000;
            spi_2_bus_if.valid <= 1;
        end else begin
            spi_2_bus_if.valid <= 0;
        end
        if((25 < cnt) && (cnt < 27)) begin
            spi_2_bus_if.data <= 16'h6000;
            spi_2_bus_if.valid <= 1;
        end else if((27 < cnt) && (cnt < 30)) begin
            bus_2_spi_if.ready <= 0;
        end else if((30 < cnt) && (cnt < 33)) begin
            bus_2_spi_if.ready <= 1;
        end else if((33 < cnt) && (cnt < 37)) begin
            bus_2_spi_if.ready <= 0;
        end else if((37 < cnt) && (cnt < 39)) begin
            bus_2_spi_if.ready <= 1;
        end else if((40 < cnt) && (cnt < 42)) begin
            bus_2_spi_if.ready <= 0;
        end else begin
            bus_2_spi_if.ready <= 1;
        end
    end
/* アレイのテスト用
        if(cnt <= 2) begin
            reset = 1;
        end else begin
            reset = 0;
        end
        if((3 <= cnt) && (cnt <= 5)) begin
            l_d_i = l_d[cnt - 3];
            pe_t_w[0] = t_d[0][cnt - 3];
            pe_t_w[1] = t_d[1][cnt - 3];
            pe_t_w[2] = t_d[2][cnt - 3];
        end else begin
            l_d_i = 0;
            pe_t_w[0] = 0;
            pe_t_w[1] = 0;
            pe_t_w[2] = 0;
        end
        if(7 < cnt) begin
            read = 1;
        end
    end
*/
    logic [15:0] debug_0;
    logic [15:0] debug_1;
    logic [15:0] debug_2;
    
    assign debug_0 = mem[12];
    assign debug_1 = mem[13];
    assign debug_2 = mem[14];

    initial begin
/* アレイ単体テスト用
        l_d[0] = 8;
        l_d[1] = 10;
        l_d[2] = 4;
        t_d[0][0] = 1;
        t_d[0][1] = 7;
        t_d[0][2] = 9;
        t_d[1][0] = 6;
        t_d[1][1] = 3;
        t_d[1][2] = 5;
        t_d[2][0] = 2;
        t_d[2][1] = 7;
        t_d[2][2] = 2;
*/
        mem[0] = 8;
        mem[1] = 10;
        mem[2] = 4;
        mem[3] = 1;
        mem[4] = 6;
        mem[5] = 2;
        mem[6] = 7;
        mem[7] = 3;
        mem[8] = 7;
        mem[9] = 9;
        mem[10] = 5;
        mem[11] = 2;
    end
endmodule
