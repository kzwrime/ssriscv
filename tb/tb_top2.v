// Code your testbench here
// or browse Examples
`timescale 1ps/1ps
`define CLOCK_TIME_HALF 50
`include "src/ssriscv_cpu_top.v"
`include "tb/defines.vh"

module tb();
	
    reg clk = 1;
    reg rst_n = 1;
    wire error;
    integer counter = -1;
    integer FILE;
    ssriscv_cpu_top SV_CPU_TOP(
        .clk(clk), 
        .rst_n(rst_n), 
        .error(error)
    );

    always @(*) begin
        #`CLOCK_TIME_HALF clk <= ~clk;
        counter <= counter + 1;
        if(counter >= 300) $finish;
    end

    initial begin
        $display("--------------BEGIN TEST---------------");
        #(`CLOCK_TIME_HALF*2.1)
        rst_n <= 1;
        // #((`CLOCK_TIME_HALF)*1.1) rst_n <= 0;
        // #((`CLOCK_TIME_HALF)*1.1) rst_n <= 1;
    end

	reg [31:0] instruction;
	reg [31:0] pc;
	reg [31:0] rd;
	reg [31:0] expectedResult;

	// always #50 clk = !clk;

    initial
    begin
        FILE = $fopen("./tb_top2.md", "a");
        $fwrite(FILE, "\n");
        $fclose(FILE);
        $dumpfile("tb_top2.vcd");  //生成的vcd文件名称
        $dumpvars(0, tb);       //tb模块名称
    end

    initial begin
        test_add;
        test_and;
        test_andi;
        // test_auipc;
        test_beq;
        // test_csr;
        test_jal;
        test_load;
        // test_lui;
        test_slli;
        test_slti;
        test_sltiu;
        test_store;
    end

    integer i = 0;

    always @(negedge clk) begin
        FILE = $fopen("./tb_top2.md", "a");
        $fwrite(FILE, "# pc %x\n", SV_CPU_TOP.pc_now);
        case({SV_CPU_TOP.SV_ID_DECODER.is_alu,      SV_CPU_TOP.SV_ID_DECODER.is_load, 
              SV_CPU_TOP.SV_ID_DECODER.is_store,    SV_CPU_TOP.SV_ID_DECODER.is_bxx, 
              SV_CPU_TOP.SV_ID_DECODER.is_jal,      SV_CPU_TOP.SV_ID_DECODER.is_jalr, 
              SV_CPU_TOP.SV_ID_DECODER.is_alui,     SV_CPU_TOP.SV_ID_DECODER.is_lui,
              SV_CPU_TOP.SV_ID_DECODER.is_auipc})
            9'b100000000:   $fwrite(FILE, "### is_alu\n");
            9'b010000000:   $fwrite(FILE, "### is_load\n");
            9'b001000000:   $fwrite(FILE, "### is_store\n");
            9'b000100000:   $fwrite(FILE, "### is_bxx\n");
            9'b000010000:   $fwrite(FILE, "### is_jal\n");
            9'b000001000:   $fwrite(FILE, "### is_jalr\n");
            9'b000000100:   $fwrite(FILE, "### is_alui\n");
            9'b000000010:   $fwrite(FILE, "### is_lui\n");
            9'b000000001:   $fwrite(FILE, "### is_auipc\n");
        endcase
        $fwrite(FILE, "instr: %b\n",SV_CPU_TOP.instr);
        $fwrite(FILE, "|instr|func7|rs2|rs1|func3|rd|opcode|\n");
        $fwrite(FILE, "|-|-|-|-|-|-|-|\n");
        $fwrite(FILE, "|**%x**|%b|%b(%d)|%b(%d)|%b|%b(%d)|%b|\n", 
                SV_CPU_TOP.instr, SV_CPU_TOP.instr[31:25],  SV_CPU_TOP.rs2,   SV_CPU_TOP.rs2, 
                SV_CPU_TOP.rs1,   SV_CPU_TOP.rs1,           SV_CPU_TOP.func3, SV_CPU_TOP.rd, 
                SV_CPU_TOP.rd,    SV_CPU_TOP.instr[6:0]);
        $fwrite(FILE, "|**alu_in1**|**alu_in2**|**alu_out**|**reg_read_data1**|**reg_read_data2**|**reg_write_data**|**mem_read_data**|\n");
        $fwrite(FILE, "|%x(%d)|%x(%d)|%x(%d)|%x(%d)|%x(%d)|%x(%d)|%x(%d)|\n",  SV_CPU_TOP.alu_in1, SV_CPU_TOP.alu_in1, 
                SV_CPU_TOP.alu_in2,         SV_CPU_TOP.alu_in2,         SV_CPU_TOP.alu_out, SV_CPU_TOP.alu_out,
                SV_CPU_TOP.reg_read_data1,  SV_CPU_TOP.reg_read_data1,  SV_CPU_TOP.reg_read_data2, 
                SV_CPU_TOP.reg_read_data2,  SV_CPU_TOP.reg_write_data,  SV_CPU_TOP.reg_write_data,
                SV_CPU_TOP.mem_read_data,   SV_CPU_TOP.mem_read_data); 
        $fwrite(FILE, "|**alu_op1_reg_pc**|**alu_op2_reg_imm**|**alu_arith**|**reg_write**|**writeback_alu_mem**|**mem_read**|**mem_write**|\n");
        $fwrite(FILE, "|%x|%x|%x|%x|%x|%x|%x|\n",  SV_CPU_TOP.alu_op1_reg_pc,  SV_CPU_TOP.alu_op2_reg_imm, 
                SV_CPU_TOP.alu_arith,       SV_CPU_TOP.reg_write,       SV_CPU_TOP.writeback_alu_mem, 
                SV_CPU_TOP.mem_read,        SV_CPU_TOP.mem_write);
        $fwrite(FILE, "|**imm**|**pc_next**|**test**|||||\n");
        $fwrite(FILE, "|%x(%d)|%b|%b|||||\n", SV_CPU_TOP.imm, SV_CPU_TOP.imm, SV_CPU_TOP.pc_next, SV_CPU_TOP.bxx_test);
        // $fwrite(FILE, "|**branch**|**mem_to_reg**|**mem_write**|**alu_src**|**reg_write**|**alu_op**|**imm_ctrl**|\n");
        // $fwrite(FILE, "|%b|%b|%b|%b|%b|%b|%b|\n", SV_CPU_TOP.branch, SV_CPU_TOP.mem_to_reg, SV_CPU_TOP.mem_write, SV_CPU_TOP.alu_src, SV_CPU_TOP.reg_write, SV_CPU_TOP.alu_op, SV_CPU_TOP.imm_ctrl);
        // $fwrite(FILE, "|**imm**|**dm_read_data**|**alu_result**|**rf_write_data**|**rs2**|**rs1**|**rd**|\n");
        // $fwrite(FILE, "|%d|%x|%x|%x|%d|%d|%d|\n", SV_CPU_TOP.imm, SV_CPU_TOP.dm_read_data, SV_CPU_TOP.alu_result, SV_CPU_TOP.rf_write_data, SV_CPU_TOP.rs1, SV_CPU_TOP.rs2, SV_CPU_TOP.rd);
        $fwrite(FILE, "\n");
        $fwrite(FILE, "|reg_file(i)|x(i)|x(i+1)|x(i+2)|x(i+3)|\n");
        $fwrite(FILE, "|-|-|-|-|-|\n");
        for(i=0; i<32; i=i+4)
            $fwrite(FILE, "|%d|%x|%x|%x|%x|\n", i, SV_CPU_TOP.SV_REGFILE.regs[i], SV_CPU_TOP.SV_REGFILE.regs[i+1], SV_CPU_TOP.SV_REGFILE.regs[i+2], SV_CPU_TOP.SV_REGFILE.regs[i+3]);
        $fwrite(FILE, "|-|-|-|-|-|\n");
        $fwrite(FILE, "|**data_memory(i)**|**+0**|**+4**|**+8**|**+c**|\n");
        for(i=0; i<32; i=i+4)
            $fwrite(FILE, "%h: %h %h %h %h\n", i<<2, SV_CPU_TOP.SV_DATA_MEM.DM[i], SV_CPU_TOP.SV_DATA_MEM.DM[i+1], SV_CPU_TOP.SV_DATA_MEM.DM[i+2], SV_CPU_TOP.SV_DATA_MEM.DM[i+3]);
      // $fwrite(FILE, "<!-- slide -->\n");
      $fwrite(FILE, "\n");
      $fclose(FILE);
    end
    // Old way to test

	// initial begin 

	// 	$dumpfile("vcd/riscV.vcd");
	// 	$dumpvars(0, SV_CPU_TOP);
	// 	// Load memory
	// 	$readmemb("data/programMem_b.mem", SV_CPU_TOP.SV_IFU_IMEM.IM, 0, 3);
	// 	$readmemh("data/dataMem_h.mem", SV_CPU_TOP.mem_data_inst.dataArray, 0, 3);
		
	// 	pc = 32'b0;

	// 	// Initialize registers
	// 	clk = 1'b0;
	// 	rst_n = 1'b0;
	// 	#(`CLOCK_TIME_HALF*2.1)0
		
    //     $readmemh("data/dataMem_h.mem", SV_CPU_TOP.mem_data_inst.dataArray, 0, 3);
    //     //SV_CPU_TOP.mem_data_inst.dataArray[1] = 32'hff04a1c0;
	// 	//test_add;
	// 	//test_lui;
	// 	//test_auipc;
    //     //test_load;
    //     //test_store;
    //     test_jal;
    //     rst_n = 1'b0;
    //     #(`CLOCK_TIME_HALF*2.1)0
    //     test_beq;

	// 	$finish;
	// end


// ARITHMETICOLOGIC

task test_add; 
    begin
        clearIM(3, 31);
        $display ("ADD Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'd5);
        encodeAddi(5'h0, 5'h4, 12'd2);
        encodeAdd(5'h3, 5'h4, 5'h5);

        rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #500; //400
        `ifdef RAM_MUX_CORE
            #(`CLOCK_TIME_HALF*2.1)0
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 7) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be 7 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end
    end
endtask

task test_and;
    begin
        clearIM(3, 31);
        $display ("AND Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFF);
        encodeAddi(5'h0, 5'h4, 12'hFF);
        encodeAnd(5'h3, 5'h4, 5'h5);
        //TEST
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #500; //400
        `ifdef RAM_MUX_CORE
            #(`CLOCK_TIME_HALF*2.1)0
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 32'h000000FF) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be h000000FF but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end
    end
endtask


task test_andi;
    begin
        clearIM(2, 31);
        $display ("ANDI Test");
        pc = 32'b0;
        //encodeLW(5'h0, 5'h3, 12'h1);
        //encodeAndi(5'h3, 5'h4, 12'hFFF);
        encodeAddi(5'h0, 5'h3, 12'h444);
        encodeAndi(5'h3, 5'h5, 12'hF0F);

        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #400; //300
        `ifdef RAM_MUX_CORE
            #(`CLOCK_TIME_HALF*2.1)0
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 32'h0000404) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be h0000404 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end

    end
endtask
 
task test_slli;
    begin
        clearIM(2, 31);
        $display ("SLLI Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'd3);
        encodeSlli(5'h3, 5'h5, 5'h2);
        
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #400; //300
        `ifdef RAM_MUX_CORE
            #(`CLOCK_TIME_HALF*2.1)0
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 32'h000000C) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be h000000C but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end
    end
endtask
 
task test_slti;
    begin
        clearIM(3, 31);
        $display ("SLTI Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFC); //-12
        encodeSlti(5'h3, 5'h5, 12'h8); //1
        encodeSlti(5'h3, 5'h6, 12'hFFF); //-1
        
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #500; //400
        `ifdef RAM_MUX_CORE
            #(`CLOCK_TIME_HALF*2.1)0
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 32'h0000001) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be h0000001 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end
        if (SV_CPU_TOP.SV_REGFILE.regs[6] == 32'h0000001) $display ("    OK: reg6 is : %h", SV_CPU_TOP.SV_REGFILE.regs[6]);
        else begin
            $display ("ERROR: reg6 has to be h0000001 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[6]);
            $fatal;
        end
    end
endtask
 
task test_sltiu;
    begin
        clearIM(3, 31);
        $display ("SLTIU Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFC); // 4092
        encodeSltiu(5'h3, 5'h5, 12'hFFF); // 4095
        encodeSltiu(5'h3, 5'h3, 12'h8);  // 8

        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #500; //400
        `ifdef RAM_MUX_CORE
            #(`CLOCK_TIME_HALF*2.1)0
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 32'h0000001) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be h0000001 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end
        if (SV_CPU_TOP.SV_REGFILE.regs[3] == 32'h0000000) $display ("    OK: reg3 is : %h", SV_CPU_TOP.SV_REGFILE.regs[3]);
        else begin
            $display ("ERROR: reg3 has to be h0000001 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[3]);
            $fatal;
        end
    end
endtask

task test_lui;
	begin
		encodeLui(5'h2, 20'hFFFFF);
		encodeLui(5'h3, 20'hAAAAA);
		encodeLui(5'h4, 20'h55555);
	end
endtask

task test_auipc;
  begin
  encodeAuipc(5'h2, 20'hFFFFF);
  encodeAuipc(5'h3, 20'hAAAAA);
  encodeAuipc(5'h4, 20'h55555);
  end
endtask


// LOAD_STORE
task test_load;
    begin
        $readmemh("data/dataMem_h.mem", SV_CPU_TOP.SV_CPU_TOP.SV_DATA_MEM.DM, 0, 3);
        clearIM(5, 31);
        $display ("LOAD Test");
        pc = 32'b0;
        encodeLB(5'h0, 5'h3, 12'h4);
        encodeLH(5'h0, 5'h4, 12'h4);
        encodeLW(5'h0, 5'h5, 12'h4);
        encodeLHU(5'h0, 5'h6, 12'h4);
        encodeLBU(5'h0, 5'h7, 12'h4);
        //TEST
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #600;  // 600
        `ifdef RAM_MUX_CORE
            #400
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 32'hf04a1c0f) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be hf04a1c0f but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end

    end
endtask

task test_store;
    begin
        $readmemh("data/dataMem_h.mem", SV_CPU_TOP.SV_CPU_TOP.SV_DATA_MEM.DM, 0, 3);
        clearIM(11, 31);
        pc = 32'b0;
        
        $display ("STORE Test");
        encodeLW(5'h0, 5'h1, 12'h0);
        encodeLW(5'h0, 5'h2, 12'h4);
        encodeLW(5'h0, 5'h3, 12'h8);
        encodeLW(5'h0, 5'h4, 12'hC);

        encodeSW(5'h0, 5'h1, 12'h10);
        encodeSH(5'h0, 5'h2, 12'h14);
        encodeSB(5'h0, 5'h3, 12'h18);
        encodeSW(5'h0, 5'h4, 12'h1C);

        encodeLW(5'h0, 5'h5, 12'h10);
        encodeLW(5'h0, 5'h6, 12'h14);
        encodeLW(5'h0, 5'h7, 12'h18);

        //TEST
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #1300; //1200
        `ifdef RAM_MUX_CORE
            #2000
        `endif
        if (SV_CPU_TOP.SV_REGFILE.regs[5] == 32'h10101010) $display ("    OK: reg5 is : %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
        else begin
            $display ("ERROR: reg5 has to be h10101010 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
            $fatal;
        end
        if (SV_CPU_TOP.SV_REGFILE.regs[6] == 32'h00001c0f) $display ("    OK: reg6 is : %h", SV_CPU_TOP.SV_REGFILE.regs[6]);
        else begin
            $display ("ERROR: reg5 has to be h00001c0f but is: %h", SV_CPU_TOP.SV_REGFILE.regs[6]);
            $fatal;
        end
        if (SV_CPU_TOP.SV_REGFILE.regs[7] == 32'h00000011) $display ("    OK: reg7 is : %h", SV_CPU_TOP.SV_REGFILE.regs[7]);
        else begin
            $display ("ERROR: reg5 has to be h00000011 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[7]);
            $fatal;
        end

    end
endtask

task test_jal;  // Not sure if the JAL works as intended
    begin
        clearIM(3, 31);
        $display ("JAL Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFF); 
        encodeAddi(5'h0, 5'h4, 12'hFFF);
        encodeJal(5'h5, {21'h1FFFF8}); // -8
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #400; //400
        `ifdef RAM_MUX_CORE
            #300
        `endif
        if (SV_CPU_TOP.pc_now == 0) $display ("  OK: PC is: %d", SV_CPU_TOP.pc_now);
        else begin
            $display ("ERROR: PC has to be 0 but is: %d", SV_CPU_TOP.pc_now);
            $fatal;
        end
    end
endtask


task test_beq;
    begin
        // clearIM();
        $display ("BEQ Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFF);
        encodeAddi(5'h0, 5'h4, 12'hFFF);
        encodeBeq(5'h3, 5'h4, 13'hF0);
        
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #400; //400
        `ifdef RAM_MUX_CORE
            #300
        `endif
        if (SV_CPU_TOP.pc_now == 248) $display ("    OK: PC is: %d", SV_CPU_TOP.pc_now);
        else begin
            $display ("ERROR: PC has to be 248 but is: %d", SV_CPU_TOP.pc_now);
            $fatal;
        end
    end
endtask


task test_csr;
    begin
        // clearIM();
        $display ("CSR Test");
        pc = 32'b0;
        encodeCsr(12'hC00, 5'h0, `FUNCT3_CSRRS, 5'h1);
        encodeCsr(12'hC01, 5'h0, `FUNCT3_CSRRS, 5'h2);
        encodeCsr(12'hC02, 5'h0, `FUNCT3_CSRRS, 5'h3);
        rst_n = 1'b1;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b0;
        #(`CLOCK_TIME_HALF*2.1) rst_n = 1'b1;
        #400; //400
        `ifdef RAM_MUX_CORE
            #200
            if (SV_CPU_TOP.SV_REGFILE.regs[3] == 32'h0000003) $display ("    OK: reg3 is : %h", SV_CPU_TOP.SV_REGFILE.regs[3]);
            else begin
                $display ("ERROR: reg3 has to be h0000003 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[3]);
                $fatal;
            end
        `else
            if (SV_CPU_TOP.SV_REGFILE.regs[3] == 32'h0000001) $display ("    OK: reg3 is : %h", SV_CPU_TOP.SV_REGFILE.regs[3]);
            else begin
                $display ("ERROR: reg3 has to be h0000001 but is: %h", SV_CPU_TOP.SV_REGFILE.regs[3]);
                $fatal;
            end
        `endif
    end
endtask







task encodeAddi;
	input [4:0] rs1;
	input [4:0] rd;
	input [11:0] immediate;
	begin
		instruction = {immediate, rs1, 3'b000, rd, `OPCODE_I_IMM};
		SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
		pc = pc + 32'd4;
	end
endtask

task encodeAndi;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b111, rd, `OPCODE_I_IMM};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeSlti;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b010, rd, `OPCODE_I_IMM};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeSltiu;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b011, rd, `OPCODE_I_IMM};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeSlli;
    input [4:0] rs1;
    input [4:0] rd;
    input [4:0] immediate;
    begin
        instruction = {7'h0, immediate, rs1, `FUNCT3_SLLI, rd, `OPCODE_I_IMM}; // 3'b001
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeAdd;
	input [4:0] rs1;
	input [4:0] rs2;
	input [4:0] rd;
	begin
	 instruction = {7'b0, rs2, rs1, 3'b000, rd, `OPCODE_R_ALU};
	 SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
	 $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
	 pc = pc + 32'd4;
	end
endtask

task encodeAnd;
    input [4:0] rs1;
    input [4:0] rs2;
    input [4:0] rd;
    begin
        instruction = {7'b0, rs2, rs1, 3'b111, rd, `OPCODE_R_ALU};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
	    $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeSlt;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b010, rd, `OPCODE_R_ALU};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeSltu;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b011, rd, `OPCODE_R_ALU};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeSll;
    input [4:0] rs1;
    input [4:0] rd;
    input [4:0] immediate;
    begin
        instruction = {7'h0, immediate, rs1, 3'b001, rd, `OPCODE_R_ALU};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
		$display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeLui;
	input [4:0] rd;
	input [19:0] immediate;
	begin
	instruction = {immediate[19:0], rd, `OPCODE_U_LUI};
	SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
    $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
	pc = pc + 32'd4;
	end
endtask

task encodeAuipc;
    input [4:0] rd;
    input [19:0] immediate;
    begin
        instruction = {immediate[19:0], rd, `OPCODE_U_AUIPC};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeLB;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LB, rd, `OPCODE_I_LOAD};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
 endtask

task encodeLH;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LH, rd, `OPCODE_I_LOAD};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
 endtask

task encodeLW;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LW, rd, `OPCODE_I_LOAD};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeLBU;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LBU, rd, `OPCODE_I_LOAD};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeLHU;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LHU, rd, `OPCODE_I_LOAD};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeSB;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SB, offset[4:0], `OPCODE_S_STORE};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
 endtask

task encodeSH;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SH, offset[4:0], `OPCODE_S_STORE};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
 endtask

task encodeSW;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SW, offset[4:0], `OPCODE_S_STORE};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeJal;
    input [4:0] rd;
    input [20:0] immediate;
    begin
        instruction = {immediate[20], immediate[10:1], immediate[11], immediate[19:12], rd, `OPCODE_J_JAL};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask


task encodeBeq;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b0, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeBne;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b1, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBlt;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b100, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBge;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b101, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBltu;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b110, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBgeu;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b11, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

task encodeCsr;
    input [11:0] addr;
    input [4:0] rs1;
    input [2:0] FUNCT3_OP;
    input [4:0] rd;
    
    begin
        instruction = {addr, rs1, FUNCT3_OP, rd, `OPCODE_I_SYSTEM};
        SV_CPU_TOP.SV_IFU_IMEM.IM[pc >> 2] = instruction;
        $display("mem[%d] = %x", pc, SV_CPU_TOP.SV_IFU_IMEM.IM[pc>>2]);
        pc = pc + 32'd4;
    end
endtask

integer ii;
task clearIM;
    input [4:0] in1, in2;
    begin
        for(ii = in1; ii<=in2; ii = ii+1) begin
            SV_CPU_TOP.SV_IFU_IMEM.IM[ii] <= 32'bx;
        end
    end
endtask

//always @ (negedge clk) begin
		// $display("reg5 = %d\npc = %d\ninst = %b", SV_CPU_TOP.reg_file_inst.regFile[5], SV_CPU_TOP.addr_progMem, SV_CPU_TOP.instruction_progmem);
		// $display("reg1 = %h", SV_CPU_TOP.SV_REGFILE.regs[1]);
        // $display("reg2 = %h", SV_CPU_TOP.SV_REGFILE.regs[2]);
        //$display("reg3 = %h", SV_CPU_TOP.SV_REGFILE.regs[3]);
        // $display("reg4 = %h", SV_CPU_TOP.SV_REGFILE.regs[4]);
        //$display("reg5 = %h", SV_CPU_TOP.SV_REGFILE.regs[5]);
		// $display("rs2_exec_unit_t = %d", SV_CPU_TOP.rs2_exec_unit_t);
		// $display("ALU_op_t = %d", SV_CPU_TOP.ALU_op_t);
		//$display("is_imm_t = %d", SV_CPU_TOP.is_imm_t);
		// $display("r_num_write_reg_file = %d", SV_CPU_TOP.r_num_write_reg_file);
        //$display("pc = %d", SV_CPU_TOP.core_inst.program_counter_inst.addr);

//end

endmodule   