
module second_layer(
    clk,
    rst,
    start,
    activation_data,
    logit_data_out,
    done,
    activation_read_address,
    logit_write_address,
    logit_write_en,
    logit_memory_address
);

input clk, rst, start;
input [7:0] activation_data;
input [3:0] logit_memory_address;

output signed [25:0] logit_data_out;
output done;

output [3:0] activation_read_address;
output [3:0] logit_write_address;
output logit_write_en;


// Internal control and address signals
wire [3:0] activation_address;
wire [7:0] weight_address;
wire [3:0] bias_address;
wire load_bias;
wire accumulate_en;
wire [3:0] logit_address;


// Second-layer controller
second_layer_controller slc1(
    .clk(clk),
    .rst(rst),
    .start(start),
    .activation_address(activation_address),
    .weight_address(weight_address),
    .bias_address(bias_address),
    .load_bias(load_bias),
    .accumulate_en(accumulate_en),
    .logit_address(logit_address),
    .logit_write_en(logit_write_en),
    .done(done)
);


// Expose controller-generated addresses
assign activation_read_address = activation_address;
assign logit_write_address = logit_address;


// Second-layer datapath
second_layer_datapath sld1(
    .clk(clk),
    .rst(rst),
    .activation_data(activation_data),
    .weight_address(weight_address),
    .bias_address(bias_address),
    .load_bias(load_bias),
    .accumulate_en(accumulate_en),
    .logit_address(logit_memory_address),
    .logit_write_en(logit_write_en),
    .logit_data_out(logit_data_out)
);

endmodule

