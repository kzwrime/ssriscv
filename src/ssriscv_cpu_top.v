`include "src/ssriscv_data_mem.v"
`include "src/ssriscv_defines.v"
`include "src/ssriscv_exu_alu.v"
`include "src/ssriscv_id_decoder.v"
`include "src/ssriscv_ifu_imem.v"
`include "src/ssriscv_ifu_pc.v"
`include "src/ssriscv_reg.v"
`include "src/ssriscv_npc.v"

module ssriscv_cpu_top (
    input clk,
    input rst_n,
    output error
);

    wire bxx_test;
    // wire [1:0]  pc_src;
    // wire [31:0] pc_in;
    wire [31:0] pc_rst = 32'b0;
    wire [31:0] pc_now;
    wire [31:0] pc_next;
    wire pc_write_back;

    wire [31:0] instr;
    wire [2:0]  func3;
    wire [4:0]  rs1, rs2, rd;
    wire [31:0] imm;
    
    wire [2:0] alu_op;
    wire alu_op1_reg_pc;
    wire alu_op2_reg_imm;
    wire alu_arith;
    wire reg_write;
    wire writeback_alu_mem;
    wire mem_read = is_load;
    wire mem_write = is_store;

    wire is_alu, is_load, is_store, is_bxx, is_jal, is_jalr;

    wire error1, error2;
    assign error = error1 | error2;

    wire [31:0] alu_in1, alu_in2, alu_out;
    
    wire [31:0] reg_read_data1, reg_read_data2;
    wire [31:0] reg_write_data;

    wire [31:0] mem_read_data;

    assign alu_in1 = alu_op1_reg_pc ? pc_now : reg_read_data1;
    assign alu_in2 = (is_jal | is_jalr) ? 4 : alu_op2_reg_imm ? imm : reg_read_data2;
    assign reg_write_data = writeback_alu_mem ? mem_read_data : alu_out;
    // assign pc_in   = imm;

    ssriscv_ifu_pc SV_IFU_PC(
        .clk(clk),
        .rst_n(rst_n),
        .pc_rst(pc_rst),
        .pc_next(pc_next),
        .pc_now(pc_now)
    );

    ssriscv_npc SV_NPC(
        .test(bxx_test),
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .is_bxx(is_bxx),
        .pc_now(pc_now),
        .imm(imm),
        .reg_read_data1(reg_read_data1),
        .pc_next(pc_next)
    );

    ssriscv_ifu_imem SV_IFU_IMEM(
        .addr(pc_now),
        .instr(instr)
    );

    ssriscv_id_decoder SV_ID_DECODER(
        .instr(instr),
        .func3(func3),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .alu_op(alu_op),
        .alu_op1_reg_pc(alu_op1_reg_pc),
        .alu_op2_reg_imm(alu_op2_reg_imm),
        .alu_arith(alu_arith),
        .reg_write(reg_write),
        .writeback_alu_mem(writeback_alu_mem),
        .pc_write_back(pc_write_back),
        // .pc_src(pc_src),
        .is_alu(is_alu), .is_load(is_load), .is_store(is_store),
        .is_bxx(is_bxx), .is_jal(is_jal), .is_jalr(is_jalr),
        .imm(imm),
        .error(error)
    );
    
    ssriscv_regfile SV_REGFILE(
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(reg_write),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .reg_write_data(reg_write_data),
        .reg_read_data1(reg_read_data1),
        .reg_read_data2(reg_read_data2)
    );

    ssriscv_exu_alu SV_EXU_ALU(
        .alu_in1(alu_in1),
        .alu_in2(alu_in2),
        .alu_out(alu_out),
        .alu_op(alu_op),
        .alu_arith(alu_arith),
        .is_bxx(is_bxx),
        .test(bxx_test)
    );

    ssriscv_data_mem SV_DATA_MEM(
        .clk(clk),
        .mem_addr(alu_out),
        .mem_write_data(reg_read_data2),
        .func(func3),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_read_data(mem_read_data)
    );

    `ifdef TEST_BENCH
        always @(*) begin
            if(error) begin
                $display("ERROR\n");
                $finish;
            end
        end
    `endif

endmodule