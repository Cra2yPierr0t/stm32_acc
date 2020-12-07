module TOY_accelerator(
    input logic clk,
    spi_if.slv_port spi_port,
    input logic cs
);

    bus_if spi_2_bus_if();

    spi_slave slave (
        .clk            (clk            ),
        .cs             (cs             ),
        .spi_port       (spi_port       ),
        .bus_mst_port   (spi_2_bus_if   ),
        .bus_slv_port   (bus_2_spi_if   ),
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
        .PE_NUMBER      (64),
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


endmodule
