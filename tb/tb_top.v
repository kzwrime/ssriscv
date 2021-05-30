`timescale 1ps/1ps
`define CLOCK_TIME_HALF 50
`include "src/ssriscv_cpu_top.v"

module tb_top ();
    
    reg clk = 1;
    reg rst_n = 1;
    wire error;
    integer counter = -1;
    ssriscv_cpu_top SV_CPU_TOP(
        .clk(clk), 
        .rst_n(rst_n), 
        .error(error)
    );

    always @(*) begin
        #`CLOCK_TIME_HALF clk <= ~clk;
        counter <= counter + 1;
        if(counter >= 40) $finish;
    end

    initial begin
        #10
        $display("--------------BEGIN TEST---------------");
        rst_n <= 1;
        #((`CLOCK_TIME_HALF)*1.1) rst_n <= 0;
        #((`CLOCK_TIME_HALF)*1.1) rst_n <= 1;
    end

    initial begin
        $readmemh("./test_instr.dat", SV_CPU_TOP.SV_IFU_IMEM.IM);
        $display("pc = 0 : %x", SV_CPU_TOP.SV_IFU_IMEM.IM[0]);
    end

    integer i = 0;
    always @(negedge clk) begin
        $display("# pc %x", SV_CPU_TOP.pc_now);
        case({SV_CPU_TOP.SV_ID_DECODER.is_alu,      SV_CPU_TOP.SV_ID_DECODER.is_load, 
              SV_CPU_TOP.SV_ID_DECODER.is_store,    SV_CPU_TOP.SV_ID_DECODER.is_bxx, 
              SV_CPU_TOP.SV_ID_DECODER.is_jal,      SV_CPU_TOP.SV_ID_DECODER.is_jalr, 
              SV_CPU_TOP.SV_ID_DECODER.is_alui,     SV_CPU_TOP.SV_ID_DECODER.is_lui,
              SV_CPU_TOP.SV_ID_DECODER.is_auipc})
            9'b100000000:   $display("### is_alu");
            9'b010000000:   $display("### is_load");
            9'b001000000:   $display("### is_store");
            9'b000100000:   $display("### is_bxx");
            9'b000010000:   $display("### is_jal");
            9'b000001000:   $display("### is_jalr");
            9'b000000100:   $display("### is_alui");
            9'b000000010:   $display("### is_lui");
            9'b000000001:   $display("### is_auipc");
        endcase
        $display("instr: %b",SV_CPU_TOP.instr);
        $display("|instr|func7|rs2|rs1|func3|rd|opcode|");
        $display("|-|-|-|-|-|-|-|");
        $display("|**%x**|%b|%b(%d)|%b(%d)|%b|%b(%d)|%b|", 
                SV_CPU_TOP.instr, SV_CPU_TOP.instr[31:25],  SV_CPU_TOP.rs2,   SV_CPU_TOP.rs2, 
                SV_CPU_TOP.rs1,   SV_CPU_TOP.rs1,           SV_CPU_TOP.func3, SV_CPU_TOP.rd, 
                SV_CPU_TOP.rd,    SV_CPU_TOP.instr[6:0]);
        $display("|**alu_in1**|**alu_in2**|**alu_out**|**reg_read_data1**|**reg_read_data2**|**reg_write_data**|**mem_read_data**|");
        $display("|%x(%d)|%x(%d)|%x(%d)|%x(%d)|%x(%d)|%x(%d)|%x(%d)|",  SV_CPU_TOP.alu_in1, SV_CPU_TOP.alu_in1, 
                SV_CPU_TOP.alu_in2,         SV_CPU_TOP.alu_in2,         SV_CPU_TOP.alu_out, SV_CPU_TOP.alu_out,
                SV_CPU_TOP.reg_read_data1,  SV_CPU_TOP.reg_read_data1,  SV_CPU_TOP.reg_read_data2, 
                SV_CPU_TOP.reg_read_data2,  SV_CPU_TOP.reg_write_data,  SV_CPU_TOP.reg_write_data,
                SV_CPU_TOP.mem_read_data,   SV_CPU_TOP.mem_read_data); 
        $display("|**alu_op1_reg_pc**|**alu_op2_reg_imm**|**alu_arith**|**reg_write**|**writeback_alu_mem**|**mem_read**|**mem_write**|");
        $display("|%x|%x|%x|%x|%x|%x|%x|",  SV_CPU_TOP.alu_op1_reg_pc,  SV_CPU_TOP.alu_op2_reg_imm, 
                SV_CPU_TOP.alu_arith,       SV_CPU_TOP.reg_write,       SV_CPU_TOP.writeback_alu_mem, 
                SV_CPU_TOP.mem_read,        SV_CPU_TOP.mem_write);
        $display("|**imm**|**pc_src**|**test**|**pc_in**||||");
        $display("|%x(%d)|%b|%b|%x||||", SV_CPU_TOP.imm, SV_CPU_TOP.imm, SV_CPU_TOP.pc_src, SV_CPU_TOP.bxx_test, SV_CPU_TOP.pc_in);
        // $display("|**branch**|**mem_to_reg**|**mem_write**|**alu_src**|**reg_write**|**alu_op**|**imm_ctrl**|");
        // $display("|%b|%b|%b|%b|%b|%b|%b|", SV_CPU_TOP.branch, SV_CPU_TOP.mem_to_reg, SV_CPU_TOP.mem_write, SV_CPU_TOP.alu_src, SV_CPU_TOP.reg_write, SV_CPU_TOP.alu_op, SV_CPU_TOP.imm_ctrl);
        // $display("|**imm**|**dm_read_data**|**alu_result**|**rf_write_data**|**rs2**|**rs1**|**rd**|");
        // $display("|%d|%x|%x|%x|%d|%d|%d|", SV_CPU_TOP.imm, SV_CPU_TOP.dm_read_data, SV_CPU_TOP.alu_result, SV_CPU_TOP.rf_write_data, SV_CPU_TOP.rs1, SV_CPU_TOP.rs2, SV_CPU_TOP.rd);
        $display();
        $display("|reg_file(i)|x(i)|x(i+1)|x(i+2)|x(i+3)|");
        $display("|-|-|-|-|-|");
        for(i=0; i<32; i=i+4)
            $display("|%d|%x|%x|%x|%x|", i, SV_CPU_TOP.SV_REGFILE.regs[i], SV_CPU_TOP.SV_REGFILE.regs[i+1], SV_CPU_TOP.SV_REGFILE.regs[i+2], SV_CPU_TOP.SV_REGFILE.regs[i+3]);
        $display("|-|-|-|-|-|");
        $display("|**data_memory(i)**|**+0**|**+4**|**+8**|**+c**|");
        for(i=0; i<32; i=i+4)
            $display("%h: %h %h %h %h", i, SV_CPU_TOP.SV_DATA_MEM.DM[i], SV_CPU_TOP.SV_DATA_MEM.DM[i+1], SV_CPU_TOP.SV_DATA_MEM.DM[i+2], SV_CPU_TOP.SV_DATA_MEM.DM[i+3]);
      // $display("<!-- slide -->");
      $display();
    end

    initial
    begin            
        $dumpfile("tb_top.vcd");  //生成的vcd文件名称
        $dumpvars(0, tb_top);       //tb模块名称
    end

endmodule