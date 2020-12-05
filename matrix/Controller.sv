module Controller #(
    parameter ADDR_SIZE = 10,
    parameter PE_NUMBER = 64,
    parameter MEM_HEAD_ADDR = 16'h000f,
    parameter ZERO_POINT_ADDR = 16'hffff
)(
    input   clk,
    output  logic read,
    output  logic reset,
    bus_if.slv_port vec_csr_if,
    bus_if.slv_port mat_csr_if,
    bus_if.slv_port csr_if,
    output  logic [ADDR_SIZE-1:0] pe_t_o_addr[0:PE_NUMBER-1],
    output  logic [ADDR_SIZE-1:0] l_d_o_addr
);

parameter WAIT  = 2'b00;
parameter CAL   = 2'b01;
parameter READ  = 2'b10;

parameter MEM_WAIT  = 2'b00;
parameter MEM_FETCH = 2'b01;
parameter MEM_WRITE = 2'b10;
parameter MEM_CAL_WAIT = 2'b11;

    logic [7:0] row_size;
    logic [7:0] column_size;

    logic [7:0] mem_index = '0;

    logic [7:0] cal_cnt = 8'h00;
    logic [7:0] read_cnt = 8'h00;

    logic   run_req = 0;

    logic [1:0] array_state = WAIT;
    logic [1:0] mem_state   = WAIT;

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
        case(array_state)
            WAIT    : begin
                if(run_req == 1) begin
                    array_state <= CAL;
                end else begin
                    array_state <= WAIT;
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
                    array_state   <= READ;
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
                    array_state   <= WAIT;
                    read_cnt <= 8'h00;
                end
                reset   <= 0;
                read    <= 1;
                vec_csr_if.ready <= 0;
                mat_csr_if.ready <= 0;
                csr_if.ready <= 0;
            end
        endcase

        case(mem_state)
            MEM_WAIT    : begin
                if(run_req == 1) begin
                    mem_state <= MEM_FETCH;
                end else begin
                    mem_state <= MEM_WAIT;
                end
            end
            MEM_FETCH   : begin
                genvar i;
                generate 
                    for(i = 0; i < PE_NUMBER; i = i + 1) begin : gen_fetch_system
                        if(row_size < i) begin
                            if(column_cnt < column_size) begin
                                pe_t_o_addr[i] <= MEM_HEAD_ADDR + 1 + row_size + i + mem_index;
                            end else begin
                                pe_t_o_addr[i] <= ZERO_POINT_ADDR;
                            end
                        end else begin
                            pe_t_o_addr[i] <= ZERO_POINT_ADDR; 
                        end
                    end
                    if(column_cnt < column_size) begin
                        column_cnt <= column_cnt + 1;
                        mem_index <= mem_index + column_size;
                    end else begin
                        column_cnt <= '0;
                        mem_index <= '0;
                    end
                endgenerate

                if(row_cnt < row_size) begin    //vec fetch
                    l_d_o_addr <= MEM_HEAD_ADDR + 1 + row_cnt;
                    row_cnt <= row_cnt + 1;
                    mem_state <= state;
                end else begin
                    l_d_o_addr <= ZERO_POINT_ADDR;
                    row_cnt <= '0;
                    mem_state <= MEM_CAL_WAIT;
                end
            end
            MEM_CAL_WAIT    : begin
                if(cal_cnt < row_size + column_size - 1 - 1) begin
                    mem_state <= mem_state;
                end else begin
                    mem_state <= MEM_WRITE;
                end
            end
            MEM_WRITE   : begin
                if(read_cnt < column_size - 1) begin
                    mem_state <= mem_state;
                end else begin
                    mem_state <= MEM_WAIT;
                end
            end
        endcase
    end
endmodule
