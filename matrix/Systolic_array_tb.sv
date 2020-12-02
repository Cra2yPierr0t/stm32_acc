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

    Systolic_array SA(
        .clk    (clk    ),
        .read   (read   ),
        .reset  (reset  ),
        .l_d_i  (l_d_i  ),
        .pe_t_w (pe_t_w )
    );

    assign cnt_w = cnt + 1;

    always_ff @(posedge clk) begin
        cnt = cnt_w;
        if(cnt <= 2) begin
            reset = 1;
        end else begin
            reset = 0;
        end
        if((3 <= cnt) && (cnt <= 5)) begin
            l_d_i = l_d[cnt - 3];
            pe_t_w[0] = t_d[0][cnt - 3];
        end else begin
            l_d_i = 0;
            pe_t_w[0] = 0;
        end
        if((4 <= cnt) && (cnt <= 6)) begin
            pe_t_w[1] = t_d[1][cnt - 4];
        end else begin
            pe_t_w[1] = 0;
        end
        if((5 <= cnt) && (cnt <= 7)) begin
            pe_t_w[2] = t_d[2][cnt - 5];
        end else begin
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
