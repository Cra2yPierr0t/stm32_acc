module Memory #(
    parameter MEM_SIZE  = 1024,
    parameter ADDR_SIZE = 10,
    parameter WORD_SIZE = 16,
    parameter PE_NUMBER = 64
)(
    input logic clk,
    input logic [ADDR_SIZE-1:0] w_addr,
    input logic w_en,
    input logic [WORD_SIZE-1:0] w_data,
    input logic [ADDR_SIZE-1:0] r_addr,
    output logic [WORD_SIZE-1:0] r_data,
    output logic [WORD_SIZE-1:0] l_d_o,
    input logic l_d_o_en,
    output logic [WORD_SIZE-1:0] pe_t_w[0:PE_NUMBER-1],
    input logic [PE_NUMBER-1:0] pe_t_o_en,
    input logic [WORD_SIZE-1:0] l_d_o
);

    logic [WORD_SIZE-1:0] mem[0:MEM_SIZE];

    //PE_NUMBER個の読み出し機構を作成する
    always_ff @(posedge clk) begin
        if(w_en) begin
            mem[w_addr] <= w_data;
        end
    end
    assign r_data <= mem[r_addr];

endmodule
