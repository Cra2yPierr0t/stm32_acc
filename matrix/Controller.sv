module Controller(
    input   clk,
    output  logic read,
    output  logic reset,
    bus_if.slv_port vec_csr_if,
    bus_if.slv_port mat_csr_if,
    bus_if.slv_port csr_if
);

parameter WAIT  = 2'b00;
parameter CAL   = 2'b01;
parameter READ  = 2'b10;

    logic [7:0] row_size;
    logic [7:0] column_size;

    logic [7:0] cal_cnt = 8'h00;
    logic [7:0] read_cnt = 8'h00;

    logic   run_req = 0;

    logic [1:0] state = WAIT;

    always_ff @(posedge vec_csr_if.valid) begin
        row_size    <= vec_csr_if.data;
    end
    always_ff @(posedge mat_csr_if.valid) begin
        column_size <= mat_csr_if.data;
    end
    always_ff @(posedge csr_if.valid) begin
        run_req <= csr_if.data[0];
    end

    always_ff @(posedge clk) begin
        case(state)
            WAIT    : begin
                if(run_req == 1) begin
                    state <= CAL;
                end else begin
                    state <= WAIT;
                end
                reset   <= 1;
                read    <= 0;
                vec_csr_if.ready <= 1;
                mat_csr_if.ready <= 1;
                csr_if.ready <= 1;
            end
            CAL     : begin
                if(cal_cnt < row_size + column_size - 1 - 1) begin
                    cal_cnt <= cal_cnt + 8'h01;
                end else begin
                    state   <= READ;
                    cal_cnt <= 8'h00;
                end
                reset   <= 0;
                read    <= 0;
                vec_csr_if.ready <= 0;
                mat_csr_if.ready <= 0;
                csr_if.ready <= 0;
            end
            READ    : begin
                if(read_cnt < column_size - 1) begin //case文でステートマシンを作るときのカスみたいな記述
                    read_cnt <= read_cnt + 8'h01;
                end else begin
                    state   <= WAIT;
                    read_cnt <= 8'h00;
                end
                reset   <= 0;
                read    <= 1;
                vec_csr_if.ready <= 0;
                mat_csr_if.ready <= 0;
                csr_if.ready <= 0;
            end
        endcase
    end
endmodule
