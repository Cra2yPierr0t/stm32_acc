module spi_tb(
    output logic [7:0] led,
    input logic cs,
    input logic clk,
    spi_if.slv_port spi_port
);
    
    bus_if bus_mst_port();

    spi_slave spi_slave(
        .*
    );

    always_ff @(posedge bus_mst_port.valid) begin
        led <= bus_mst_port.data[7:0];
    end
endmodule
