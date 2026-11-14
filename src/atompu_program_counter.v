// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module atompu_program_counter(input wire clk,reset,we,input wire [7:0] value,output reg [7:0] pc);
 always @(posedge clk)begin
  if(reset)pc<=8'd0;else if(we)pc<=value;
 end
endmodule
`default_nettype wire
