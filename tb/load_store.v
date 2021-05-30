// Code your testbench here
// or browse Examples
`timescale 1ps/1ps

`include"tb/tb_top2.v"

module load_store_test();

	tb TB();
	
	initial begin 

		// // $dumpfile("vcd/riscV.vcd");
		// // $dumpvars(0, TB.top_inst);
		// TB.pc = 32'b0;
		// // Initialize registers
		// TB.clk = 1'b0;
		// TB.rst_n = 1'b0;
		// #100
		// // Load memory
		$readmemh("data/dataMem_h.mem", TB.SV_CPU_TOP.SV_CPU_TOP.SV_DATA_MEM.DM, 0, 3);
		

		//test_lui;
		//test_auipc;
		//test_load;
		//test_store;
		TB.test_load;
		TB.rst_n = 1'b0;
		#100
		//Load data from memory
		$readmemh("data/dataMem_h.mem", TB.SV_CPU_TOP.SV_CPU_TOP.SV_DATA_MEM.DM, 0, 3);
		TB.test_store;

	$finish;
end

endmodule   