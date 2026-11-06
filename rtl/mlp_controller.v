
module mlp_controller(
    clk,
    rst,
    start,
    first_layer_done,
    second_layer_done,
    argmax_done,
    first_layer_start,
    second_layer_start,
    argmax_start,
    done
);

input clk, rst, start;
input first_layer_done, second_layer_done, argmax_done;

output reg first_layer_start;
output reg second_layer_start;
output reg argmax_start;
output reg done;

reg [2:0] present_state, next_state;

parameter IDLE          = 3'b000,
          START_FIRST   = 3'b001,
          WAIT_FIRST    = 3'b010,
          START_SECOND  = 3'b011,
          WAIT_SECOND   = 3'b100,
          START_ARGMAX  = 3'b101,
          WAIT_ARGMAX   = 3'b110,
          FINISH        = 3'b111;


// State transition logic
always @(*) begin

    next_state = present_state;

    case(present_state)

        IDLE: begin
            if(start)
                next_state = START_FIRST;
        end

        START_FIRST: begin
            next_state = WAIT_FIRST;
        end

        WAIT_FIRST: begin
            if(first_layer_done)
                next_state = START_SECOND;
        end

        START_SECOND: begin
            next_state = WAIT_SECOND;
        end

        WAIT_SECOND: begin
            if(second_layer_done)
                next_state = START_ARGMAX;
        end

        START_ARGMAX: begin
            next_state = WAIT_ARGMAX;
        end

        WAIT_ARGMAX: begin
            if(argmax_done)
                next_state = FINISH;
        end

        FINISH: begin
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end

    endcase

end


// State register
always @(posedge clk) begin

    if(!rst)
        present_state <= IDLE;

    else
        present_state <= next_state;

end


// Output logic
always @(*) begin

    first_layer_start = 0;
    second_layer_start = 0;
    argmax_start = 0;
    done = 0;

    case(present_state)

        START_FIRST: begin
            first_layer_start = 1;
        end

        START_SECOND: begin
            second_layer_start = 1;
        end

        START_ARGMAX: begin
            argmax_start = 1;
        end

        FINISH: begin
            done = 1;
        end

        default: begin
            first_layer_start = 0;
            second_layer_start = 0;
            argmax_start = 0;
            done = 0;
        end

    endcase

end

endmodule
