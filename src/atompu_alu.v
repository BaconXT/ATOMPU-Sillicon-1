// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module atompu_alu(input wire [3:0] op,input wire [7:0] a,b,
 output reg [7:0] result,output wire zero,output reg carry);
 reg [8:0] wide;
 always @* begin
  result=8'd0;carry=1'b0;wide=9'd0;
  case(op)
   4'h2:result=b;
   4'h3:begin wide={1'b0,a}+{1'b0,b};result=wide[7:0];carry=wide[8];end
   4'h4,4'he:begin result=a-b;carry=(a>=b);end
   4'h5:result=a&b;
   4'h6:result=a|b;
   4'h7:result=a^b;
   4'h8:result=~a;
   default:result=8'd0;
  endcase
 end
 assign zero=(result==8'd0);
endmodule
`default_nettype wire
