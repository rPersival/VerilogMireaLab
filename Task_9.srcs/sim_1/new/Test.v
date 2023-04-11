`timescale 1ns / 1ps

module Test();

reg clock = 0;

always #10 clock = ~clock;

reg[3:0] test = 4'b0001;

reg inputButton = 0;
reg sortButton = 0;
reg leftButton = 0;
reg rightButton = 0;
reg resetButton = 1;

reg[7:0] mask = 8'b0000_0000;
wire[7:0] segmentValues;
wire[7:0] outMask;

// initial
// begin
//    #10000000
//    leftButton = ~leftButton;
// end

always #10000000
    leftButton = ~leftButton;

//  always #100000000
//      test = (test + 1) % 8;
 
//  always #50000000 
//     button = ~button;
 

Main main(.clock(clock), .inp(test), .button(inputButton), .leftButton(leftButton), .rightButton(rightButton),
             .sortButton(sortButton), .resetButton(resetButton), .mask(mask), .segmentValues(segmentValues), .outMask(outMask));

endmodule