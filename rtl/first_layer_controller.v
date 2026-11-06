module first_layer_controller(clk,rst,start,bias_address,load_bias,pixel_address,weight_address,accumulate_en,activation_write_en,activation_address,done);
input clk,rst,start;
output reg[3:0] bias_address;
output reg load_bias,accumulate_en,activation_write_en,done;
output reg[3:0] activation_address;
output reg[9:0] pixel_address;
output reg[13:0] weight_address;
reg[2:0] present_state;
parameter IDLE=3'b000,BIAS_READ=3'b001,BIAS_LOAD=3'b010,MAC_READ=3'b011,MAC_EXECUTE=3'b100,ACTIVATION_WRITE=3'b101,NEXT_NEURON=3'b110;
reg[9:0] pixel_counter;
reg[3:0] neuron_counter;
reg[2:0] next_state;
always@(*)
begin
next_state=present_state;
case (present_state)
IDLE: if(start) next_state=BIAS_READ; else next_state=IDLE;
BIAS_READ: next_state=BIAS_LOAD;
BIAS_LOAD: next_state=MAC_READ;
MAC_READ: next_state=MAC_EXECUTE;
MAC_EXECUTE: if(pixel_counter<783) next_state=MAC_READ; else  next_state=ACTIVATION_WRITE;
ACTIVATION_WRITE: next_state=NEXT_NEURON;
NEXT_NEURON:if(neuron_counter<15) next_state=BIAS_READ; else if(neuron_counter>=15) next_state=IDLE;
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
        pixel_counter<=0;
    end
    else if((present_state==IDLE)&&(start==1))
    begin
        pixel_counter<=0;
    end
    else if((present_state==MAC_EXECUTE)&&(pixel_counter<783))
    begin
        pixel_counter<=pixel_counter+1;
    end
    else if((present_state==NEXT_NEURON)&&(neuron_counter<15))
    begin
        pixel_counter<=0;
    end
    else
    begin
        pixel_counter<=pixel_counter;
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
    else if((present_state==NEXT_NEURON)&&(neuron_counter<15))
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
  pixel_address = 0;
  weight_address = 0;
  accumulate_en = 0;
  activation_write_en = 0;
  activation_address = 0;
  done = 0;
case(present_state)
BIAS_READ:bias_address=neuron_counter;
BIAS_LOAD:
begin
load_bias=1;bias_address=neuron_counter;
end
MAC_READ:
begin
weight_address=784*neuron_counter+pixel_counter; pixel_address=pixel_counter;
end
MAC_EXECUTE:
begin
accumulate_en=1;pixel_address=pixel_counter;weight_address=784*neuron_counter+pixel_counter;
end
ACTIVATION_WRITE:
begin
activation_address = neuron_counter; activation_write_en = 1;
end
NEXT_NEURON: if((present_state==NEXT_NEURON)&&(neuron_counter==15)) done=1; else done=0;
endcase
end
endmodule

