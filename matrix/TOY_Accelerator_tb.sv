`include "../io/if.sv"
module TOY_accelerator_tb(
    input logic clk
);

    bus_if spi_2_bus_if();
    bus_if bus_2_spi_if();
    bus_if bus_2_spi_if_dummy();

    logic read, reset;
    logic [15:0] l_d_i;
    logic [15:0] l_d_o;
    logic [9:0] l_d_o_addr;
    logic [15:0] pe_t_w[0:2];
    logic [9:0] pe_t_o_addr[0:2];
    logic [9:0] w_addr;
    logic [15:0] w_data;
    logic w_en;
    logic [9:0] r_addr;
    logic [15:0] mem_r_data;

    bus_if vec_csr_if();
    bus_if mat_csr_if();
    bus_if csr_if();

    Systolic_array #(
        .PE_NUMBER  (3)
    ) Systolic_Array (
        .clk    (clk    ),
        .read   (read   ),
        .reset  (reset  ),
        .l_d_i  (l_d_i  ),
        .l_d_o  (l_d_o  ),
        .pe_t_w (pe_t_w )
    );

    Memory #(
        .MEM_SIZE   (1024),
        .ADDR_SIZE  (10),
        .WORD_SIZE  (16),
        .PE_NUMBER  (3)
    ) Memory (
        .clk            (clk            ),
        .w_addr         (w_addr         ),
        .w_data         (w_data         ),
        .w_en           (w_en           ),
        .r_addr         (r_addr         ),
        .r_data         (mem_r_data     ),
        .l_d_o          (l_d_i          ),
        .l_d_o_addr     (l_d_o_addr     ),
        .pe_t_w         (pe_t_w         ),
        .pe_t_o_addr    (pe_t_o_addr    )
    );

    CSR CSR (
        .clk    (clk    ),
        .spi_2_bus_if   (spi_2_bus_if   ),
        .bus_2_spi_if   (bus_2_spi_if_dummy),
        .vec_csr_if     (vec_csr_if     ),
        .mat_csr_if     (mat_csr_if     ),
        .csr_if         (csr_if         )
    );

    Controller #(
        .PE_NUMBER      (3),
        .MEM_HEAD_ADDR  (0),
        .ZERO_POINT_ADDR(16'h5555)
    ) Controller (
        .clk            (clk    ),
        .read           (read   ),
        .reset          (reset  ),
        .vec_csr_if     (vec_csr_if ),
        .mat_csr_if     (mat_csr_if ),
        .spi_2_bus_if   (spi_2_bus_if   ),
        .bus_2_spi_if   (bus_2_spi_if   ),
        .csr_if         (csr_if         ),
        .pe_t_o_addr    (pe_t_o_addr    ),
        .l_d_o_addr     (l_d_o_addr     ),
        .w_addr         (w_addr         ),
        .w_data         (w_data         ),
        .w_en           (w_en           ),
        .r_addr         (r_addr         ),
        .l_d_o          (l_d_o          ),
        .mem_r_data     (mem_r_data     )
    );

    logic [31:0] cnt = 32'h0000_0000;
    logic [31:0] cnt_w = 32'h0000_0000;

    assign cnt_w = cnt + 1;
    always_ff @(posedge clk) begin
        cnt <= cnt_w;
        if(cnt <= 2) begin
            spi_2_bus_if.data <= 16'h1001;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 3) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 4) begin
            spi_2_bus_if.data <= 16'h0003;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 5) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 6) begin
            spi_2_bus_if.data <= 16'h1002;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 7) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 8) begin
            spi_2_bus_if.data <= 16'h0002;
            spi_2_bus_if.valid <= 1;
        end else if((8 < cnt) && (cnt < 12)) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 12) begin
            spi_2_bus_if.data <= 16'h4000;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 13) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 14) begin
            spi_2_bus_if.data <= 16'h0012;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 15) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 16) begin
            spi_2_bus_if.data <= 16'h0035;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 17) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 18) begin
            spi_2_bus_if.data <= 16'h002a;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 19) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 20) begin
            spi_2_bus_if.data <= 16'h5000;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 21) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 22) begin
            spi_2_bus_if.data <= 16'h0031;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 23) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 24) begin
            spi_2_bus_if.data <= 16'h0050;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 25) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 26) begin
            spi_2_bus_if.data <= 16'h0001;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 27) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 28) begin
            spi_2_bus_if.data <= 16'h0012;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 29) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 30) begin
            spi_2_bus_if.data <= 16'h000a;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 31) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 32) begin
            spi_2_bus_if.data <= 16'h0002;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 33) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 34) begin
            spi_2_bus_if.data <= 16'h3000;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 35) begin
            spi_2_bus_if.valid <= 0;
        end else if((35 < cnt) && (cnt < 52)) begin
            spi_2_bus_if.valid <= 0;
        end else if(cnt == 52) begin
            spi_2_bus_if.data <= 16'h6000;
            spi_2_bus_if.valid <= 1;
        end else if(cnt == 53) begin
            spi_2_bus_if.valid <= 0;
        end else if((53 < cnt) && (cnt < 55)) begin
            spi_2_bus_if.valid <= 0;
            bus_2_spi_if.ready <= 0;
        end else if(cnt == 55) begin
            bus_2_spi_if.ready <= 1;
        end else if(cnt == 56) begin
            bus_2_spi_if.ready <= 0;
        end else if(cnt == 57) begin
            bus_2_spi_if.ready <= 0;
        end else if(cnt == 58) begin
            bus_2_spi_if.ready <= 0;
        end else if(cnt == 59) begin
            bus_2_spi_if.ready <= 1;
        end else if(cnt == 60) begin
            bus_2_spi_if.ready <= 0;
        end else if(cnt == 61) begin
            bus_2_spi_if.ready <= 0;
        end else if(cnt == 62) begin
            bus_2_spi_if.ready <= 0;
        end else if(cnt == 63) begin
            bus_2_spi_if.ready <= 0;
        end else begin
            bus_2_spi_if.ready <= 0;
        end
    end

endmodule
