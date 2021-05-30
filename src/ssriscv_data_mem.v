module ssriscv_data_mem(
    input clk,
    input [31:0] mem_addr,
    input [31:0] mem_write_data,
    input [2:0]  func,
    input mem_write,
    input mem_read,
    output reg [31:0] mem_read_data
);
    reg[31:0] DM[0:255];

    integer ii;
    initial begin
        for(ii = 0; ii<256; ii = ii+1)
            DM[ii] <= 0;
    end 
    always @(negedge clk) begin
        if(mem_write) begin
            case(func)
                3'b000: begin
                    case(mem_addr[1:0])
                        2'b00: DM[mem_addr[7:2]][7:0] <= mem_write_data[7:0];
                        2'b01: DM[mem_addr[7:2]][15:8] <= mem_write_data[7:0];
                        2'b10: DM[mem_addr[7:2]][23:16] <= mem_write_data[7:0];
                        2'b11: DM[mem_addr[7:2]][31:24] <= mem_write_data[7:0];
                    endcase
                end
                3'b001: begin 
                    case(mem_addr[1])
                        1'b0: DM[mem_addr[7:2]][15:0] <= mem_write_data[15:0];
                        1'b1: DM[mem_addr[7:2]][31:16] <= mem_write_data[15:0];
                    endcase
                end
                3'b010: begin
                    DM[mem_addr[7:2]] <= mem_write_data;
                end
            endcase 
        end

        if(mem_read) begin
            case(func)
                3'b000:             
                    case(mem_addr[1:0])
                        2'b00:  mem_read_data <= {{24{ DM[mem_addr[7:2]][7]}}, DM[mem_addr[7:2]][7:0]};
                        2'b01:  mem_read_data <= {{24{ DM[mem_addr[7:2]][15]}}, DM[mem_addr[7:2]][15:8]};
                        2'b10:  mem_read_data <= {{24{ DM[mem_addr[7:2]][23]}}, DM[mem_addr[7:2]][23:16]};
                        2'b11:  mem_read_data <= {{24{ DM[mem_addr[7:2]][31]}}, DM[mem_addr[7:2]][31:24]};
                    endcase
                3'b001: 
                    case(mem_addr[1])
                        1'b0:   mem_read_data <= {{16{ DM[mem_addr[7:2]][15]}}, DM[mem_addr[7:2]][15:0]};
                        1'b1:   mem_read_data <= {{16{ DM[mem_addr[7:2]][31]}}, DM[mem_addr[7:2]][31:16]};
                    endcase
                3'b100: 
                    case(mem_addr[1:0])
                        2'b00:  mem_read_data <= DM[mem_addr[7:2]][7:0];
                        2'b01:  mem_read_data <= DM[mem_addr[7:2]][15:8];
                        2'b10:  mem_read_data <= DM[mem_addr[7:2]][23:16];
                        2'b11:  mem_read_data <= DM[mem_addr[7:2]][31:24];
                    endcase
                3'b101:
                    case(mem_addr[1])
                        1'b0:   mem_read_data <= DM[mem_addr[7:2]][15:0];
                        1'b1:   mem_read_data <= DM[mem_addr[7:2]][31:16];
                    endcase
                3'b010: mem_read_data <= DM[mem_addr[7:2]];
                default: mem_read_data <= 32'b0;
            endcase
        end
        else mem_read_data <= 32'b0;
    end

endmodule