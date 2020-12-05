module #(
    parameter GENERAL_CSR_ADDR = 12'h000,
    parameter WRITE_COMMAND = 4'h1,
    parameter READ_COMMAND = 4'h1,
    parameter END_WRITE_COMMAND = 4'h2,
    parameter VEC_CSR_ADDR = 12'h001,
    parameter MAT_CSR_ADDR = 12'h002,
) CSR (
    bus_if.slv_port spi_2_bus_if,
    bus_if.mst_port vec_csr_if,
    bus_if.mst_port mat_csr_if,
    bus_if.mst_port csr_if
);

    logic w_flag = 0;
    logic [11:0] w_addr;

    always_ff @(posedge spi_2_bus_if.valid) begin
        if(w_flag) begin
            case(w_addr)
                VEC_CSR_ADDR    : begin
                    vec_csr_if.data <= spi_2_bus_if.data;
                    vec_csr_if.valid <= 1;
                    w_flag <= 0;
                end
                MAT_CSR_ADDR    : begin
                    mat_csr_if.data <= spi_2_bus_if.data;
                    mat_csr_if.valid <= 1;
                    w_flag <= 0;
                end
                GENERAL_CSR_ADDR : begin
                    csr_if.data <= spi_2_bus_if.data;
                    csr_if.valid <= 1;
                    w_flag <= 0;
                end
            endcase
        end else begin
            case(spi_2_bus_if.data)
                {WRITE_COMMAND, VEC_CSR_ADDR}   : begin
                    w_flag <= 1;
                    w_addr <= spi_2_bus_if.data[11:0];
                end
                {WRITE_COMMAND, MAT_CSR_ADDR}   : begin
                    w_flag <= 1;
                    w_addr <= spi_2_bus_if.data[11:0];
                end
                {WRITE_COMMAND, CSR_ADDR}   : begin
                    w_flag <= 1;
                    w_addr <= spi_2_bus_if.data[11:0];
                end
                {READ_COMMAND, VEC_CSR_ADDR} : begin
                    vec_csr_if.data;
                end
                default : begin
                    w_flag <= 0;
                end
            endcase
            vec_csr_if.valid <= 0;
            mat_csr_if.valid <= 0;
            csr_if.valid <= 0;
        end
    end
endmodule
