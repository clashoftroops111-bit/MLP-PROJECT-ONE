
module mlp_top_tb;

reg clk, rst, start;

wire [3:0] predicted_digit;
wire done;

integer i;
integer cycles;
integer errors;

reg [7:0] expected_hidden [0:15];
reg signed [25:0] expected_logits [0:9];


// ==========================================
// DUT
// ==========================================

mlp_top DUT(
    .clk(clk),
    .rst(rst),
    .start(start),
    .predicted_digit(predicted_digit),
    .done(done)
);


// ==========================================
// CLOCK
// ==========================================

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


// ==========================================
// TEST
// ==========================================

initial begin

    rst = 0;
    start = 0;
    errors = 0;
    cycles = 0;

    // Load Python reference outputs
    $readmemh("rtl/mem/expected_hidden.mem", expected_hidden);
    $readmemh("rtl/mem/expected_logits.mem", expected_logits);

    // Reset
    repeat(2) @(negedge clk);
    rst = 1;

    // Start complete MLP
    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    // Wait for final classification
    while(done !== 1'b1 && cycles < 50000) begin
        @(negedge clk);
        cycles = cycles + 1;
    end

    // ======================================
    // TIMEOUT CHECK
    // ======================================

    if(done !== 1'b1) begin

        $display("ERROR: MLP TIMEOUT");
        errors = errors + 1;

    end

    else begin

        $display("----------------------------------");
        $display("COMPLETE MLP SIMULATION RESULTS");
        $display("----------------------------------");

        $display("Clock cycles = %0d", cycles);

        // ==================================
        // CHECK HIDDEN ACTIVATIONS
        // ==================================

        $display("");
        $display("CHECKING FIRST LAYER ACTIVATIONS");

        for(i=0; i<16; i=i+1) begin

            if(DUT.FL1.fld1.Am1.mem[i] !== expected_hidden[i]) begin

                $display("FAIL: Hidden neuron %0d | RTL=%0d | Expected=%0d",
                    i,
                    DUT.FL1.fld1.Am1.mem[i],
                    expected_hidden[i]);

                errors = errors + 1;

            end

        end

        // ==================================
        // CHECK OUTPUT LOGITS
        // ==================================

        $display("");
        $display("CHECKING SECOND LAYER LOGITS");

        for(i=0; i<10; i=i+1) begin

            if($signed(DUT.SL1.sld1.lm1.mem[i]) !== expected_logits[i]) begin

                $display("FAIL: Logit %0d | RTL=%0d | Expected=%0d",
                    i,
                    $signed(DUT.SL1.sld1.lm1.mem[i]),
                    expected_logits[i]);

                errors = errors + 1;

            end

            else begin

                $display("PASS: Logit %0d = %0d",
                    i,
                    $signed(DUT.SL1.sld1.lm1.mem[i]));

            end

        end

        // ==================================
        // CHECK FINAL PREDICTION
        // ==================================

        $display("");
        $display("CHECKING FINAL CLASSIFICATION");

        $display("Predicted digit = %0d", predicted_digit);
        $display("Expected digit  = 7");

        if(predicted_digit !== 4'd7) begin

            $display("FAIL: Incorrect classification");
            errors = errors + 1;

        end

        else begin

            $display("PASS: Correct classification");

        end

    end

    // ======================================
    // FINAL RESULTS
    // ======================================

    $display("");
    $display("----------------------------------");

    if(errors == 0)
        $display("COMPLETE MLP TEST: PASSED");
    else
        $display("COMPLETE MLP TEST: FAILED");

    $display("Total errors = %0d", errors);

    $display("----------------------------------");

    $finish;

end

endmodule
