// SPDX-License-Identifier: Apache-2.0
// Two phases (address,data), each four-phase REQ/ACK. ACK synchronized through 2 FF.
`default_nettype none
module atompu_bus(input wire clk,reset,start,input wire write,ifetch,
 input wire [7:0] address,wdata,input wire ack,input wire [7:0] external_data,
 output wire busy,output reg done,output reg [7:0] rdata,
 output wire req,phase,write_out,ifetch_out,output wire [7:0] pins);
 localparam IDLE=3'd0,WAIT_INIT=3'd1,ADDR=3'd2,WAIT_ADDR_LOW=3'd3,DATA=3'd4,WAIT_DATA_LOW=3'd5;
 reg [2:0] state;reg ack_meta,ack_sync;reg [7:0] saved_addr,saved_data;reg saved_write,saved_ifetch;
 always @(posedge clk)begin
  if(reset)begin ack_meta<=0;ack_sync<=0;end
  else begin ack_meta<=ack;ack_sync<=ack_meta;end
 end
 assign busy=(state!=IDLE);assign req=(state==ADDR || state==DATA);
 assign phase=(state==DATA || state==WAIT_DATA_LOW);
 assign write_out=saved_write;assign ifetch_out=saved_ifetch;
 assign pins=(phase && saved_write)?saved_data:saved_addr;
 always @(posedge clk)begin
  if(reset)begin state<=IDLE;done<=0;rdata<=0;saved_addr<=0;saved_data<=0;saved_write<=0;saved_ifetch<=0;end
  else begin
   done<=0;
   case(state)
    IDLE:if(start)begin saved_addr<=address;saved_data<=wdata;saved_write<=write;saved_ifetch<=ifetch;state<=WAIT_INIT;end
    WAIT_INIT:if(!ack_sync)state<=ADDR;
    ADDR:if(ack_sync)state<=WAIT_ADDR_LOW;
    WAIT_ADDR_LOW:if(!ack_sync)state<=DATA;
    DATA:if(ack_sync)begin if(!saved_write)rdata<=external_data;state<=WAIT_DATA_LOW;end
    WAIT_DATA_LOW:if(!ack_sync)begin state<=IDLE;done<=1;end
    default:state<=IDLE;
   endcase
  end
 end
endmodule
`default_nettype wire
