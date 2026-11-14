// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module atompu_control(input wire clk,reset,input wire [7:0] pc,
 input wire bus_done,input wire [7:0] bus_rdata,input wire legal,
 input wire [3:0] op,input wire [7:0] a,alu_result,input wire alu_zero,alu_carry,
 output reg [7:0] instruction,operand,
 output wire bus_start,bus_write,bus_ifetch,output wire [7:0] bus_addr,bus_wdata,
 output reg reg_we,pc_we,output reg [7:0] reg_value,pc_value,
 output reg zero,carry,halted,fault,
 output reg retired,output reg [7:0] retired_pc,retired_instruction,retired_operand);
 localparam FETCH0=4'd0,WAIT0=4'd1,FETCH1=4'd2,WAIT1=4'd3,EXEC=4'd4,MEM_START=4'd5,MEM_WAIT=4'd6,STOP=4'd7;
 reg [3:0] state;wire branch=(op==4'hb || (op==4'hc && zero) || (op==4'hd && !zero));
 assign bus_start=(state==FETCH0 || state==FETCH1 || state==MEM_START);
 assign bus_write=(state==MEM_START && op==4'ha);
 assign bus_ifetch=(state==FETCH0 || state==FETCH1);
 assign bus_addr=state==FETCH0?pc:state==FETCH1?(pc+8'd1):operand;
 assign bus_wdata=a;
 // Combinational write enables are sampled by register/PC flops on the retirement edge.
 always @* begin
  reg_we=0;pc_we=0;reg_value=0;pc_value=pc+8'd2;
  if(state==EXEC && legal)begin
   if(op==4'h1)begin reg_we=1;reg_value=operand;end
   else if(op>=4'h2 && op<=4'h8)begin reg_we=1;reg_value=alu_result;end
   if(op!=4'h9 && op!=4'ha && op!=4'hf && !(branch && operand[0]))begin pc_we=1;if(branch)pc_value=operand;end
  end
  if(state==MEM_WAIT && bus_done)begin
   pc_we=1;
   if(op==4'h9)begin reg_we=1;reg_value=bus_rdata;end
  end
 end
 task retire;
 begin retired<=1;retired_pc<=pc;retired_instruction<=instruction;retired_operand<=operand;end
 endtask
 always @(posedge clk)begin
  if(reset)begin state<=FETCH0;instruction<=0;operand<=0;zero<=0;carry<=0;halted<=0;fault<=0;retired<=0;retired_pc<=0;retired_instruction<=0;retired_operand<=0;end
  else begin
   retired<=0;
   case(state)
    FETCH0:state<=WAIT0;
    WAIT0:if(bus_done)begin instruction<=bus_rdata;state<=FETCH1;end
    FETCH1:state<=WAIT1;
    WAIT1:if(bus_done)begin operand<=bus_rdata;state<=EXEC;end
    EXEC:begin
     if(!legal || (branch && operand[0]))begin halted<=1;fault<=1;state<=STOP;end
     else if(op==4'hf)begin halted<=1;state<=STOP;retire();end
     else if(op==4'h9 || op==4'ha)state<=MEM_START;
     else begin
      if(op==4'h1)begin zero<=(operand==0);carry<=0;end
      else if((op>=4'h2 && op<=4'h8) || op==4'he)begin zero<=alu_zero;carry<=alu_carry;end
      retire();state<=FETCH0;
     end
    end
    MEM_START:state<=MEM_WAIT;
    MEM_WAIT:if(bus_done)begin
     if(op==4'h9)begin zero<=(bus_rdata==0);carry<=0;end
     retire();state<=FETCH0;
    end
    STOP:state<=STOP;
    default:begin state<=STOP;halted<=1;fault<=1;end
   endcase
  end
 end
endmodule
`default_nettype wire
