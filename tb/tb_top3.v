`timescale 1ps/1ps
`define CLOCK_TIME_HALF 50
`include "src/ssriscv_cpu_top.v"
`define HEXFILE ".verilog"

module tb_top3 ();
    
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
        if(counter >= 150) $finish;
    end

    initial begin
        #10
        $display("--------------BEGIN TEST---------------");
        rst_n <= 1;
        #((`CLOCK_TIME_HALF)*1.1) rst_n <= 0;
        #((`CLOCK_TIME_HALF)*1.1) rst_n <= 1;
    end

    reg[7:0] IM_TMP[1023:0]; // 8 * 1024 == 32 * 256 == 2^13
    initial begin
        clearIM(0, 255);
        clearIM_TMP(0, 1023);
        #100
        $write("HEXFILE = ");
        $display(`HEXFILE);
        // $readmemh(`HEXFILE, IM_TMP);
        // for(ii = 0; ii <= 1023; ii = ii + 4) begin
        //     SV_CPU_TOP.SV_IFU_IMEM.IM[ii>>2][7:0] = IM_TMP[ii];
        //     SV_CPU_TOP.SV_IFU_IMEM.IM[ii>>2][15:8] = IM_TMP[ii+1];
        //     SV_CPU_TOP.SV_IFU_IMEM.IM[ii>>2][23:16] = IM_TMP[ii+2];
        //     SV_CPU_TOP.SV_IFU_IMEM.IM[ii>>2][31:24] = IM_TMP[ii+3];
        // end
        
        $readmemh(`HEXFILE, SV_CPU_TOP.SV_IFU_IMEM.IM);

        $display("pc = 0x0 : %x", SV_CPU_TOP.SV_IFU_IMEM.IM[0]);
        $display("pc = 0x4 : %x", SV_CPU_TOP.SV_IFU_IMEM.IM[1]);
    end

    integer i;
    always @(negedge clk) begin
        #1
        FILE = $fopen("./tb/tb_top3.md", "a");
        $fwrite(FILE, "# pc %x\n", SV_CPU_TOP.pc_now);
        if(SV_CPU_TOP.pc_now == SV_CPU_TOP.pc_rst) $display();
        $write("pc %x,\t instr %x\t\t\n", SV_CPU_TOP.pc_now, SV_CPU_TOP.instr);
        $write("reg(9) = %x %x \t\tmem(1) = %x\t\t", SV_CPU_TOP.SV_REGFILE.regs[9], SV_CPU_TOP.SV_REGFILE.regs[10], SV_CPU_TOP.SV_DATA_MEM.DM[1]);
        // $write("reg(27) = %x %x \t\tmem(4) = %x\n", SV_CPU_TOP.SV_REGFILE.regs[27], SV_CPU_TOP.SV_REGFILE.regs[28], SV_CPU_TOP.SV_DATA_MEM.DM[1]);
        case({SV_CPU_TOP.SV_ID_DECODER.is_alu,      SV_CPU_TOP.SV_ID_DECODER.is_load, 
              SV_CPU_TOP.SV_ID_DECODER.is_store,    SV_CPU_TOP.SV_ID_DECODER.is_bxx, 
              SV_CPU_TOP.SV_ID_DECODER.is_jal,      SV_CPU_TOP.SV_ID_DECODER.is_jalr, 
              SV_CPU_TOP.SV_ID_DECODER.is_alui,     SV_CPU_TOP.SV_ID_DECODER.is_lui,
              SV_CPU_TOP.SV_ID_DECODER.is_auipc})
            9'b100000000: begin 
                $fwrite(FILE, "### is_alu x%d, x%d, x%d\n", SV_CPU_TOP.rd, SV_CPU_TOP.rs1, SV_CPU_TOP.rs2);
                $display("### is_alu \tx%d, x%d, x%d\t\t\t x%d <= 0x%h", 
                        SV_CPU_TOP.rd, SV_CPU_TOP.rs1, SV_CPU_TOP.rs2, SV_CPU_TOP.rd, SV_CPU_TOP.reg_write_data);
                end
            9'b010000000: begin 
                $fwrite(FILE, "### is_load x%d, 0x%x(x%d)\n", SV_CPU_TOP.rd, SV_CPU_TOP.imm, SV_CPU_TOP.rs1);
                $display("### is_load \tx%d, 0x%x(x%d) \t0x%x", SV_CPU_TOP.rd, SV_CPU_TOP.imm, SV_CPU_TOP.rs1, SV_CPU_TOP.reg_write_data);
                end
            9'b001000000: begin 
                $fwrite(FILE, "### is_store x%d 0x%x(x%d)\n", SV_CPU_TOP.rs2, SV_CPU_TOP.imm, SV_CPU_TOP.rs1);
                $display("### is_store \tx%d 0x%x(x%d) \t0x%x", SV_CPU_TOP.rs2, SV_CPU_TOP.imm, SV_CPU_TOP.rs1, SV_CPU_TOP.reg_read_data2);
                
                end
            9'b000100000: begin 
                $fwrite(FILE, "### is_bxx\n");
                $display("### is_bxx \tt=%d,\t  0x%x", SV_CPU_TOP.bxx_test, SV_CPU_TOP.pc_next);
                end
            9'b000010000: begin 
                $fwrite(FILE, "### is_jal\n");
                $display("### is_jal \t\t  0x%h", SV_CPU_TOP.pc_next);
                end
            9'b000001000: begin 
                $fwrite(FILE, "### is_jalr\n");
                $display("### is_jalr");
                end
            9'b000000100: begin 
                if({SV_CPU_TOP.rd, SV_CPU_TOP.rs1, SV_CPU_TOP.rs2} == 15'b00000_00000_00000) begin
                    $fwrite(FILE, "### nop\n");
                    $display("### nop");
                end
                else begin
                    $fwrite(FILE, "### is_alui x%d, x%d, 0x%x\n", SV_CPU_TOP.rd, SV_CPU_TOP.rs1, SV_CPU_TOP.imm);
                    $display("### is_alui \tx%d, x%d, 0x%x\t\t x%d <= 0x%h", 
                            SV_CPU_TOP.rd, SV_CPU_TOP.rs1, SV_CPU_TOP.imm, SV_CPU_TOP.rd, SV_CPU_TOP.reg_write_data);
                end
                end
            9'b000000010: begin 
                $fwrite(FILE, "### is_lui x%d, 0x%x\n", SV_CPU_TOP.rd, SV_CPU_TOP.imm);
                $display("### is_lui \tx%d, \t  0x%x\t\t x%d <= 0x%h", SV_CPU_TOP.rd, 
                        SV_CPU_TOP.imm, SV_CPU_TOP.rd, SV_CPU_TOP.reg_write_data);
                end
            9'b000000001: begin 
                $fwrite(FILE, "### is_auipc\n");
                $display("### is_auipc \t\t\t\t\t x%d <= 0x%x", SV_CPU_TOP.rd, SV_CPU_TOP.reg_write_data);
                end
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

    initial
    begin
        FILE = $fopen("./tb/tb_top3.md", "a");
        $fwrite(FILE, "\n");
        $fclose(FILE);
        $dumpfile("./tb/tb_top3.vcd");  //生成的vcd文件名称
        $dumpvars(0, tb_top3);       //tb模块名称
    end

    integer ii;
    task clearIM;
        input [4:0] in1, in2;
        begin
            for(ii = in1; ii<=in2; ii = ii+1) begin
                SV_CPU_TOP.SV_IFU_IMEM.IM[ii] <= 32'bx;
            end
        end
    endtask

    task clearIM_TMP;
        input [4:0] in1, in2;
        begin
            for(ii = in1; ii<=in2; ii = ii+1) begin
                IM_TMP[ii] <= 8'bx;
            end
        end
    endtask

endmodule