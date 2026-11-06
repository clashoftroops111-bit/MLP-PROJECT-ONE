
`timescale 1ns/1ps

module second_layer_controller_tb;

reg clk, rst, start;

wire [3:0] activation_address;
wire [7:0] weight_address;
wire [3:0] bias_address;
wire load_bias, accumulate_en;
wire [3:0] logit_address;
wire logit_write_en, done;

integer mac_count;
integer logit_count;
integer errors;
integer expected_weight;
integer expected_activation;
integer expected_neuron;
integer timeout_count;

reg [3:0] previous_activation;
reg [3:0] previous_neuron;

second_layer_controller DUT (
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

// Clock generation: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    mac_count = 0;
    logit_count = 0;
    errors = 0;
    timeout_count = 0;

    rst = 0;
    start = 0;

    repeat(2) @(negedge clk);
    rst = 1;

    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    $display("Second layer controller test started...");

    // Monitor controller outputs
    while(done !== 1'b1 && timeout_count < 2000) begin
        @(negedge clk);
        timeout_count = timeout_count + 1;

        if(accumulate_en) begin
            expected_weight = 16 * DUT.neuron_counter +
                              DUT.activation_counter;

            if(weight_address !== expected_weight[7:0]) begin
                $display("ERROR: Incorrect weight address. Expected %0d, Got %0d",
                         expected_weight, weight_address);
                errors = errors + 1;
            end

            if(activation_address !== DUT.activation_counter) begin
                $display("ERROR: Incorrect activation address");
                errors = errors + 1;
            end

            mac_count = mac_count + 1;
        end

        if(logit_write_en) begin
            if(logit_address !== DUT.neuron_counter) begin
                $display("ERROR: Incorrect logit address");
                errors = errors + 1;
            end

            logit_count = logit_count + 1;
        end

        if(load_bias && accumulate_en) begin
            $display("ERROR: load_bias and accumulate_en asserted together");
            errors = errors + 1;
        end
    end

    if(timeout_count >= 2000) begin
        $display("ERROR: Controller timeout");
        errors = errors + 1;
    end

    // Final checks
    if(mac_count != 160) begin
        $display("ERROR: Expected 160 MAC operations, Got %0d", mac_count);
        errors = errors + 1;
    end

    if(logit_count != 10) begin
        $display("ERROR: Expected 10 logit writes, Got %0d", logit_count);
        errors = errors + 1;
    end

    if(done !== 1'b1) begin
        $display("ERROR: Done was not asserted");
        errors = errors + 1;
    end

    $display("-----------------------------------------");
    $display("MAC operations  = %0d", mac_count);
    $display("Logit writes    = %0d", logit_count);
    $display("Errors          = %0d", errors);
    $display("-----------------------------------------");

    if(errors == 0)
        $display("SECOND LAYER CONTROLLER TEST PASSED");
    else
        $display("SECOND LAYER CONTROLLER TEST FAILED");

    $finish;
end

endmodule
