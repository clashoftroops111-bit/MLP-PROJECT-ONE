module testbench_for_setup();
wire y_out;
reg a1,b1;
parameter finish_time=100;
setup_test s1 (.a(a1),.b(b1),.y(y_out));
initial #finish_time $finish;
initial
begin
    a1=0;b1=0;
    #10 a1=0;b1=0;
    #10 a1=1;b1=0;
    #10 a1=0;b1=1;
    #10 a1=1;b1=1;
end
initial
begin
    $monitor("time=",$time,"a1=%b b1=%b y_out=%b",a1,b1,y_out);
end
endmodule