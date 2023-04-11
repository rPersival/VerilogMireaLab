`timescale 1ns / 1ps

module ClockDivider #(rate = 1) (input clock, output reg outClock = 0);

wire[($clog2(rate) - 1):0] out;

always@ (posedge out == 0) outClock = ~outClock;

Counter #(1, rate) counter (.clock(clock), .isEnabled(1), .isResetted(0), .out(out));

endmodule
