`include "src/ssriscv_defines.v"

module ssriscv_exu_alu (
    input  [31:0] alu_in1,
    input  [31:0] alu_in2,
    output reg [31:0] alu_out,

    input  [2:0]  alu_op,
    input  alu_arith,
    input  is_bxx,
    output zero,
    output reg test
);
    // TODO 让移位操作通过颠倒 alu_in 共用一个移位器
    // TODO 让 bxx 系列复用普通 alu 部分(其实写得一样就可以自动复用元件吧？)
    always @(*) begin
        if(~is_bxx) begin
        case(alu_op)
            3'b000:     alu_out <= (~alu_arith) ? alu_in1 + alu_in2  
                                : alu_in1 - alu_in2;                    // ADD/SUB/ADDI
            3'b010:     alu_out <= {31'b0,                              // SLT/SLTI
                                {~alu_in1[31], alu_in1[30:0]} < {~alu_in2[31], alu_in2[30:0]}};
            3'b011:     alu_out <= {31'b0, alu_in1 < alu_in2};          // SLTU/SLTIU
            3'b100:     alu_out <= alu_in1 ^ alu_in2;                   // XOR/XORI
            3'b110:     alu_out <= alu_in1 | alu_in2;                   // OR/ORI
            3'b111:     alu_out <= alu_in1 & alu_in2;                   // AND/ANDI

            3'b001:     alu_out <= alu_in1 << alu_in2[4:0];             // SLL/SLLI
            3'b101:     if(alu_arith) alu_out <= ($signed(alu_in1) >>> alu_in2[4:0]); else alu_out <= (alu_in1 >> alu_in2[4:0]);
            // 3'b101:     alu_out <= ($signed({(alu_arith & alu_in1[31]), alu_in1[30:0]}) >>> alu_in2[4:0]);  // SRL/SRLI/SRA/SRAI
            default:    begin alu_out <= 32'bx; test <= 1'bx; end
        endcase
        end else begin
            // $display("--------------------bxx %b %x %x", alu_op, alu_in1, alu_in2);
            case(alu_op)
                3'b000: test <= alu_in1 === alu_in2;
                3'b001: test <= ~(alu_in1 === alu_in2);
                3'b100: test <= $signed(alu_in1) < $signed(alu_in2);
                3'b101: test <= $signed(alu_in1) >= $signed(alu_in2);
                3'b110: test <= alu_in1 < alu_in2;
                3'b111: test <= ~(alu_in1 < alu_in2);
                default begin alu_out <= 1'bx; test <= 1'b0; end
            endcase 
        end
    end

    assign zero = (alu_out == 32'b0);

endmodule