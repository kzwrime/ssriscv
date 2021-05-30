module ssriscv_npc (
    input test,
    input is_jal,
    input is_jalr,
    input is_bxx,
    input [31:0] pc_now,
    input [31:0] imm,
    input [31:0] reg_read_data1,
    output [31:0] pc_next
);
    // jalr  : rs1  +  imm
    // jal   : pc   +  imm
    // bxx(T): pc   +  imm
    // bxx(F): pc   +  4
    // normal: pc   +  4

    wire [31:0] pc_op1, pc_op2;
    assign pc_op1 = is_jalr ? reg_read_data1 : pc_now;
    assign pc_op2 = ((is_bxx & test) | is_jal | is_jalr) ? imm : 4;
    assign pc_next = pc_op1 + pc_op2;

endmodule