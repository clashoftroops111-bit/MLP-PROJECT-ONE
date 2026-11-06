
`timescale 1ns/1ps

module first_layer_controller_tb;

reg clk, rst, start;

wire [3:0] bias_address;
wire load_bias;
wire [9:0] pixel_address;
wire [13:0] weight_address;
wire accumulate_en;
wire activation_write_en;
wire [3:0] activation_address;
wire done;

integer mac_count;
integer activation_count;
integer errors;
integer expected_weight_address;

first_layer_controller DUT (
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

// Clock: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Count and verify controller operations
always @(posedge clk) begin
    if (rst) begin

        if (accumulate_en) begin
            mac_count = mac_count + 1;

            expected_weight_address = mac_count - 1;

            if (weight_address !== expected_weight_address[13:0]) begin
                $display("ERROR: MAC %0d, expected weight address %0d, got %0d",
                         mac_count, expected_weight_address, weight_address);
                errors = errors + 1;
            end

            if (pixel_address !== ((mac_count - 1) % 784)) begin
                $display("ERROR: MAC %0d, incorrect pixel address %0d",
                         mac_count, pixel_address);
                errors = errors + 1;
            end
        end

        if (activation_write_en) begin
            if (activation_address !== activation_count[3:0]) begin
                $display("ERROR: Activation write %0d, incorrect address %0d",
                         activation_count, activation_address);
                errors = errors + 1;
            end

            activation_count = activation_count + 1;
        end

        if (done) begin
            $display("DONE asserted at time %0t", $time);
        end
    end
end

initial begin

    mac_count = 0;
    activation_count = 0;
    errors = 0;

    rst = 0;
    start = 0;

    // Apply reset
    repeat(2) @(negedge clk);
    rst = 1;

    // Start pulse
    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    // Wait for completion
    wait(done == 1);

    // Allow completion state to be observed
    @(negedge clk);

    $display("-----------------------------------");
    $display("MAC operations       = %0d", mac_count);
    $display("Activation writes    = %0d", activation_count);
    $display("Errors               = %0d", errors);
    $display("-----------------------------------");

    if (mac_count == 12544 &&
        activation_count == 16 &&
        errors == 0)
        $display("CONTROLLER TEST PASSED");
    else
        $display("CONTROLLER TEST FAILED");

    $finish;
end

// Timeout protection
initial begin
    #2000000;
    $display("ERROR: Simulation timeout");
    $finish;
end

endmodule
