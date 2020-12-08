module TOY_Accelerator #(
    parameter PE_NUMBER = 20
)(
    input logic clk,
    spi_if.slv_port spi_port,
    input logic cs
);

    bus_if spi_2_bus_if();
    bus_if bus_2_spi_if();

    logic read, reset;
    logic [15:0] l_d_i;
    logic [15:0] l_d_o;
    logic [9:0] l_d_o_addr;
    logic [15:0] pe_t_w[0:PE_NUMBER-1];
    logic [9:0] pe_t_o_addr[0:PE_NUMBER-1];
    logic [9:0] w_addr;
    logic [15:0] w_data;
    logic w_en;
    logic [9:0] r_addr;
    logic [15:0] mem_r_data;

    bus_if vec_csr_if();
    bus_if mat_csr_if();
    bus_if csr_if();

    spi_slave slave (
        .clk            (clk            ),
        .cs             (cs             ),
        .spi_port       (spi_port       ),
        .bus_mst_port   (spi_2_bus_if   ),
        .bus_slv_port   (bus_2_spi_if   ),
    );

    Systolic_array #(
        .PE_NUMBER  (PE_NUMBER)
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
        .PE_NUMBER  (PE_NUMBER)
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
        .bus_2_spi_if   (),
        .vec_csr_if     (vec_csr_if     ),
        .mat_csr_if     (mat_csr_if     ),
        .csr_if         (csr_if         )
    );

    Controller #(
        .PE_NUMBER      (PE_NUMBER),
        .MEM_HEAD_ADDR  (0),
        .ZERO_POINT_ADDR(10'b11_1111_1111)
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


endmodule
