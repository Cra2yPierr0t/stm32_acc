module PE(
    input   logic clk,
    input   logic read,
    input   logic reset,
    input   logic [15:0] l_d_i,
    input   logic [15:0] r_d_i,
    input   logic [15:0] t_d_i,
    output  logic [15:0] l_d_o,
    output  logic [15:0] r_d_o
);

    logic [15:0] buffer_w;
    logic [15:0] buffer;

    logic [15:0] l_d_o_w;

    logic [15:0] r_d_o_r;
    
    always_comb begin
        if(reset) begin
            buffer_w = 16'h0000;
        end else if(read) begin
            buffer_w = r_d_i;
        end else begin
            buffer_w = buffer + l_d_i * t_d_i;
        end

        if(reset) begin
            l_d_o_w = 16'h0000;
        end else if(read) begin
            l_d_o_w = buffer;
        end else begin
            l_d_o_w = 16'h0000;
        end

        r_d_o = r_d_o_r;
        if(read) begin
            l_d_o = buffer;
        end else begin
            l_d_o = 16'h0000;
        end
    end

    always_ff @(posedge clk) begin
        buffer  <= buffer_w;
        r_d_o_r <= l_d_i;
    end
endmodule
