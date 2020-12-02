module spi_slave #(
    parameter FPGA_CLK  = 12_000_000,
    parameter SPI_CLK   = 1_000_000
)(
    spi_if.slv_port spi_port,
    bus_if.mst_port bus_mst_port
);

    logic   [7:0] mo_data;
    logic   [2:0] mo_data_index = 3'b000;

    always_ff @(posedge spi_port.sclk) begin    // read
        mo_data[mo_data_index] <= spi_port.mosi;
        mo_data_index <= mo_data_index + 3'b001;
    end

    logic   [7:0] so_data;
    logic   [2:0] so_data_index = 3'b000;

    always_ff @(negedge spi_port.sclk) begin    // write
        spi_port.miso <= so_data[so_data_index];
        so_data_index <= so_data_index + 3'b001;
    end

    always_comb begin
        bus_mst_port.valid = (mo_data_index == 3'b000);
        bus_mst_port.data  = mo_data;
    end
endmodule
