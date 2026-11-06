module weight_memory(clk,input_address,d_out);
input clk;
input[13:0] input_address;
output reg[7:0] d_out;
reg signed [7:0] mem[0:12543];
initial
begin
$readmemh("rtl/mem/W1.mem",mem);
end
always@(posedge clk)
begin
    d_out<=mem[input_address];
end
endmodule