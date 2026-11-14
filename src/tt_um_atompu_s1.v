// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module tt_um_atompu_s1 (
 input wire [7:0] ui_in,output wire [7:0] uo_out,
 input wire [7:0] uio_in,output wire [7:0] uio_out,output wire [7:0] uio_oe,
 input wire ena,clk,rst_n
);
 wire reset=!rst_n || !ena;
 wire [7:0] pins,result0;wire req,phase,write,ifetch,halted,fault,zero,carry;
 wire retired;wire[7:0] retired_pc,retired_instruction,retired_operand;
 atompu_s1_top core(clk,reset,ui_in,uio_in[7],pins,req,phase,write,ifetch,halted,fault,zero,carry,result0,retired,retired_pc,retired_instruction,retired_operand);
 assign uo_out=!ena?8'd0:req?pins:result0;
 assign uio_out=!ena?8'd0:{1'b0,(halted?fault:carry),zero,halted,phase,ifetch,write,req};
 assign uio_oe=8'h7f;
 wire unused=&{uio_in[6:0],retired,retired_pc,retired_instruction,retired_operand,1'b0};
endmodule
`default_nettype wire
