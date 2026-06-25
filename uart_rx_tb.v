`timescale 1ns/1ns

module uart_rx_tb;

reg clk;
reg reset;
reg rx;

wire [7:0] data_out;
wire busy;
wire done;

uart_rx uut(
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .data_out(data_out),
    .busy(busy),
    .done(done)
);

// Clock generation (10 ns period)
always #5 clk = ~clk;

// Task to send one UART bit
task send_bit;
    input bit_value;
    integer i;
    begin
        rx = bit_value;
        for(i = 0; i < 8; i = i + 1)
            @(posedge clk);
    end
endtask
initial begin

    clk = 0;
    reset = 1;
    rx = 1;

    #20;
    reset = 0;

    repeat(5) @(posedge clk);

    // Send byte 10110010
    send_bit(0);     // Start

    send_bit(0);     // D0
    send_bit(1);     // D1
    send_bit(0);     // D2
    send_bit(0);     // D3
    send_bit(1);     // D4
    send_bit(1);     // D5
    send_bit(0);     // D6
    send_bit(1);     // D7

    send_bit(1);     // Stop

    repeat(10) @(posedge clk);

    $display("----------------------------");
    $display("Received Data = %b", data_out);

    if(data_out == 8'b10110010)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    $finish;

end

initial begin
    $dumpfile("uart_rx.vcd");
    $dumpvars(0, uart_rx_tb);
end

endmodule