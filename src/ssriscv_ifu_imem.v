module ssriscv_ifu_imem (
  input  [31:0] addr,
  output [31:0] instr
);
  reg [31:0]  IM[0:255];
  assign instr = IM[addr[9:2]];
endmodule