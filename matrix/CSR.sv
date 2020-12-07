module CSR #(
    parameter GENERAL_CSR_ADDR = 12'h000,
    parameter WRITE_COMMAND = 4'h1,
    parameter READ_COMMAND = 4'h2,
    parameter VEC_CSR_ADDR = 12'h001,
    parameter MAT_CSR_ADDR = 12'h002
)(
    input   logic clk,
    bus_if.slv_port spi_2_bus_if,
    bus_if.mst_port bus_2_spi_if,
    bus_if.mst_port vec_csr_if,
    bus_if.mst_port mat_csr_if,
    bus_if.mst_port csr_if
);

    logic w_flag = 0;
    logic [11:0] w_addr;
    logic r_flag = 0;
    logic [11:0] r_addr;

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
                {WRITE_COMMAND, GENERAL_CSR_ADDR}   : begin
                    w_flag <= 1;
                    w_addr <= spi_2_bus_if.data[11:0];
                end
                {READ_COMMAND, VEC_CSR_ADDR} : begin
                    r_addr <= spi_2_bus_if.data[11:0];
                end
                {READ_COMMAND, MAT_CSR_ADDR} : begin
                    r_addr <= spi_2_bus_if.data[11:0];
                end
                {READ_COMMAND, GENERAL_CSR_ADDR} : begin
                    r_addr <= spi_2_bus_if.data[11:0];
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

    always_ff @(posedge clk) begin
        if(bus_2_spi_if.ready) begin
            case(r_addr)
                VEC_CSR_ADDR    : begin
                    bus_2_spi_if.data <= vec_csr_if.data;
                    bus_2_spi_if.valid <= 1;
                end
                MAT_CSR_ADDR    : begin
                    bus_2_spi_if.data <= mat_csr_if.data;
                    bus_2_spi_if.valid <= 1;
                end
                GENERAL_CSR_ADDR    : begin
                    bus_2_spi_if.data <= csr_if.data;
                    bus_2_spi_if.valid <= 1;
                end
                default : begin
                    bus_2_spi_if.data <= bus_2_spi_if.data;
                    bus_2_spi_if.valid <= 0;
                end
            endcase
        end else begin
            bus_2_spi_if.valid <= 0;
        end
    end
endmodule
