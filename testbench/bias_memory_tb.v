module testbench_for_bias_memory();
reg clk;
reg[3:0] inaddrr;
wire[31:0] bias_out;
bias_memory b1(clk,inaddrr,bias_out);
initial
begin
    clk=1'b0;
end
initial #300 $finish;
always #10 clk=~clk;
initial
begin
    inaddrr=0;
    #15 inaddrr=12;
    #38 inaddrr=10;
    #98 inaddrr=11;
    #157 inaddrr=8;
end
initial
begin
    $monitor("time=%0b",$time,"input_address=%0t bias=%08h",inaddrr,bias_out);
end
endmodule