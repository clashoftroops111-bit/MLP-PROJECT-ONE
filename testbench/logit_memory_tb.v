
`timescale 1ns/1ps

module logit_memory_tb;

reg [3:0] inaddr;
reg clk, write_en;
reg signed [25:0] datain;
wire signed [25:0] out_data;

integer errors;

logit_memory DUT (
    .inaddr(inaddr),
    .datain(datain),
    .clk(clk),
    .write_en(write_en),
    .out_data(out_data)
);

// Clock generation: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    errors = 0;

    inaddr = 0;
    datain = 0;
    write_en = 0;

    // Write three values
    @(negedge clk);
    inaddr = 0;
    datain = 26'sd12345;
    write_en = 1;

    @(negedge clk);
    inaddr = 1;
    datain = -26'sd5432;

    @(negedge clk);
    inaddr = 9;
    datain = -26'sd100000;

    // Switch to read mode
    @(negedge clk);
    write_en = 0;

    // Read address 0
    inaddr = 0;
    @(posedge clk);
    #1;
    if (out_data === 26'sd12345)
        $display("Address 0: PASS | Output = %0d", $signed(out_data));
    else begin
        $display("Address 0: FAIL | Output = %0d", $signed(out_data));
        errors = errors + 1;
    end

    // Read address 1
    @(negedge clk);
    inaddr = 1;
    @(posedge clk);
    #1;
    if (out_data === -26'sd5432)
        $display("Address 1: PASS | Output = %0d", $signed(out_data));
    else begin
        $display("Address 1: FAIL | Output = %0d", $signed(out_data));
        errors = errors + 1;
    end

    // Read address 9
    @(negedge clk);
    inaddr = 9;
    @(posedge clk);
    #1;
    if (out_data === -26'sd100000)
        $display("Address 9: PASS | Output = %0d", $signed(out_data));
    else begin
        $display("Address 9: FAIL | Output = %0d", $signed(out_data));
        errors = errors + 1;
    end

    $display("--------------------------------");
    $display("Total errors = %0d", errors);

    if (errors == 0)
        $display("LOGIT MEMORY TEST PASSED");
    else
        $display("LOGIT MEMORY TEST FAILED");

    $finish;
end

endmodule
