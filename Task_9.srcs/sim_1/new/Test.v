`timescale 1ns / 1ps

module Test();

reg clock = 0;

always #10 clock = ~clock;

reg[3:0] test = 4'b0001;

reg button = 0;
reg[7:0] mask = 8'b0000_0000;
wire[7:0] segmentValues;
wire[7:0] outMask;

//initial
//begin
//    #50000000
//    button = ~button;
//    #50000000
//    button = ~button;
//end

 always #100000000
     test = (test + 1) % 8;
 
 always #50000000 
    button = ~button;
 

Main main(.clock(clock), .inp(test), .button(button), .sortButton(1'b0), .resetButton(1'b0), .mask(mask), .segmentValues(segmentValues), .outMask(outMask));

endmodule