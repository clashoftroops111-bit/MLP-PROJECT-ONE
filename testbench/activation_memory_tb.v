
`timescale 1ns/1ps

module testbench_for_activation_memory();

reg clk;
reg write_en;
reg [3:0] inaddrr;
wire [7:0] out_data;
reg [7:0] data_in;

activation_memory a1(inaddrr, data_in, clk, write_en, out_data);

initial
begin
    clk = 1'b0;
end

always #10 clk = ~clk;

initial
begin
    inaddrr = 0;
    write_en = 1;
    data_in = 25;

    
    #20 inaddrr = 12; data_in = 100;
    #20 inaddrr = 10; data_in = 200;
    #20 inaddrr = 11; data_in = 50;
    #20 inaddrr = 8;  data_in = 150;

    
    #20 write_en = 0;

    
    #20 inaddrr = 0;
    #20 inaddrr = 12;
    #20 inaddrr = 10;
    #20 inaddrr = 11;
    #20 inaddrr = 8;

    
    #20 write_en = 1; inaddrr = 10; data_in = 75;

    
    #20 write_en = 0;
    #20 inaddrr = 10;

    #40 $finish;
end

initial
begin
    $monitor("Time=%0t ns | Address=%0d | Write_en=%b | Data_in=%0d | Out_data=%0d",
             $time, inaddrr, write_en, data_in, out_data);
end

endmodule
