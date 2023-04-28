`timescale 1ns / 1ps

module Main(input clock, //clock
            input[3:0] inp, //switch_values
            input button, //button
            input sortButton, //button
            input resetButton, //button
            input leftButton,  //button
            input rightButton, //button
            input[7:0] mask, //switch_values
            input keyboardClock, //keyboard_values
            input keyboardData, //keyboard_values
            
            output[7:0] segmentValues,
            output[7:0] outMask);

wire[63:0] innerBus;
wire[31:0] outDigits;
wire[63:0] tempDigits;
wire[2:0] counterOut;
wire isReadyOutput;
wire isDecoderReadyOutput;
wire isKeyboardReadyOutput;
wire[3:0] keyboardOut;
wire outClock;
wire[1:0] flags;
wire keyReleasedFlag;
wire rButtonFlag;

wire bottomSignalButton;
wire topSignalButton;

wire bottomSignalSortButton;
wire topSignalSortButton;

wire bottomSignalResetButton;
wire topSignalResetButton;

wire bottomSignalLeftButton;
wire topSignalLeftButton;

wire bottomSignalRightButton;
wire topSignalRightButton;

// UI modules

//Switches input
//ShiftRegister shiftRegister(.clock(clock), .inp(inp), .isResetted(bottomSignalResetButton && topSignalResetButton), .inputButton(bottomSignalButton && topSignalButton), .leftButton(bottomSignalLeftButton && topSignalLeftButton),
//                                .rightButton(bottomSignalRightButton && topSignalRightButton), .tempDigits(tempDigits), .isReadyOutput(isReadyOutput), .out(outDigits), .innerBus(innerBus));

//Keyboard input
ShiftRegister shiftRegister(.clock(clock), .inp(inp), .inpKeyboard(keyboardOut), .isResetted(bottomSignalResetButton && topSignalResetButton), .keyReleasedFlag(keyReleasedFlag), .inputFlags(flags), .rButtonFlagS(rButtonFlag), .inputButton(bottomSignalButton && topSignalButton), .leftButton(bottomSignalLeftButton && topSignalLeftButton),
                                .rightButton(bottomSignalRightButton && topSignalRightButton), .tempDigits(tempDigits), .isReadyOutput(isReadyOutput), .isKeyboardReadyOutput(isKeyboardReadyOutput), .out(outDigits), .innerBus(innerBus));

ClockDivider #(10240) divider(.clock(clock), .outClock(outClock));

// Button modules
Filter filter1(.clock(clock), .isClockEnabled(1'b1), .signal(button), .bottomSignal(bottomSignalButton), .topSignal(topSignalButton));
Filter filter2(.clock(clock), .isClockEnabled(1'b1), .signal(sortButton), .bottomSignal(bottomSignalSortButton), .topSignal(topSignalSortButton));
Filter filter3(.clock(clock), .isClockEnabled(1'b1), .signal(resetButton), .bottomSignal(bottomSignalResetButton), .topSignal(topSignalResetButton));
Filter filter4(.clock(clock), .isClockEnabled(1'b1), .signal(leftButton), .bottomSignal(bottomSignalLeftButton), .topSignal(topSignalLeftButton));
Filter filter5(.clock(clock), .isClockEnabled(1'b1), .signal(rightButton), .bottomSignal(bottomSignalRightButton), .topSignal(topSignalRightButton));

// 7-segment control modules
Counter #(1, 8) counter(.clock(outClock), .isEnabled(1), .isResetted(0), .out(counterOut));
SegmentRegister segmentRegister(.clock(outClock), .address(counterOut), .value(outDigits), .segmentValues(segmentValues));
AnodesMaskRegister anodesRegister(.clock(outClock), .address(counterOut), .mask(mask), .anodes(outMask));

// Logic modules
CountSort countSort(.clock(clock), .value(innerBus), .isReadyInput(bottomSignalSortButton && topSignalSortButton),
   .isResetted(bottomSignalResetButton && topSignalResetButton), .isReadyOutput(isReadyOutput), .outValue(tempDigits));

keyboardSymbolDecoder symbolDecoder(.clock(clock), .keyboardClock(keyboardClock), .keyboardData(keyboardData),
    .isReadyOutput(isDecoderReadyOutput), .isKeyboardReadyOutput(isKeyboardReadyOutput), .out(keyboardOut), .flags(flags), .keyReleasedFlag(keyReleasedFlag), .rButtonFlagH(rButtonFlag));

endmodule
