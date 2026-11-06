module relu_impllementation(accumulator,activation);
input signed[25:0] accumulator;
output reg[7:0] activation;
reg signed[32:0] accumulator_extended;
reg signed[32:0] relu_output;
reg signed[45:0] intermediate_relu;
reg signed[45:0] rounded_intermediate_relu;
always@(*)
begin
    accumulator_extended={{7{accumulator[25]}},accumulator};
end
always@(*)
begin
    if(accumulator_extended<=0)
    begin
        relu_output=0;
    end
    else
    begin
        relu_output=accumulator_extended;
    end
end
always@(*)
begin
    intermediate_relu=relu_output*(46'sd7116);
    rounded_intermediate_relu=(intermediate_relu+46'sd8388608)>>>24;
    if(rounded_intermediate_relu>255)
    begin
        activation=255;
    end
    else 
    activation=rounded_intermediate_relu[7:0];
end
endmodule

