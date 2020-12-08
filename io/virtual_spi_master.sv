module virtual_spi_master(
    input logic clk,
    spi_if.mst_port spi_port
);
    logic [31:0] cnt = '0;
    logic vir_clk = 0;;
    logic [31:0] index_1 = '0;
    logic [3:0] index_2 = 4'hf;

    logic [15:0] mem[0:127];

    always_ff @(posedge clk) begin
        if(cnt == 32'h0000_0050) begin
            vir_clk <= ~vir_clk;
            cnt <= '0;
        end else begin
            vir_clk <= vir_clk;
            cnt <= cnt + 1;
        end
        mem[1] <= 16'h1001;
        mem[2] <= 16'h0002;
        mem[3] <= 16'h1002;
        mem[4] <= 16'h0003;
        mem[5] <= 16'h4000;
        mem[6] <= 16'h0003;
        mem[7] <= 16'h0004;
        mem[8] <= 16'h5000;
        mem[9] <= 16'h0003;
        mem[10] <= 16'h0005;
        mem[11] <= 16'h0002;
        mem[12] <= 16'h0004;
        mem[13] <= 16'h0007;
        mem[14] <= 16'h0001;
        mem[15] <= 16'h3000;
        mem[16] <= 16'h6000;
        mem[17] <= 16'h0000;
        mem[18] <= 16'h0000;
    end

    always_ff @(posedge vir_clk) begin
        spi_port.sclk <= ~spi_port.sclk;
    end

    always_ff @(negedge spi_port.sclk) begin
        if(index_2 == 4'h0) begin
            index_2 <= 4'hf;
            index_1 <= index_1 + 1;
        end else begin
            index_2 <= index_2 - 4'h1;
        end
    end
    assign spi_port.mosi = mem[index_1][index_2];


endmodule
