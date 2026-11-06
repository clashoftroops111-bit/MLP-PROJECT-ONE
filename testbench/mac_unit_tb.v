module testbench_for_mac_unit();
reg clk,rst,accumulate_en;
reg[7:0] pixel;
reg signed[7:0] weight;
wire signed[25:0] accumulator;
first_mac_unit fmu1(clk,rst,accumulate_en,pixel,weight,accumulator);
initial
begin
    clk<=1'b0;
end
initial #300 $finish;
always #10 clk=~clk;
initial
begin
    accumulate_en=1; pixel=4; weight=5;rst=1;
    #12 accumulate_en=0; pixel=5;
    #19 rst=0;
    #21 rst=1; accumulate_en=1;
    #26 weight=-6;
    #40 accumulate_en=1; weight=12;
    #120 pixel=9;
end
initial
begin
    $monitor("time=%0t",$time,"accumulator=%b  accumulate_en=%b  rst=%b pixel=%b weight=%b",accumulator,accumulate_en,rst,pixel,weight);
end
endmodule