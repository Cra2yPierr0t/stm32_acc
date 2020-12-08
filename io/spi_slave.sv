module spi_slave #(
    parameter DATA_SIZE = 16,
    parameter INDEX_WIDTH = 4,
    parameter FPGA_CLK  = 12_000_000,
    parameter SPI_CLK   = 1_000_000
)(
    input logic clk,
    input logic cs,
    spi_if.slv_port spi_port,
    bus_if.mst_port bus_mst_port,
    bus_if.slv_port bus_slv_port
);

    logic   [DATA_SIZE-1:0] mo_data;
    logic   [INDEX_WIDTH-1:0] mo_data_index = '0;

    logic   [DATA_SIZE-1:0] so_data = 16'h0000;
    logic   [INDEX_WIDTH-1:0] so_data_index = DATA_SIZE-1;

    logic [1:0] shift_reg = 2'b00;
    logic [1:0] shift_reg_2 = 2'b00;

    always_ff @(posedge clk) begin
        shift_reg <= {shift_reg[0], spi_port.sclk};
        if(shift_reg == 2'b01) begin    // read
            if(cs == 0) begin
                mo_data[~mo_data_index] <= spi_port.mosi;
                mo_data_index <= mo_data_index + 1;
            end else begin
                mo_data <= mo_data;
            end
        end else begin
            mo_data <= mo_data;
            mo_data_index <= mo_data_index;
        end
        
        shift_reg_2 <= {shift_reg_2[0], bus_slv_port.valid};
        if(shift_reg == 2'b10) begin    // write
            if(cs == 0) begin
                //spi_port.miso <= so_data[so_data_index];
                so_data <= {so_data[DATA_SIZE-2:0], 1'b0};
                so_data_index <= so_data_index - 1;
            end else begin
                so_data_index <= DATA_SIZE - 1;
            end
        end else if(shift_reg_2 == 2'b01) begin
            so_data <= bus_slv_port.data;
            so_data_index <= DATA_SIZE - 1;
        end else begin
            so_data <= so_data; 
            so_data_index <= so_data_index;
        end
    end

    always_comb begin
        bus_mst_port.valid = (mo_data_index == '0);
        bus_mst_port.data  = mo_data;
        spi_port.miso <= so_data[DATA_SIZE-1];
        if(so_data_index == DATA_SIZE-1) begin
            bus_slv_port.ready = 1;
        end else begin
            bus_slv_port.ready = 0;
        end
    end
endmodule
