interface bus_if;
    logic   ready;
    logic   valid;
    logic   [15:0] data;
    modport mst_port(input ready, output valid, data);
    modport slv_port(input valid, data, output ready);
endinterface

interface spi_if;
    logic   sclk;
    logic   miso;
    logic   mosi;
    modport mst_port(input miso, output sclk, mosi);
    modport slv_port(input sclk, mosi, output miso);
endinterface
