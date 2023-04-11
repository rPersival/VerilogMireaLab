`timescale 1ns / 1ps

module AnodesMaskRegister
(
    input clock,
    input[2:0] address,
    input[7:0] mask,
    output wire[7:0] anodes
);

reg[7:0] tempAnodes = -2;

always@ (posedge clock)
    tempAnodes <= ~(1 << address) | mask;

assign anodes = tempAnodes;

endmodule