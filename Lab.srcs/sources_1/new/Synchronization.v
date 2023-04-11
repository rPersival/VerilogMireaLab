`timescale 1ns / 1ps

module Synchronization(input clock, input asyncSignal, output reg outSignal = 0);

reg tempReg = 0;

always @(posedge clock)
    tempReg = asyncSignal;

always @(posedge clock) 
    outSignal = tempReg;

endmodule
