module first_mac_unit(clk,rst,accumulate_en,pixel,weight,accumulator,load_bias,bias);
input clk,rst,accumulate_en,load_bias;
input[7:0] pixel;
input signed[7:0] weight;
output reg signed[25:0] accumulator; 
reg signed[8:0] pixel_signed;
reg signed[8:0] weight_signed;
reg signed[17:0] temp_reg;
input signed[31:0] bias;
always@(*)
begin
    pixel_signed={1'b0,pixel};
    weight_signed={weight[7],weight};
end
always@(posedge clk)
begin
    if(!rst) accumulator<=0;
    else if(load_bias)
    begin
        accumulator<=bias[25:0];
    end
    else 
    begin
        if(accumulate_en)
        begin
            accumulator<=accumulator+{{8{temp_reg[17]}},temp_reg};
        end
        else
        begin
            accumulator<=accumulator;
        end
    end
end
always@(*)
begin
    temp_reg=pixel_signed*weight_signed;
end
endmodule