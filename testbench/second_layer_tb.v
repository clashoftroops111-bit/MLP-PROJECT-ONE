
`timescale 1ns/1ps

module second_layer_tb;

reg clk;
reg rst;
reg start;
reg [7:0] activation_data;

wire signed [25:0] logit_data_out;
wire done;

reg [7:0] hidden_mem [0:15];
reg signed [25:0] expected_logits [0:9];

integer i;
integer cycles;
integer errors;


// DUT
second_layer DUT(
    .clk(clk),
    .rst(rst),
    .start(start),
    .activation_data(activation_data),
    .logit_data_out(logit_data_out),
    .done(done)
);


// Clock generation: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


// Load reference data
initial begin
    $readmemh("rtl/mem/expected_hidden.mem", hidden_mem);
    $readmemh("rtl/mem/expected_logits.mem", expected_logits);
end


// Emulate synchronous activation memory read
always @(posedge clk) begin
    if (rst)
        activation_data <= hidden_mem[DUT.slc1.activation_address];
end


// Main test
initial begin

    rst = 0;
    start = 0;
    activation_data = 0;
    cycles = 0;
    errors = 0;

    // Reset
    #20;
    rst = 1;

    // Start second-layer computation
    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    // Wait for completion, with timeout
    while (done !== 1'b1 && cycles < 5000) begin
        @(negedge clk);
        cycles = cycles + 1;
    end

    #1;

    if (done !== 1'b1) begin
        $display("ERROR: TIMEOUT - second layer did not finish.");
        $finish;
    end

    $display("");
    $display("========================================");
    $display("       SECOND LAYER LOGIT RESULTS");
    $display("========================================");

    // Compare all 10 logits
    for (i = 0; i < 10; i = i + 1) begin

        if (DUT.sld1.lm1.mem[i] !== expected_logits[i]) begin
            $display(
                "FAIL: Logit %0d | RTL = %0d | Expected = %0d",
                i,
                $signed(DUT.sld1.lm1.mem[i]),
                $signed(expected_logits[i])
            );
            errors = errors + 1;
        end
        else begin
            $display(
                "PASS: Logit %0d | Value = %0d",
                i,
                $signed(DUT.sld1.lm1.mem[i])
            );
        end

    end

    $display("----------------------------------------");

    if (errors == 0)
        $display("SECOND LAYER TEST: PASSED");
    else
        $display("SECOND LAYER TEST: FAILED (%0d errors)", errors);

    $display("Clock cycles waited: %0d", cycles);
    $display("========================================");

    $finish;

end

endmodule
