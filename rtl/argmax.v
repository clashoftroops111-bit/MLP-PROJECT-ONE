
module argmax(
    clk,
    rst,
    start,
    logit_data,
    logit_address,
    predicted_digit,
    done
);

input clk, rst, start;
input signed [25:0] logit_data;

output reg [3:0] logit_address;
output reg [3:0] predicted_digit;
output reg done;

reg [1:0] present_state, next_state;

reg [3:0] counter;
reg signed [25:0] max_logit;

parameter IDLE    = 2'b00,
          READ    = 2'b01,
          COMPARE = 2'b10,
          FINISH  = 2'b11;


// Next-state logic
always @(*) begin

    next_state = present_state;

    case (present_state)

        IDLE:
            if (start)
                next_state = READ;

        READ:
            next_state = COMPARE;

        COMPARE:
            if (counter < 9)
                next_state = READ;
            else
                next_state = FINISH;

        FINISH:
            next_state = IDLE;

        default:
            next_state = IDLE;

    endcase

end


// State register
always @(posedge clk) begin

    if (!rst)
        present_state <= IDLE;
    else
        present_state <= next_state;

end


// Counter
always @(posedge clk) begin

    if (!rst)
        counter <= 0;

    else if ((present_state == IDLE) && start)
        counter <= 0;

    else if ((present_state == COMPARE) && (counter < 9))
        counter <= counter + 1;

end


// Maximum and predicted digit registers
always @(posedge clk) begin

    if (!rst) begin
        max_logit <= 0;
        predicted_digit <= 0;
    end

    else if ((present_state == IDLE) && start) begin
        max_logit <= 0;
        predicted_digit <= 0;
    end

    else if (present_state == COMPARE) begin

        if ((counter == 0) || ($signed(logit_data) > max_logit)) begin
            max_logit <= logit_data;
            predicted_digit <= counter;
        end

    end

end


// Output logic
always @(*) begin

    logit_address = 0;
    done = 0;

    case (present_state)

        READ:
            logit_address = counter;

        COMPARE:
            logit_address = counter;

        FINISH:
            done = 1;

    endcase

end

endmodule
