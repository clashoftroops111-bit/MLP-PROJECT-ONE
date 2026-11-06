module weight_memory_layer_two(clk,input_address,d_out);
input clk;
input[7:0] input_address;
output reg signed[7:0] d_out;
reg signed [7:0] mem[0:159];
initial
begin
$readmemh("rtl/mem/W2.mem",mem);
end
always@(posedge clk)
begin
    d_out<=mem[input_address];
end
endmodule