// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module atompu_s1_top(input wire clk,reset,input wire [7:0] read_data,input wire ack,
 output wire [7:0] bus_pins,output wire req,phase,write,ifetch,halted,fault,zero,carry,
 output wire [7:0] result0,
 output wire retired,output wire [7:0] retired_pc,retired_instruction,retired_operand);
 wire [7:0] pc,next_pc,instruction,operand,a,b,alu_result,reg_value;
 wire [3:0] op;wire [1:0] dst,src;wire legal,alu_zero,alu_carry,reg_we,pc_we;
 wire bus_start,bus_done,bus_busy,bus_write,bus_ifetch;wire [7:0] bus_addr,bus_wdata,bus_rdata;
 atompu_program_counter pc_unit(clk,reset,pc_we,next_pc,pc);
 atompu_decoder decoder(instruction,operand,op,dst,src,legal);
 atompu_registers registers(clk,reset,reg_we,dst,src,reg_value,a,b,result0);
 atompu_alu alu(op,a,b,alu_result,alu_zero,alu_carry);
 atompu_control control(clk,reset,pc,bus_done,bus_rdata,legal,op,a,alu_result,alu_zero,alu_carry,instruction,operand,bus_start,bus_write,bus_ifetch,bus_addr,bus_wdata,reg_we,pc_we,reg_value,next_pc,zero,carry,halted,fault,retired,retired_pc,retired_instruction,retired_operand);
 atompu_bus bus(clk,reset,bus_start,bus_write,bus_ifetch,bus_addr,bus_wdata,ack,read_data,bus_busy,bus_done,bus_rdata,req,phase,write,ifetch,bus_pins);
 wire unused=bus_busy;
endmodule
`default_nettype wire
