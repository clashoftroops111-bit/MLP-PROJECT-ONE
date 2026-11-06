module second_layer_datapath(clk,rst,activation_data,weight_address,bias_address,load_bias,accumulate_en,logit_address,logit_write_en,logit_data_out);
input clk,rst,load_bias,accumulate_en,logit_write_en;
input[7:0] activation_data;
input[7:0] weight_address;
input[3:0] bias_address;
input[3:0] logit_address;
output wire signed[25:0] logit_data_out;
wire signed[7:0] weight_data;
wire signed[31:0] bias_data;
wire signed[25:0] accumulator;
weight_memory_layer_two wml2(.clk(clk),.input_address(weight_address),.d_out(weight_data));
bias_memory_layer2 bml2(.clk(clk),.inn_addr(bias_address),.data_outt(bias_data));
first_mac_unit fmlu2(.clk(clk),.rst(rst),.accumulate_en(accumulate_en),.pixel(activation_data),.weight(weight_data),.accumulator(accumulator),.load_bias(load_bias),.bias(bias_data));
logit_memory lm1(.inaddr(logit_address),.datain(accumulator),.clk(clk),.write_en(logit_write_en),.out_data(logit_data_out));
endmodule