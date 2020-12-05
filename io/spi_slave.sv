module spi_slave #(
    parameter FPGA_CLK  = 12_000_000,
    parameter SPI_CLK   = 1_000_000,
    parameter DATA_SIZE = 16
)(
    spi_if.slv_port spi_port,
    bus_if.mst_port bus_mst_port
);

    logic   [DATA_SIZE-1:0] mo_data;
    logic   [3:0] mo_data_index = 4'b0000;

    always_ff @(posedge spi_port.sclk) begin    // read
        mo_data[mo_data_index] <= spi_port.mosi;
        if(mo_data_index == DATA_SIZE - 1) begin
            mo_data_index <='0;
        end else begin
            mo_data_index <= mo_data_index + '1;
        end
    end

    logic   [DATA_SIZE-1:0] so_data;
    logic   [3:0] so_data_index = 4'b0000;

    always_ff @(negedge spi_port.sclk) begin    // write
        spi_port.miso <= so_data[so_data_index];
        if(so_data_index == DATA_SIZE - 1) begin
            so_data_index <= '0;
        end else begin
            so_data_index <= so_data_index + '1;
        end
    end

    always_comb begin
        bus_mst_port.valid = (mo_data_index == '0);
        bus_mst_port.data  = mo_data;
    end
endmodule
