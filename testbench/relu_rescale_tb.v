module testbench_for_relu_rescale_unit();
reg[25:0] accumulator;
reg[31:0] bias_two;
wire[7:0] activation;
relu_impllementation RLU1(accumulator,bias_two,activation);
initial
begin
 #500 $finish;
end
initial
begin
    accumulator=0; bias_two=0;
    #10 accumulator=-100; bias_two=50;
    #10 accumulator=1000; bias_two=-500;
    #10 accumulator=100000; bias_two=0;
    #10 accumulator=35442444;bias_two=4355353;
end
initial
begin
$monitor("Time = %0t ns | Accumulator = %0d | Bias = %0d | Activation = %0d",
         $time, accumulator, bias_two, activation);
end
endmodule
