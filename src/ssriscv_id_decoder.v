`include "src/ssriscv_defines.v"

module ssriscv_id_decoder (
    input [31:0] instr,

    output [2:0] func3,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,

    output [2:0] alu_op,
    output alu_op1_reg_pc,  // 0:reg, 1:pc
    output alu_op2_reg_imm, // 0:reg, 1:imm
    output alu_arith,
    output reg_write,
    output writeback_alu_mem,   // 0:alu, 1:mem
    output pc_write_back,

    // output [1:0] pc_src,    // 00:pc+4, 10:alu(jmp), 01: test ? alu : pc+4
    //                         // pc_src[1] | (pc_src[0] & test) ? alu : pc+4
    
    output is_alu,
    output is_load,
    output is_store,
    output is_bxx,
    output is_jal,
    output is_jalr,

    output [31:0] imm,
    output error
);


    wire [6:0] opcode = instr[6:0];

    wire [31:0] Iimm = {{21{instr[31]}}, instr[30:20]};
    wire [31:0] Simm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
    wire [31:0] Bimm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] Uimm = {instr[31], instr[30:12], {12{1'b0}}};
    wire [31:0] Jimm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};   

    // 可以直接写成合取式
    assign is_alu   = (opcode == `INSTR_ALU);
    assign is_alui  = (opcode == `INSTR_ALUI);
    assign is_load  = (opcode == `INSTR_LOAD);
    assign is_store = (opcode == `INSTR_STORE);
    assign is_bxx   = (opcode == `INSTR_BXX);
    assign is_jal   = (opcode == `INSTR_JAL);
    assign is_jalr  = (opcode == `INSTR_JALR);
    wire   is_lui   = (opcode == `INSTR_LUI);
    wire   is_auipc = (opcode == `INSTR_AUIPC);
    wire   is_sys   = (opcode == `INSTR_SYSTEM);    // csr, env
    wire   is_env   = is_sys & (~(func3[2] | func3[1] | func3[0]));
    wire   is_csr   = is_sys & (~is_env);

    wire   is_nop   = is_alu & (rs1 == 5'b0) & (rs2 == 5'b0) & (~(|instr[31:20]));

    assign imm = ({32{is_alui | is_jalr | is_load}} & Iimm)
               | ({32{is_lui  | is_auipc}} & Uimm)
               | ({32{is_store}} & Simm)
               | ({32{is_bxx}}   & Bimm)
               | ({32{is_jal}}   & Jimm);

    assign alu_op = (is_load | is_store | is_lui | is_auipc | is_jal | is_jalr) ? 3'b000 : func3;
    // assign alu_op1_reg_pc  = is_bxx  | is_jal  | is_auipc;
    // assign alu_op2_reg_imm = is_alui | is_load | is_store | is_bxx 
    //                        | is_jal  | is_jalr | is_auipc | is_lui;
    assign alu_op1_reg_pc  = is_jal  | is_jalr | is_auipc;
    assign alu_op2_reg_imm = is_alui | is_load | is_store 
                           | is_auipc| is_lui;
    assign reg_write       = is_alu  | is_alui | is_load
                           | is_jal  | is_jalr | is_auipc | is_lui;
    assign alu_arith = (is_alu | is_alui) & instr[30];  // SUB / SRA / SRAI
    assign writeback_alu_mem = is_load;
    assign pc_write_back = is_jal | is_jalr;
    // assign pc_src[0] = is_bxx;
    // assign pc_src[1] = is_jal | is_jalr;

    assign func3 = instr[14:12];
    assign rs1   = is_lui ? 5'b0 : instr[19:15];
    assign rs2   = instr[24:20];
    assign rd    = instr[11:7];

    assign error = ~(is_alu | is_alui | is_load | is_store | is_bxx
                   | is_jal | is_jalr | is_lui  | is_auipc);
    wire error_x_1 = error ? 1'bx : 1'b1;
    wire error_x_0 = error ? 1'bx : 1'b0;

endmodule