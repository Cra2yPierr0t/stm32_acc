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
    input logic [ADDR_SIZE-1:0] l_d_o_addr,
    output logic [WORD_SIZE-1:0] pe_t_w[0:PE_NUMBER-1],
    input logic [ADDR_SIZE-1:0] pe_t_o_addr[0:PE_NUMBER-1]

);

    logic [WORD_SIZE-1:0] mem[0:MEM_SIZE-1];

    always_ff @(posedge clk) begin
        if(w_en) begin
            mem[w_addr] <= w_data;
        end
        r_data <= mem[r_addr];
    end

    //PE_NUMBER個の読み出し機構を作成する
    generate 
        genvar i;
        for(i=0; i < PE_NUMBER; i=i+1) begin : gen_read_line
            always_ff @(posedge clk) begin
                pe_t_w[i] <= mem[pe_t_o_addr[i]];
            end
        end
    endgenerate
    always_ff @(posedge clk) begin
        l_d_o <= mem[l_d_o_addr];
    end

endmodule
