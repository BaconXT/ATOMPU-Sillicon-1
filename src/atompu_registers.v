// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module atompu_registers(input wire clk,reset,input wire we,
 input wire [1:0] dst,src,input wire [7:0] value,
 output wire [7:0] a,b,result0);
 reg [7:0] bank[0:3];integer i;
 always @(posedge clk)begin
  if(reset)for(i=0;i<4;i=i+1)bank[i]<=8'd0;
  else if(we)bank[dst]<=value;
 end
 assign a=bank[dst];assign b=bank[src];assign result0=bank[0];
endmodule
`default_nettype wire
