module logit_memory(inaddr,datain,clk,write_en,out_data);
input[3:0] inaddr;
input clk,write_en;
input signed[25:0] datain;
output reg signed[25:0] out_data;
reg[25:0] mem[0:9];
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