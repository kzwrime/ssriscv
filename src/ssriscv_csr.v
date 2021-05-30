module ssriscv_csr (
    input clk,
    input rst_n,
    input  [4:0]  csr_op,
    input  [11:0] csr_addr,
    input  [31:0] csr_data_in,
    output [31:0] csr_data_out
);
    
    always @(posedge clk) begin
        if()
    end

endmodule