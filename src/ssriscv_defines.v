`ifndef __SSRISCV_DEFINES__
`define __SSRISCV_DEFINES__

`define INSTR_ALU       7'b0110011
`define INSTR_ALUI      7'b0010011
`define INSTR_LOAD      7'b0000011
`define INSTR_STORE     7'b0100011
`define INSTR_BXX       7'b1100011
`define INSTR_JAL       7'b1101111
`define INSTR_JALR      7'b1100111
`define INSTR_LUI       7'b0110111
`define INSTR_AUIPC     7'b0010111
`define INSTR_FENCE     7'b0001111
`define INSTR_SYSTEM    7'b1110011
// `define INSTR_E         7'b1110011


`define CSRRW   3'b001
`define CSRRS   3'b010
`define CSRRC   3'b001
`define CSRRWI  3'b101
`define CSRRSI  3'b110
`define CSRRCI  3'b111

`define CSR_MSTATUS     12'h300     // 机器模式状态寄存器       (machine status register)
`define CSR_MISA        12'h301     // 机器模式指令集架构寄存器 (machine ISA register)
`define CSR_MEDELEG     12'h302     // Machine exception delegation register
`define CSR_MIE         12'h304     // 机器模式中断使能寄存器   (machine interrupt enable register)
`define CSR_MTVEC       12'h305     // 机器模式异常入口基地址寄存器 (machine trap-vector base-address register)
`define CSR_MSCRATCH    12'h340     // 机器模式擦写寄存器       (machine srcatch register)
`define CSR_MEPC        12'h341     // 机器模式异常pc寄存器     (machine exception program counter)
`define CSR_MCAUSE      12'h342     // 机器模式异常原因寄存器   (machine cause register)
`define CSR_MBADADDR    12'h343     // 机器模式异常值寄存器     (machine trap value register)
`define CSR_MTVAL       12'h343     // 机器模式异常值寄存器     (machine trap value register) 同上
`define CSR_MLP         12'h344     // 机器模式中断等待寄存器   (machine interrupt pending register)
`define CSR_MCYCLE      12'hb00     // 周期计数器的低32位       (lower 32bits of cycle counter)
`define CSR_MCYCLEH     12'hb80     // 周期计数器的高32位       (upper 32bits of cycle counter)
`define CSR_MHARTID     12'hf14     // hart编号寄存器(hart ID register)，readonly，hart的编号。多hart系统中，起码有一个hart编号为0

`define CSR_CYCLE       12'hC00     // Cycle counter for RDCYCLE instruction, USER

`define CSR_MISA_INIT   32'b0100_0000_0000_0000_0000_0001_0000_0000     // 32位，支持 BASE ISA


`endif