module ssriscv_ifu_pc (
    input clk,
    input rst_n,
    input [31:0] pc_rst,
    input [31:0] pc_next,
    output reg [31:0] pc_now   
);
    // reg  [31:0] pc;
    reg isn_rst;

    initial begin
        isn_rst = 1;
    end

    always @(posedge clk) begin
        if(rst_n) begin
            pc_now  = isn_rst ? pc_next : pc_rst;
            isn_rst = 1;
        end
        else begin
            isn_rst <= 0;
            // pc_now  <= pc_rst;
        end
    end
    // 为了仿真兼容长短的复位信号，长复位信号（超过一个时钟）使用上方
    // 短复位脉冲使用下方
    always @(negedge rst_n) begin
        isn_rst <= 0;
        // pc <= pc_rst;
    end

endmodule