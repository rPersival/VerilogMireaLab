`timescale 1ns / 1ps

module keyboardTest();

//input
reg clock = 0;
//reg keyboardClock = 0;
reg[15:0] keyboardData = 16'h2EF0;
reg[4:0] counter = 0;
reg[7:0] mask = 8'b0000_0000;

//output
wire[7:0] segmentValues;
wire[7:0] outMask;
wire dividedClock;

reg testKeyboardData = 0;
//reg flag = 0;

always #10 
begin
    clock = ~clock;
//    keyboardClock = ~keyboardClock;
    if (counter >= 5'd15)
        testKeyboardData = 0;
//        flag = 1;
    else
        testKeyboardData = keyboardData[counter];
    counter = counter + 1;
end

Main main(.clock(clock), .inp(4'b0000), .button(1'b0), .sortButton(1'b0), .resetButton(1'b0),
             .leftButton(1'b0), .rightButton(1'b0), .mask(mask), .keyboardClock(dividedClock), .keyboardData(testKeyboardData), .segmentValues(segmentValues), .outMask(outMask));
             
ClockDivider #(3) keyboardClockDivider(.clock(clock), .outClock(dividedClock));


endmodule
