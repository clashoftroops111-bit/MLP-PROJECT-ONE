module first_layer_datapath(clk,rst,pixel_address,weight_address,bias_address,load_bias,accumulate_en,activation_address,activation_write_en,activation_data_out
);
input clk,rst,accumulate_en,activation_write_en,load_bias;
input[9:0] pixel_address;
input[13:0] weight_address;
input[3:0] bias_address;
input[3:0] activation_address;
output[7:0] activation_data_out;
wire[7:0] pixel_data;
wire signed[7:0] weight_data;
wire signed[31:0] bias_data;
wire signed[25:0] accumulator;
wire[7:0] activation_data;  
input_memory IM1(.inaddr(pixel_address),.clk(clk),.out_data(pixel_data));
weight_memory Wm1(.clk(clk),.input_address(weight_address),.d_out(weight_data));
bias_memory Bm1(.clk(clk),.inn_addr(bias_address),.data_outt(bias_data));
first_mac_unit fmu1(.clk(clk),.rst(rst),.accumulate_en(accumulate_en),.pixel(pixel_data),.weight(weight_data),.accumulator(accumulator),.load_bias(load_bias),.bias(bias_data));
relu_impllementation Rl1(.accumulator(accumulator),.activation(activation_data));
activation_memory Am1(.inaddr(activation_address),.datain(activation_data),.clk(clk),.write_en(activation_write_en),.out_data(activation_data_out));
endmodule



