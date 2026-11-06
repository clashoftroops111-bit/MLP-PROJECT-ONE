module testbench_for_weight_memory();
reg[13:0] inaddr;
wire[7:0] d_out;
reg clk;
weight_memory wm1(clk,inaddr,d_out);
initial
begin
    clk=1'b0;
end
initial #300 $finish;
always #10 clk=~clk;
initial
begin
    inaddr=2;
    #13 inaddr=13;
    #14 inaddr=16;
    #56 inaddr=98;
    #126 inaddr=11000;
end
initial
begin
    $monitor("time=%0t",$time,"input_address=%0d d_out=%02h",inaddr,d_out);
end
endmodule