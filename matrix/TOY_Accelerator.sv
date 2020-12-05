module TOY_accelerator(
    input logic clk,
    spi_if.slv_port spi_port
);

    bus_if spi_2_bus_if();

    spi_slave slave (
        .spi_port       (spi_port       ),
        .bus_mst_port   (spi_2_bus_if   )
    );

    Systolic_array #(
        .PE_NUMBER  (64)
    ) Systolic_Array (
        .clk    (clk    ),
        .read   (read   ),
        .reset  (reset  ),
        .l_d_i  (l_d_i  ),
        .l_d_o  (l_d_o  ),
        .pe_t_w (pe_t_w )
    );

    Memory #(
        .MEM_SIZE   (),
        .ADDR_SIZE  (),
        .WORD_SIZE  (),
        .PE_NUMBER  ()
    ) Memory (
        .clk            (),
        .w_addr         (),
        .w_en           (),
        .r_addr         (),
        .r_data         (),
        .l_d_o          (),
        .l_d_o_addr     (),
        .pe_t_w         (),
        .pe_t_o_addr    ()
    );

    Controller #(
        .PE_NUMBER      (64),
        .MEM_HEAD_ADDR  (0),
        .ZERO_POINT_ADDR(16'h5555)
    ) Controller (
        .clk            (clk    ),
        .read           (read   ),
        .reset          (reset  ),
        .vec_csr_if     (vec_csr_if ),
        .mat_csr_if     (mat_csr_if ),
        .csr_if         (csr_if ),
        .pe_t_o_addr    (pe_t_o_addr    ),
        .l_d_o_addr     (l_d_o_addr     ),
        .w_addr         (),
        .w_en           ()
    );


endmodule
