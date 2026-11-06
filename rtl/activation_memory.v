module activation_memory(inaddr,datain,clk,write_en,out_data);
input[3:0] inaddr;
input clk,write_en;
input[7:0] datain;
output reg[7:0] out_data;
reg[7:0] mem[0:15];
always@(posedge clk)
begin
    if(write_en)
    begin
        mem[inaddr]<=datain;
    end
    else
    begin
        out_data<=mem[inaddr];
    end
end
endmodule