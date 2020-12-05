`include "../io/if.sv"
module Systolic_array_tb(
    input logic clk
);
    logic [31:0] cnt = 32'h0000_0000;
    logic [31:0] cnt_w = 32'h0000_0000;
    logic reset = 0;
    logic read = 0;
    logic [15:0] l_d_i;
    logic [15:0] pe_t_w[0:2];

    logic [15:0] l_d[0:2];
    logic [15:0] t_d[0:2][0:2];

    bus_if  vec_csr_if();
    bus_if  mat_csr_if();
    bus_if  csr_if();

    Systolic_array #(
        .PE_NUMBER(3)
    ) SA (
        .clk    (clk    ),
        .read   (read   ),
        .reset  (reset  ),
        .l_d_i  (l_d_i  ),
        .pe_t_w (pe_t_w )
    );

/*
    Controller Controller(
        .clk    (clk    ),
        .read   (read   ),
        .reset  (reset  ),
        .vec_csr_if (vec_csr_if ),
        .mat_csr_if (mat_csr_if ),
        .csr_if (csr_if )
    );
*/

    assign cnt_w = cnt + 1;
/*
    assign vec_csr_if.data = 3;
    assign mat_csr_if.data = 3;
    assign csr_if.data = 1;
*/

    always_ff @(posedge clk) begin
        cnt = cnt_w;
/* コントローラのテスト用
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
*/
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

    initial begin
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
    end
endmodule
