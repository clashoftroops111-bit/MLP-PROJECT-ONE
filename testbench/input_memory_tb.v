
`timescale 1ns/1ps

module input_memory_tb();

reg clk;
reg [9:0] inaddr;
wire [7:0] out_data;

reg [7:0] expected_mem [0:783];

input_memory dut(inaddr, clk, out_data);

initial begin
    clk = 0;
    inaddr = 0;

    $readmemh("rtl/mem/input.mem", expected_mem);
end

always #10 clk = ~clk;

task check_address;
    input [9:0] address;
    begin
        @(negedge clk);
        inaddr = address;

        @(posedge clk);
        #1;

        if (out_data !== expected_mem[address]) begin
            $display("FAIL: Address=%0d Expected=%0d Actual=%0d",
                     address, expected_mem[address], out_data);
            $stop;
        end
        else begin
            $display("PASS: Address=%0d Data=%0d",
                     address, out_data);
        end
    end
endtask

initial begin
    #1;

    check_address(0);
    check_address(1);
    check_address(27);
    check_address(28);
    check_address(100);
    check_address(783);

    $display("Input memory test completed successfully.");
    $finish;
end

endmodule
