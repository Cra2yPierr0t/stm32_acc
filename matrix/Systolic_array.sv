module Systolic_array #(
    parameter PE_NUMBER = 64
)(
    input logic clk,
    input logic read,
    input logic reset,
    input logic [15:0] l_d_i,
    input logic [15:0] pe_t_w[0:PE_NUMBER-1],
    output logic [15:0] l_d_o
);

    logic [15:0] pe_c_w[0:PE_NUMBER-1];
    logic [15:0] pe_r_w[0:PE_NUMBER];

    //delay_bufferの数は後で
    logic [15:0] delay_buffer[1:(PE_NUMBER)*(PE_NUMBER-1)/2];
    logic [15:0] pe_t_w_delayed[1:PE_NUMBER-1];

    genvar i;
    genvar j;
    generate
        PE PE(
            .clk    (clk    ),
            .read   (read   ),
            .reset  (reset  ),
            .l_d_i  (l_d_i  ),
            .r_d_i  (pe_r_w[1]),
            .t_d_i  (pe_t_w[0]),
            .l_d_o  (pe_r_w[0]),
            .r_d_o  (pe_c_w[0])
        );
        for(i = 1; i < PE_NUMBER; i = i + 1) begin : generateArray
            always_ff @(posedge clk) begin
                delay_buffer[i*(i+1)/2] <= pe_t_w[i];
            end
            if(1 < i) begin
                for(j = i*(i-1)/2+1; j < i*(i+1)/2; j = j + 1) begin : generate_delay_buffer
                    always_ff @(posedge clk) begin
                        delay_buffer[j] <= delay_buffer[j+1];
                    end
                end
            end
            assign pe_t_w_delayed[i] = delay_buffer[i*(i-1)/2+1];
            PE PE(
                .clk    (clk    ),
                .read   (read   ),
                .reset  (reset  ),
                .l_d_i  (pe_c_w[i-1]),
                .r_d_i  (pe_r_w[i+1]),
                .t_d_i  (pe_t_w_delayed[i]),
                .l_d_o  (pe_r_w[i]),
                .r_d_o  (pe_c_w[i])
            );
        end
    endgenerate
    assign l_d_o = pe_r_w[0];
endmodule
