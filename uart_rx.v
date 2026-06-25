module uart_rx(
    input clk,
    input reset,
    input rx,

    output [7:0] data_out,
    output reg busy,
    output reg done
);
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] current, next;

wire baud_done;
wire bit_done;
wire [7:0] rx_data;
reg shift;

baud_counter bc(
    .clk(clk),
    .reset(reset),
    .enable(current != IDLE),
    .baud_done(baud_done)
);

bit_counter btc(
    .clk(clk),
    .reset(reset),
    .baud_done(baud_done),
    .enable(current == DATA),
    .bit_done(bit_done)
);

shift_register sr(
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .shift(shift),
    .data_out(rx_data)
);

always @(posedge clk or posedge reset) begin
    if(reset)
        current <= IDLE;
    else
        current <= next;
end
always @(*) begin
    next = current;
    shift = 1'b0;
    case(current)
        IDLE: begin
            if(!rx)
                next = START;
        end

        START: begin
            if(baud_done)
                next = DATA;
        end

        DATA: begin
            if(baud_done) begin
                if(!bit_done)
                    shift = 1'b1;
                else
                    next = STOP;
            end
        end

        STOP: begin
            if(baud_done) begin
                next = IDLE;
            end
        end
        default: begin
            next = IDLE;
        end
    endcase
end

always @(*) begin

    busy = 1'b0;
    done = 1'b0;

    case(current)

        IDLE: begin
            busy = 1'b0;
            done = 1'b0;
        end

        START: begin
            busy =1'b1;
            done = 1'b0;
        end 

        DATA: begin
            busy=1'b1;
            done=1'b0;
        end 

        STOP:begin
            busy = 1'b1;
            done = baud_done;
        end
    endcase
end
assign data_out = rx_data;
endmodule


module baud_counter(
    input clk,
    input reset,
    input enable,
    output reg baud_done
);
parameter BAUD_COUNT=8;
reg [8:0] baud;
always @(posedge clk or posedge reset) begin
    if(reset) begin
        baud <= 0;
        baud_done<=0;
    end 
    else begin
        if(enable) begin
            if (baud == BAUD_COUNT -1) begin
                baud <= 0;
                baud_done<=1;
            end
            else begin
                baud<=baud+1'b1;
                baud_done<=0;
            end 
        end
        else begin
            baud<=0;
            baud_done<=1'b0;
        end
    end 
end 

endmodule



module bit_counter(
    input clk,
    input reset,
    input baud_done,
    input enable,
    output bit_done
);
reg [2:0] bit_count;
parameter BIT_SIZE = 4'd8;
assign bit_done = (bit_count == BIT_SIZE-1) && baud_done && enable;
always @(posedge clk or posedge reset) begin  
    if(reset) begin
        bit_count<= 1'b0; 
    end
    else begin
        if(baud_done && enable) begin
            if(bit_count == BIT_SIZE-1'b1) begin
                bit_count <=1'b0;
            end
            else
                bit_count<= bit_count + 1'b1;
        end
        else begin
            if(!enable) begin
                bit_count<=0;
            end
        end
    end
end
endmodule


module shift_register(
    input clk,
    input reset,
    input rx,
    input shift,
    output  [7:0] data_out
);
reg [7:0] shift_reg;
assign data_out = shift_reg;

    always @(posedge clk or posedge reset) begin
    if(reset)
        shift_reg <= 8'b0;
    else if(shift)
        shift_reg <= {rx, shift_reg[7:1]};

end
endmodule