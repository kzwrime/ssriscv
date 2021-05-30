module ssriscv_regfile (
    input  clk,
    input  rst_n,
    input  reg_write,
    input  [4:0] rs1, rs2, rd,
    input  [31:0] reg_write_data,
    output [31:0] reg_read_data1,
    output [31:0] reg_read_data2
);

    integer ii;
    reg [31:0] regs[31:0];
    always @(posedge clk) begin
        if(reg_write & (|rd)) regs[rd] <= reg_write_data;
    end

    assign reg_read_data1 = (rs1 != 5'b0) ? regs[rs1] : 32'b0;
    assign reg_read_data2 = (rs2 != 5'b0) ? regs[rs2] : 32'b0;

    always @(negedge rst_n) begin
        for(ii = 0; ii < 32; ii = ii + 1)
            regs[ii] <= 0;
    end

endmodule