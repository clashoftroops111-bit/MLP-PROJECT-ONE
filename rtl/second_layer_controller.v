module second_layer_controller(clk,rst,start,activation_address,weight_address,bias_address,load_bias,accumulate_en,logit_address,logit_write_en,done);
input clk,rst,start;
output reg load_bias,accumulate_en,logit_write_en,done;
output reg[3:0] activation_address;
output reg[7:0] weight_address;
output reg[3:0] bias_address;
output reg[3:0] logit_address;
reg[2:0] present_state;
reg[2:0] next_state;
reg [3:0] activation_counter;
reg [3:0] neuron_counter;
parameter IDLE=3'b000,BIAS_READ=3'b001,BIAS_LOAD=3'b010,MAC_READ=3'b011,MAC_EXECUTE=3'b100,LOGIT_WRITE=3'b101,NEXT_NEURON=3'b110;
always@(*)
begin
next_state=present_state;
case (present_state)
IDLE: if(start) next_state=BIAS_READ; else next_state=IDLE;
BIAS_READ: next_state=BIAS_LOAD;
BIAS_LOAD: next_state=MAC_READ;
MAC_READ: next_state=MAC_EXECUTE;
MAC_EXECUTE: if(activation_counter<15) next_state=MAC_READ; else  next_state=LOGIT_WRITE;
LOGIT_WRITE: next_state=NEXT_NEURON;
NEXT_NEURON:if(neuron_counter<9) next_state=BIAS_READ; else if(neuron_counter>=9) next_state=IDLE;
default:next_state=IDLE;
endcase
end
always@(posedge clk)
begin
    if(!rst)
    begin
        present_state<=IDLE;
    end
    else
    begin
        present_state<=next_state;
    end
end

always@(posedge clk)
begin
    if(!rst)
    begin
        activation_counter<=0;
    end
    else if((present_state==IDLE)&&(start==1))
    begin
        activation_counter<=0;
    end
    else if((present_state==MAC_EXECUTE)&&(activation_counter<15))
    begin
        activation_counter<=activation_counter+1;
    end
    else if((present_state==NEXT_NEURON)&&(neuron_counter<9))
    begin
        activation_counter<=0;
    end
    else
    begin
        activation_counter<=activation_counter;
    end
end

always@(posedge clk)
begin
    if(!rst)
    begin
        neuron_counter<=0;
    end
    else if((present_state==IDLE)&&(start==1))
    begin
        neuron_counter<=0;
    end
    else if((present_state==NEXT_NEURON)&&(neuron_counter<9))
    begin
        neuron_counter<=neuron_counter+1;
    end
    else
    begin
        neuron_counter<=neuron_counter;
    end
end

always@(*)
begin
  bias_address = 0;
  load_bias = 0;
  activation_address = 0;
  weight_address = 0;
  accumulate_en = 0;
  logit_write_en = 0;
  logit_address = 0;
  done = 0;
case(present_state)
BIAS_READ:bias_address=neuron_counter;
BIAS_LOAD:
begin
load_bias=1;bias_address=neuron_counter;
end
MAC_READ:
begin
weight_address=16*neuron_counter+activation_counter; activation_address=activation_counter;
end
MAC_EXECUTE:
begin
accumulate_en=1;activation_address=activation_counter;weight_address=16*neuron_counter+activation_counter;
end
LOGIT_WRITE:
begin
logit_address = neuron_counter; logit_write_en = 1;
end
NEXT_NEURON: if((present_state==NEXT_NEURON)&&(neuron_counter==9)) done=1; else done=0;
endcase
end
endmodule