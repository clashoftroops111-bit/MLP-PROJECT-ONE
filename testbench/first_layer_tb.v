
`timescale 1ns/1ps

module first_layer_tb;

reg clk, rst, start;
wire done;

reg [7:0] expected [0:15];

integer i;
integer errors;

first_layer DUT (
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done)
);

// Clock generation: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Load Python reference activations
initial begin
    $readmemh("rtl/mem/expected_hidden.mem", expected);
end

// Main test
initial begin

    errors = 0;

    rst = 0;
    start = 0;

    // Apply reset
    repeat(2) @(negedge clk);
    rst = 1;

    // Give start a one-cycle pulse
    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    $display("First layer computation started...");

    // Wait until all 16 neurons are calculated
    wait(done == 1);

    // Allow signals to settle
    #1;

    $display("\nFIRST LAYER ACTIVATION COMPARISON");
    $display("---------------------------------------------");
    $display("Neuron | RTL Output | Expected | Result");
    $display("---------------------------------------------");

    for(i = 0; i < 16; i = i + 1) begin

        if (DUT.fld1.Am1.mem[i] === expected[i]) begin

            $display("  %2d   |     %3d    |   %3d    | PASS",
                i,
                DUT.fld1.Am1.mem[i],
                expected[i]);

        end
        else begin

            $display("  %2d   |     %3d    |   %3d    | FAIL",
                i,
                DUT.fld1.Am1.mem[i],
                expected[i]);

            errors = errors + 1;
        end

    end

    $display("---------------------------------------------");
    $display("Total neurons checked = 16");
    $display("Errors = %0d", errors);

    if(errors == 0)
        $display("\nFIRST LAYER TEST PASSED");
    else
        $display("\nFIRST LAYER TEST FAILED");

    $finish;
end

// Timeout protection
initial begin
    #2000000;
    $display("ERROR: Simulation timeout");
    $finish;
end

endmodule
