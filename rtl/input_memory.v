module input_memory(inaddr,clk,out_data);
input[9:0] inaddr;
input clk;
output reg[7:0] out_data;
reg[7:0] mem[0:783];
initial
begin
    $readmemh("rtl/mem/input.mem",mem);
end
always@(posedge clk)
begin
    
        out_data<=mem[inaddr];
   
end
endmodule