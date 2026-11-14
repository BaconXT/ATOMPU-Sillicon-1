// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module atompu_decoder(input wire [7:0] instruction,operand,
 output wire [3:0] op,output wire [1:0] dst,src,output reg legal);
 assign op=instruction[7:4];assign dst=instruction[3:2];assign src=instruction[1:0];
 always @* begin
  legal=1'b1;
  case(instruction[7:4])
   4'h0,4'hf:legal=(instruction[3:0]==0 && operand==0);
   4'h1,4'h9,4'ha:legal=(instruction[1:0]==0);
   4'h2,4'h3,4'h4,4'h5,4'h6,4'h7,4'he:legal=(operand==0);
   4'h8:legal=(instruction[1:0]==0 && operand==0);
   4'hb,4'hc,4'hd:legal=(instruction[3:0]==0);
   default:legal=1'b0;
  endcase
 end
endmodule
`default_nettype wire
