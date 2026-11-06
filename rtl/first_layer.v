
module first_layer(
    clk,
    rst,
    start,
    done,
    activation_write_address,
    activation_write_en,
    activation_data_out,
    activation_memory_address
);

input clk, rst, start;
input [3:0] activation_memory_address;

output done;
output [3:0] activation_write_address;
output activation_write_en;
output [7:0] activation_data_out;

wire [3:0] bias_address;
wire load_bias, accumulate_en;
wire [3:0] activation_address;
wire [9:0] pixel_address;
wire [13:0] weight_address;


// Controller
first_layer_controller flc1(
    .clk(clk),
    .rst(rst),
    .start(start),
    .bias_address(bias_address),
    .load_bias(load_bias),
    .pixel_address(pixel_address),
    .weight_address(weight_address),
    .accumulate_en(accumulate_en),
    .activation_write_en(activation_write_en),
    .activation_address(activation_address),
    .done(done)
);


// Expose the write address
assign activation_write_address = activation_address;


// Datapath
first_layer_datapath fld1(
    .clk(clk),
    .rst(rst),
    .pixel_address(pixel_address),
    .weight_address(weight_address),
    .bias_address(bias_address),
    .load_bias(load_bias),
    .accumulate_en(accumulate_en),
    .activation_address(activation_memory_address),
    .activation_write_en(activation_write_en),
    .activation_data_out(activation_data_out)
);

endmodule

