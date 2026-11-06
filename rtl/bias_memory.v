module bias_memory(clk,inn_addr,data_outt);
input clk;
input[3:0] inn_addr;
output reg signed[31:0] data_outt;
reg signed[31:0] memr[0:15];
initial
begin
    $readmemh("rtl/mem/b1.mem",memr);
end
always@(posedge clk)
begin
    data_outt<=memr[inn_addr];
end
endmodule