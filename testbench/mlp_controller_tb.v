
module mlp_controller_tb;

reg clk, rst, start;
reg first_layer_done, second_layer_done, argmax_done;

wire first_layer_start;
wire second_layer_start;
wire argmax_start;
wire done;

integer errors;

// DUT
mlp_controller DUT(
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


// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


initial begin

    rst = 0;
    start = 0;

    first_layer_done = 0;
    second_layer_done = 0;
    argmax_done = 0;

    errors = 0;

    // Reset
    repeat(2) @(negedge clk);
    rst = 1;

    @(negedge clk);

    if(done !== 0 ||
       first_layer_start !== 0 ||
       second_layer_start !== 0 ||
       argmax_start !== 0) begin

        $display("FAIL: Incorrect IDLE outputs");
        errors = errors + 1;
    end

    // ----------------------------------
    // START FIRST LAYER
    // ----------------------------------

    start = 1;
    @(negedge clk);
    start = 0;

    if(first_layer_start !== 1) begin
        $display("FAIL: First layer start not asserted");
        errors = errors + 1;
    end

    @(negedge clk);

    if(first_layer_start !== 0) begin
        $display("FAIL: First layer start not one cycle");
        errors = errors + 1;
    end

    // Hold first_layer_done low.
    // Controller must remain in WAIT_FIRST.

    repeat(3) @(negedge clk);

    if(second_layer_start !== 0) begin
        $display("FAIL: Second layer started prematurely");
        errors = errors + 1;
    end

    // Complete first layer
    first_layer_done = 1;
    @(negedge clk);
    first_layer_done = 0;

    // ----------------------------------
    // START SECOND LAYER
    // ----------------------------------

    if(second_layer_start !== 1) begin
        $display("FAIL: Second layer start not asserted");
        errors = errors + 1;
    end

    @(negedge clk);

    if(second_layer_start !== 0) begin
        $display("FAIL: Second layer start not one cycle");
        errors = errors + 1;
    end

    // Hold second_layer_done low

    repeat(3) @(negedge clk);

    if(argmax_start !== 0) begin
        $display("FAIL: Argmax started prematurely");
        errors = errors + 1;
    end

    // Complete second layer
    second_layer_done = 1;
    @(negedge clk);
    second_layer_done = 0;

    // ----------------------------------
    // START ARGMAX
    // ----------------------------------

    if(argmax_start !== 1) begin
        $display("FAIL: Argmax start not asserted");
        errors = errors + 1;
    end

    @(negedge clk);

    if(argmax_start !== 0) begin
        $display("FAIL: Argmax start not one cycle");
        errors = errors + 1;
    end

    // Hold argmax_done low

    repeat(3) @(negedge clk);

    if(done !== 0) begin
        $display("FAIL: Final done asserted prematurely");
        errors = errors + 1;
    end

    // Complete Argmax
    argmax_done = 1;
    @(negedge clk);
    argmax_done = 0;

    // ----------------------------------
    // FINAL DONE
    // ----------------------------------

    if(done !== 1) begin
        $display("FAIL: Final done not asserted");
        errors = errors + 1;
    end

    @(negedge clk);

    if(done !== 0) begin
        $display("FAIL: Done did not return low");
        errors = errors + 1;
    end

    // ----------------------------------
    // RESULTS
    // ----------------------------------

    $display("----------------------------------");

    if(errors == 0)
        $display("MLP CONTROLLER TEST: PASSED");
    else
        $display("MLP CONTROLLER TEST: FAILED");

    $display("Total errors = %0d", errors);
    $display("----------------------------------");

    $finish;

end

endmodule
