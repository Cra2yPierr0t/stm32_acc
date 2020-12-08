module PE #(
    parameter WORD_SIZE = 16
)(
    input   logic clk,
    input   logic read,
    input   logic reset,
    input   logic [WORD_SIZE-1:0] l_d_i,
    input   logic [WORD_SIZE-1:0] r_d_i,
    input   logic [WORD_SIZE-1:0] t_d_i,
    output  logic [WORD_SIZE-1:0] l_d_o,
    output  logic [WORD_SIZE-1:0] r_d_o
);

    logic [WORD_SIZE-1:0] buffer_w;
    logic [WORD_SIZE-1:0] buffer;

    logic [WORD_SIZE-1:0] r_d_o_r;
    
    always_comb begin
        if(reset) begin
            buffer_w = '0;
        end else if(read) begin
            buffer_w = r_d_i;
        end else begin
            buffer_w = buffer + l_d_i * t_d_i;
        end

        r_d_o = r_d_o_r;
        if(read) begin
            l_d_o = buffer;
        end else begin
            l_d_o = '0;
        end
    end

    always_ff @(posedge clk) begin
        buffer  <= buffer_w;
        r_d_o_r <= l_d_i;
    end
endmodule
