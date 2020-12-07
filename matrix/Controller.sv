module Controller #(
    parameter ADDR_SIZE = 10,
    parameter WORD_SIZE = 16,
    parameter PE_NUMBER = 64,
    parameter MEM_HEAD_ADDR = 16'h000f,
    parameter ZERO_POINT_ADDR = 16'hffff,
    parameter START_CAL = 4'h3,
    parameter WRITE_VEC = 4'h4,
    parameter WRITE_MAT = 4'h5,
    parameter READ_RESULT = 4'h6
)(
    input   clk,
    bus_if.slv_port spi_2_bus_if,
    bus_if.mst_port bus_2_spi_if,
    output  logic read,
    output  logic reset,
    bus_if.slv_port vec_csr_if,
    bus_if.slv_port mat_csr_if,
    bus_if.slv_port csr_if,
    output  logic [ADDR_SIZE-1:0] pe_t_o_addr[0:PE_NUMBER-1],
    output  logic [ADDR_SIZE-1:0] l_d_o_addr,
    output  logic [WORD_SIZE-1:0] w_data,
    output  logic [ADDR_SIZE-1:0] w_addr,
    output  logic w_en,
    output  logic [ADDR_SIZE-1:0] r_addr,
    input   logic [WORD_SIZE-1:0] l_d_o,
    input   logic [WORD_SIZE-1:0] mem_r_data
);

parameter WAIT  = 2'b00;
parameter CAL   = 2'b01;
parameter READ  = 2'b10;

parameter MEM_WAIT  = 2'b00;
parameter MEM_FETCH = 2'b01;
parameter MEM_WRITE = 2'b10;
parameter MEM_CAL_WAIT = 2'b11;

    logic w_en_result;
    logic w_en_data;

    logic [ADDR_SIZE-1:0] w_addr_result;
    logic [ADDR_SIZE-1:0] w_addr_data;

    logic [WORD_SIZE-1:0] w_data_result;
    logic [WORD_SIZE-1:0] w_data_data;

    logic [7:0] row_size;
    logic [7:0] column_size;

    logic [7:0] mem_index = '0;

    logic [7:0] cal_cnt = 8'h00;
    logic [7:0] read_cnt = 8'h00;

    logic [7:0] row_cnt = '0;
    logic [7:0] column_cnt = '0;

    logic   run_req = 0;

    logic [1:0] array_state = WAIT;
    logic [1:0] mem_state   = WAIT;

    logic [ADDR_SIZE-1:0] w_addr_buf = '0;
    logic [ADDR_SIZE-1:0] w_addr_buf_buf = '0;
    logic [ADDR_SIZE-1:0] w_addr_cnt = '0;

    logic [ADDR_SIZE-1:0] r_addr_cnt = '0;

    logic [1:0] start_shift_reg;
    logic start_flag = 0;

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
        start_shift_reg <= {start_shift_reg[0], start_flag};
        case(array_state)
            WAIT    : begin
                if(start_shift_reg == 2'b01) begin
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
                if(cal_cnt < row_size + column_size - 1) begin
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
                if(start_shift_reg == 2'b01) begin
                    mem_state <= MEM_FETCH;
                end else begin
                    mem_state <= MEM_WAIT;
                end
                l_d_o_addr <= ZERO_POINT_ADDR;
                w_en_result <= '0;
                w_addr_cnt  <= '0;
                column_cnt  <= '0;
            end
            MEM_FETCH   : begin
                if(column_cnt < column_size) begin
                    column_cnt <= column_cnt + 1;
                    mem_index <= mem_index + row_size;
                    w_addr_buf  <= MEM_HEAD_ADDR + row_size + row_size - 1 + mem_index;
                end else begin
                    column_cnt <= column_cnt;
                    mem_index <= '0;
                    w_addr_buf  <= w_addr_buf;
                end
                if(row_cnt < row_size) begin    //vec fetch
                    l_d_o_addr <= MEM_HEAD_ADDR + row_cnt;
                    row_cnt <= row_cnt + 1;
                    mem_state <= mem_state;
                end else begin
                    l_d_o_addr <= ZERO_POINT_ADDR;
                    row_cnt <= '0;
                    mem_state <= MEM_CAL_WAIT;
                end
            end
            MEM_CAL_WAIT    : begin
                if(cal_cnt < row_size + column_size - 1) begin
                    mem_state <= mem_state;
                end else begin
                    mem_state <= MEM_WRITE;
                end
            end
            MEM_WRITE   : begin //アレイからメモリへの結果書き込み
                if(read_cnt < column_size - 1) begin
                    mem_state <= mem_state;
                end else begin
                    mem_state <= MEM_WAIT;
                end
                w_addr_buf_buf <= w_addr_buf;
                w_en_result <= '1;
                w_addr_result   <= w_addr_buf + 1 + w_addr_cnt;
                w_addr_cnt  <= w_addr_cnt + 1;
            end
        endcase
    end
    genvar i;
    generate 
    for(i = 0; i < PE_NUMBER; i = i + 1) begin : gen_fetch_system
        always_ff @(posedge clk) begin
            if(mem_state == MEM_FETCH) begin
                if(row_size > i) begin
                    if(column_cnt < column_size) begin
                        pe_t_o_addr[i]  <= MEM_HEAD_ADDR + row_size + i + mem_index;
                    end else begin
                        pe_t_o_addr[i]  <= ZERO_POINT_ADDR;
                    end
                end else begin
                    pe_t_o_addr[i] <= ZERO_POINT_ADDR; 
                end
            end else begin
                pe_t_o_addr[i] <= ZERO_POINT_ADDR; 
            end
        end
    end
    endgenerate

    logic [1:0] spi_shift_reg;
    logic [1:0] vec_shift_reg;
    logic [1:0] mat_shift_reg;
    logic [1:0] read_shift_reg;
    logic [1:0] spi_ready_shift_reg;

    logic write_vec_flag = 0;
    logic write_mat_flag = 0;
    logic read_result_flag = 0;

    logic end_vec_flag = 0;
    logic end_mat_flag = 0;
    logic end_read_flag = 0;

    logic [9:0] mat_sub_cnt = '0;
    logic [9:0] mat_sub_sub_cnt = '0;

    logic [9:0] result_addr = '0;

    logic [9:0] vec_addr = '0;
    logic [9:0] mat_addr = '0;

    always_ff @(posedge clk) begin
        spi_shift_reg <= {spi_shift_reg[0], spi_2_bus_if.valid};
        vec_shift_reg <= {vec_shift_reg[0], end_vec_flag};
        mat_shift_reg <= {mat_shift_reg[0], end_mat_flag};
        read_shift_reg <= {read_shift_reg[0], end_read_flag};
        spi_ready_shift_reg <= {spi_ready_shift_reg[0], bus_2_spi_if.ready};
        if((write_vec_flag == 0) && (write_mat_flag == 0)) begin
            if(spi_shift_reg == 2'b01) begin
                case(spi_2_bus_if.data[15:12])
                    START_CAL   : begin
                        start_flag <= 1;
                    end
                    WRITE_VEC   : begin
                        write_vec_flag <= 1;
                    end
                    WRITE_MAT   : begin
                        write_mat_flag <= 1;
                    end
                    READ_RESULT : begin //TPUからマイコンへの結果書き出し
                        read_result_flag <= 1;
                    end
                    default     : begin
                    end
                endcase
            end
        end else begin
            if(vec_shift_reg == 2'b01) begin
                write_vec_flag <= 0;
            end
            if(mat_shift_reg == 2'b01) begin
                write_mat_flag <= 0;
            end
            if(read_shift_reg == 2'b01) begin
                read_result_flag <= 0;
            end
            start_flag <= 0;
        end

        if(write_vec_flag == 1) begin
            if(spi_shift_reg == 2'b01) begin
                w_en_data <= 1;
                w_addr_data <= vec_addr;
                w_data_data <= spi_2_bus_if.data;
                if(vec_addr == row_size - 1) begin
                    vec_addr <= 0;
                    write_vec_flag <= 0;
                    end_vec_flag <= 1;
                end else begin
                    vec_addr <= vec_addr + 1;
                    end_vec_flag <= 0;
                end
            end else begin
                w_en_data <= 0;
            end
        end else if(write_mat_flag == 1) begin
            if(spi_shift_reg == 2'b01) begin
                w_en_data <= 1;
                w_addr_data <= mat_addr + row_size;
                w_data_data <= spi_2_bus_if.data;
                if((mat_sub_cnt == column_size - 1) && (mat_sub_sub_cnt == row_size - 1)) begin
                    mat_sub_cnt <= 0;
                    end_mat_flag <= 1;
                    mat_addr <= 0;
                end else if(mat_sub_sub_cnt == row_size - 1) begin
                    mat_sub_sub_cnt <= 0;
                    mat_addr <= mat_addr + 1;
                    mat_sub_cnt <= mat_sub_cnt + 1;
                end else begin
                    mat_sub_sub_cnt <= mat_sub_sub_cnt + 1;
                    mat_sub_cnt <= mat_sub_cnt;
                    mat_addr <= mat_addr + 1;
                    end_mat_flag <= 0;
                end
            end else begin
                w_en_data <= 0;
            end
        end else if(read_result_flag == 1) begin
            if(spi_ready_shift_reg == 2'b01) begin
                if(r_addr_cnt < column_size - 1) begin
                    r_addr_cnt <= r_addr_cnt + 1;
                    end_read_flag <= 0;
                end else begin
                    r_addr_cnt <= 0;
                    end_read_flag <= 1;
                end
                bus_2_spi_if.data   <= mem_r_data;
                bus_2_spi_if.valid  <= 1;
            end else begin
                r_addr_cnt <= r_addr_cnt;
            end
            w_en_data <= 1;
            r_addr <= w_addr_buf_buf + r_addr_cnt + 1;
        end else begin
            w_en_data <= 0;
            mat_addr <= 0;
            vec_addr <= 0;
        end
    end

    always_comb begin
        if(write_mat_flag || write_vec_flag) begin
            if(write_vec_flag) begin
                w_addr = vec_addr;
            end else begin
                w_addr = mat_addr + row_size;
            end
            if(spi_shift_reg == 2'b01) begin
                w_en = 1;
            end else begin
                w_en = 0;
            end
            w_data = spi_2_bus_if.data;
            //w_addr = w_addr_data;
            //w_data = w_data_data;
            //w_en   = w_en_data;
        end else begin
            w_en = w_en_result;
            w_addr = w_addr_result;
            w_data = l_d_o;
        end
    end

endmodule
