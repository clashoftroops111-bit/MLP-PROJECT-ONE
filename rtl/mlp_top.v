
module mlp_top(
    clk,
    rst,
    start,
    predicted_digit,
    done
);

input clk, rst, start;

output [3:0] predicted_digit;
output done;


// ==========================================
// TOP-LEVEL CONTROLLER SIGNALS
// ==========================================

wire first_layer_start;
wire second_layer_start;
wire argmax_start;

wire first_layer_done;
wire second_layer_done;
wire argmax_done;


// ==========================================
// ACTIVATION MEMORY INTERFACE
// ==========================================

// First-layer write interface
wire [3:0] activation_write_address;
wire activation_write_en;

// Second-layer read interface
wire [3:0] activation_read_address;

// Shared activation memory interface
wire [3:0] activation_memory_address;
wire [7:0] activation_data;


// ==========================================
// LOGIT MEMORY INTERFACE
// ==========================================

// Second-layer write interface
wire [3:0] logit_write_address;
wire logit_write_en;

// Argmax read interface
wire [3:0] logit_read_address;

// Shared logit memory interface
wire [3:0] logit_memory_address;
wire signed [25:0] logit_data;


// ==========================================
// ADDRESS MULTIPLEXERS
// ==========================================

// Select activation memory address
assign activation_memory_address =
    activation_write_en ?
    activation_write_address :
    activation_read_address;


// Select logit memory address
assign logit_memory_address =
    logit_write_en ?
    logit_write_address :
    logit_read_address;


// ==========================================
// TOP-LEVEL FSM
// ==========================================

mlp_controller MC1(
    .clk(clk),
    .rst(rst),
    .start(start),

    .first_layer_done(first_layer_done),
    .second_layer_done(second_layer_done),
    .argmax_done(argmax_done),

    .first_layer_start(first_layer_start),
    .second_layer_start(second_layer_start),
    .argmax_start(argmax_start),

    .done(done)
);


// ==========================================
// FIRST LAYER
// ==========================================

first_layer FL1(
    .clk(clk),
    .rst(rst),
    .start(first_layer_start),
    .done(first_layer_done),

    .activation_write_address(activation_write_address),
    .activation_write_en(activation_write_en),
    .activation_data_out(activation_data),

    .activation_memory_address(activation_memory_address)
);


// ==========================================
// SECOND LAYER
// ==========================================

second_layer SL1(
    .clk(clk),
    .rst(rst),
    .start(second_layer_start),

    .activation_data(activation_data),
    .logit_data_out(logit_data),

    .done(second_layer_done),

    .activation_read_address(activation_read_address),
    .logit_write_address(logit_write_address),
    .logit_write_en(logit_write_en),

    .logit_memory_address(logit_memory_address)
);


// ==========================================
// ARGMAX
// ==========================================

argmax AM1(
    .clk(clk),
    .rst(rst),
    .start(argmax_start),

    .logit_data(logit_data),
    .logit_address(logit_read_address),

    .predicted_digit(predicted_digit),
    .done(argmax_done)
);


endmodule
