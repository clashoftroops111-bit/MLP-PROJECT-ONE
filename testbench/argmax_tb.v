
`timescale 1ns/1ps

module argmax_tb;

reg clk;
reg rst;
reg start;
reg signed [25:0] datain;
reg [3:0] write_address;
reg write_en;

wire [3:0] logit_address;
wire signed [25:0] logit_data;
wire [3:0] predicted_digit;
wire done;

wire [3:0] memory_address;

integer errors;
integer i;

reg signed [25:0] test_logits [0:9];

assign memory_address = write_en ? write_address : logit_address;


// Logit memory
logit_memory LM(
    .inaddr(memory_address),
    .datain(datain),
    .clk(clk),
    .write_en(write_en),
    .out_data(logit_data)
);


// Argmax module
argmax DUT(
    .clk(clk),
    .rst(rst),
    .start(start),
    .logit_data(logit_data),
    .logit_address(logit_address),
    .predicted_digit(predicted_digit),
    .done(done)
);


always #5 clk = ~clk;


// Write test values into logit memory
initial begin

    clk = 0;
    rst = 0;
    start = 0;
    datain = 0;
    write_address = 0;
    write_en = 0;
    errors = 0;

    test_logits[0] = -10;
    test_logits[1] = -20;
    test_logits[2] = -30;
    test_logits[3] = -40;
    test_logits[4] = -50;
    test_logits[5] = -60;
    test_logits[6] = -70;
    test_logits[7] = -80;
    test_logits[8] = -90;
    test_logits[9] = 100;

    #20;
    rst = 1;

    @(negedge clk);
    write_en = 1;

    for (i = 0; i < 10; i = i + 1) begin
        write_address = i;
        datain = test_logits[i];
        @(negedge clk);
    end

    write_en = 0;

    // Start Argmax
    start = 1;
    @(negedge clk);
    start = 0;

    // Wait for completion
    i = 0;
    while (done !== 1'b1 && i < 100) begin
        @(negedge clk);
        i = i + 1;
    end

    if (done !== 1'b1) begin
        $display("ERROR: ARGMAX TIMEOUT");
        $finish;
    end

    #1;

    $display("----------------------------------");
    $display("ARGMAX TEST RESULTS");
    $display("----------------------------------");

    $display("Predicted digit = %0d", predicted_digit);

    if (predicted_digit == 9)
        $display("ARGMAX TEST: PASSED");
    else begin
        $display("ARGMAX TEST: FAILED");
        errors = errors + 1;
    end

    $display("----------------------------------");

    $finish;

end

endmodule

