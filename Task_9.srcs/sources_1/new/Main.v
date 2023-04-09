`timescale 1ns / 1ps

module Main(input clock, input[3:0] inp, input button, input sortButton, input resetButton, input[7:0] mask,
        output[7:0] segmentValues, output[7:0] outMask);

wire[31:0] outDigits;
wire[31:0] tempDigits;
wire[2:0] counterOut;
wire isReadyOutput;
wire outClock;

wire bottomSignalButton;
wire topSignalButton;

wire bottomSignalSortButton;
wire topSignalSortButton;

wire bottomSignalResetButton;
wire topSignalResetButton;

// UI modules
ShiftRegister shiftRegister(.clock(clock), .inp(inp), .button(bottomSignalButton && topSignalButton), .tempDigits(tempDigits), .isReadyOutput(isReadyOutput), .out(outDigits));
ClockDivider #(10240) divider(.clock(clock), .outClock(outClock));

// Button modules
Filter filter1(.clock(clock), .isClockEnabled(1'b1), .signal(button), .bottomSignal(bottomSignalButton), .topSignal(topSignalButton));
Filter filter2(.clock(clock), .isClockEnabled(1'b1), .signal(sortButton), .bottomSignal(bottomSignalSortButton), .topSignal(topSignalSortButton));
Filter filter3(.clock(clock), .isClockEnabled(1'b1), .signal(~resetButton), .bottomSignal(bottomSignalResetButton), .topSignal(topSignalResetButton));

// 7-segment control modules
Counter #(1, 8) counter(.clock(outClock), .isEnabled(1), .isResetted(0), .out(counterOut));
SegmentRegister segmentRegister(.clock(outClock), .address(counterOut), .value(outDigits), .segmentValues(segmentValues));
AnodesMaskRegister anodesRegister(.clock(outClock), .address(counterOut), .value(outDigits), .mask(mask), .anodes(outMask));

// Logic modules
CountSort countSort(.clock(clock), .value(outDigits), .isReadyInput(bottomSignalSortButton && topSignalSortButton), 
   .isResetted(bottomSignalResetButton && topSignalResetButton), .isReadyOutput(isReadyOutput), .outValue(tempDigits));


endmodule
