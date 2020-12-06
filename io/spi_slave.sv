module spi_slave #(
    parameter FPGA_CLK  = 12_000_000,
    parameter SPI_CLK   = 1_000_000,
    parameter DATA_SIZE = 16
)(
    input logic cs,
    spi_if.slv_port spi_port,
    bus_if.mst_port bus_mst_port,
    bus_if.mst_port bus_slv_port
);

    logic   [DATA_SIZE-1:0] mo_data;
    logic   [3:0] mo_data_index = 4'b0000;

    always_ff @(posedge spi_port.sclk) begin    // read
        if(cs == 0) begin
            mo_data[mo_data_index] <= spi_port.mosi;
            if(mo_data_index == DATA_SIZE - 1) begin
                mo_data_index <='0;
            end else begin
                mo_data_index <= mo_data_index + '1;
            end
        end else begin
            mo_data_index <= mo_data_index;
        end
    end

    logic   [DATA_SIZE-1:0] so_data = 16'h5555;
    logic   [3:0] so_data_index = 4'b0000;

    always_ff @(posedge bus_slv_port.valid) begin
        so_data <= bus_slv_port.data;
    end

    always_ff @(negedge spi_port.sclk) begin    // write
        if(cs == 0) begin
            spi_port.miso <= so_data[so_data_index];
            if(so_data_index == DATA_SIZE - 1) begin
                so_data_index <= '0;
                bus_slv_port.ready <= '1;
            end else begin
                so_data_index <= so_data_index + '1;
                bus_slv_port.ready <= '0;
            end
        end else begin
            so_data_index <= so_data_index;
        end
    end

    always_comb begin
        bus_mst_port.valid = (mo_data_index == '0);
        bus_mst_port.data  = mo_data;
    end
endmodule
