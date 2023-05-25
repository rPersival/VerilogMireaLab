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
            
            input rxIn,
            
            output[7:0] segmentValues,
            output[7:0] outMask,
            output[15:0] Output_DebugLed,
            output Output_UART_TX_DataBit
            );

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
ShiftRegister shiftRegister(
        .clock(clock), .inp(inp | Output_Wire_UART_AscToHex_Hex_5bits),
        .inpKeyboard(keyboardOut), 
        .isResetted(Wire_ButtonDown_clk), 
        .keyReleasedFlag(keyReleasedFlag), 
        .inputFlags(flags), 
        .rButtonFlagS(rButtonFlag), 
        .inputButton(Wire_ButtonInsert_clk), 
        .leftButton(Wire_ButtonLeft_clk),
        .rightButton(Wire_ButtonRight_clk), 
        .tempDigits(tempDigits), 
        .isReadyOutput(isReadyOutput), 
        .isKeyboardReadyOutput(isKeyboardReadyOutput), 
        .out(outDigits), 
        .innerBus(innerBus));

ClockDivider #(10240) divider(.clock(clock), .outClock(outClock));

// Button modules
//Filter filter1(.clock(clock), .isClockEnabled(1'b1), .signal(button), .bottomSignal(bottomSignalButton), .topSignal(topSignalButton));
//Filter filter2(.clock(clock), .isClockEnabled(1'b1), .signal(sortButton), .bottomSignal(bottomSignalSortButton), .topSignal(topSignalSortButton));
//Filter filter3(.clock(clock), .isClockEnabled(1'b1), .signal(resetButton), .bottomSignal(bottomSignalResetButton), .topSignal(topSignalResetButton));
//Filter filter4(.clock(clock), .isClockEnabled(1'b1), .signal(leftButton), .bottomSignal(bottomSignalLeftButton), .topSignal(topSignalLeftButton));
//Filter filter5(.clock(clock), .isClockEnabled(1'b1), .signal(rightButton), .bottomSignal(bottomSignalRightButton), .topSignal(topSignalRightButton));

// 7-segment control modules
Counter #(1, 8) counter(.clock(outClock), .isEnabled(1), .isResetted(0), .out(counterOut));
SegmentRegister segmentRegister(.clock(outClock), .address(counterOut), .value(outDigits), .segmentValues(segmentValues));
AnodesMaskRegister anodesRegister(.clock(outClock), .address(counterOut), .mask(mask), .anodes(outMask));

// Logic modules
CountSort countSort(.clock(clock), .value(innerBus), .isReadyInput(Wire_ButtonClear_clk),
   .isResetted(Wire_ButtonDown_clk), .isReadyOutput(isReadyOutput), .outValue(tempDigits));

keyboardSymbolDecoder symbolDecoder(.clock(clock), .keyboardClock(keyboardClock), .keyboardData(keyboardData),
    .isReadyOutput(isDecoderReadyOutput), .isKeyboardReadyOutput(isKeyboardReadyOutput), .out(keyboardOut), .flags(flags), .keyReleasedFlag(keyReleasedFlag), .rButtonFlagH(rButtonFlag));

/////////////////InputInterfaceController/////////////////
    wire Wire_ButtonInsert_clk;
    wire Wire_ButtonClear_clk;
    wire Wire_ButtonLeft_clk;
    wire Wire_ButtonRight_clk;
    wire Wire_ButtonDown_clk;
    
assign Output_DebugLed[4:0] = Output_Wire_UART_AscToHex_Hex_5bits;
assign Output_DebugLed[15:8] = Output_Wire_UART_ReaderASCIIPackage_8bits[7:0];

    
    // Main module for interaction from buttons or keyboard or both
    InputInterfaceController module_InputInterfaceController(
        .Input_clk( clock ),
        .Input_Signal_ButtonInsert( button ),
        .Input_Signal_ButtonClear( sortButton ),
        .Input_Signal_ButtonLeft( leftButton ),
        .Input_Signal_ButtonRight( rightButton ),
        .Input_Signal_ButtonDown( resetButton ),
        
        .Input_UART_Reader_Ready( Output_Wire_UART_ReaderPackageReady_State ),
        .Input_UART_Data( Output_Wire_UART_ReaderASCIIPackage_8bits ),
        
        .Output_ButtonClear_clk( Wire_ButtonClear_clk ),
        .Output_ButtonInsert_clk( Wire_ButtonInsert_clk ),
        .Output_ButtonLeft_clk( Wire_ButtonLeft_clk ),
        .Output_ButtonRight_clk( Wire_ButtonRight_clk ),
        .Output_ButtonDown_clk( Wire_ButtonDown_clk ));
/////////////////InputInterfaceController/////////////////

wire[7:0] Output_Wire_UART_ReaderASCIIPackage_8bits;
wire Output_Wire_UART_ReaderPackageReady_State;
wire[4:0] Output_Wire_UART_AscToHex_Hex_5bits;

uartRxTx  uart
(
    .clock(clock),
    .rxIn(rxIn),
    .registerData(innerBus),
    .isSorted(isReadyOutput),
    
    .txOut(Output_UART_TX_DataBit),
    
    .Output_Wire_UART_ReaderASCIIPackage_8bits(Output_Wire_UART_ReaderASCIIPackage_8bits),
    .Output_Wire_UART_ReaderPackageReady_State(Output_Wire_UART_ReaderPackageReady_State),
    .Output_Wire_UART_AscToHex_Hex_5bits(Output_Wire_UART_AscToHex_Hex_5bits)
);

endmodule
