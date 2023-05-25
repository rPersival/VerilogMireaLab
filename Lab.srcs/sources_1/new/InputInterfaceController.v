`timescale 1ns / 1ps

module InputInterfaceController#(Delay = 4096)(
    Input_clk,
    Input_Signal_ButtonClear,
    Input_Signal_ButtonInsert,
    Input_Signal_ButtonLeft,
    Input_Signal_ButtonRight,
    Input_Signal_ButtonDown,
    Input_Key_Release,
    Input_Key_Pressed,
    Input_Key_Special,
    Input_Key_Ready,
    Input_Scancode,
    
    Input_UART_Reader_Ready,
    Input_UART_Data,
    
    Output_ButtonClear_clk,
    Output_ButtonInsert_clk,
    Output_ButtonLeft_clk,
    Output_ButtonRight_clk,
    Output_ButtonDown_clk);
    
    input wire Input_clk;
    input wire Input_Signal_ButtonClear;
    input wire Input_Signal_ButtonInsert;
    input wire Input_Signal_ButtonLeft;
    input wire Input_Signal_ButtonRight;
    input wire Input_Signal_ButtonDown;
    input wire Input_Key_Release;
    input wire Input_Key_Pressed;
    input wire Input_Key_Special;
    input wire Input_Key_Ready;
    input wire [7:0] Input_Scancode;
    input wire Input_UART_Reader_Ready;
    input wire [7:0] Input_UART_Data;
    
    output wire Output_ButtonClear_clk;
    output wire Output_ButtonInsert_clk;
    output wire Output_ButtonLeft_clk;
    output wire Output_ButtonRight_clk;
    output wire Output_ButtonDown_clk;
    
    wire Wire_ButtonClear_Enabled;
    wire Wire_ButtonClear_Signal;    

    wire Wire_ButtonInsert_Enabled;
    wire Wire_ButtonInsert_Signal;

    wire Wire_ButtonLeft_Enabled;
    wire Wire_ButtonLeft_Signal;

    wire Wire_ButtonRight_Enabled;
    wire Wire_ButtonRight_Signal;

    wire Wire_ButtonDown_Enabled;
    wire Wire_ButtonDown_Signal;
    
    assign Output_ButtonClear_clk = 
    Wire_ButtonClear_Enabled & Wire_ButtonClear_Signal | 
    Input_UART_Reader_Ready & Input_UART_Data == 8'h47;
    
    assign Output_ButtonInsert_clk = 
    Wire_ButtonInsert_Enabled & Wire_ButtonInsert_Signal | 
    Input_UART_Reader_Ready & Input_UART_Data == 8'h4B;
    
    assign Output_ButtonLeft_clk = 
    Wire_ButtonLeft_Enabled & Wire_ButtonLeft_Signal | 
    Input_UART_Reader_Ready & Input_UART_Data == 8'h49;
    
    assign Output_ButtonRight_clk = 
    Wire_ButtonRight_Enabled & Wire_ButtonRight_Signal | 
    Input_UART_Reader_Ready & Input_UART_Data == 8'h4A;
    
    assign Output_ButtonDown_clk = 
    Wire_ButtonDown_Enabled & Wire_ButtonDown_Signal | 
    Input_UART_Reader_Ready & Input_UART_Data == 8'h48;

    FilterDrebezga #(Delay) Filter_ButtonClear(
        .Input_clk( Input_clk ),
        .Input_Signal( Input_Signal_ButtonClear  | (Input_Key_Ready & Input_Key_Special & Input_Key_Release & Input_Scancode == 8'h71)),
        .Output_Signal_Enable( Wire_ButtonClear_Enabled ),
        .Output_Signal( Wire_ButtonClear_Signal ));

    FilterDrebezga #(Delay) Filter_ButtonInsert(
        .Input_clk( Input_clk ),
        .Input_Signal( Input_Signal_ButtonInsert | (Input_Key_Ready & Input_Key_Release & Input_Scancode == 8'h5A)),
        .Output_Signal_Enable( Wire_ButtonInsert_Enabled ),
        .Output_Signal( Wire_ButtonInsert_Signal ));

    FilterDrebezga #(Delay) Filter_ButtonLeft(
        .Input_clk( Input_clk ),
        .Input_Signal( Input_Signal_ButtonLeft | (Input_Key_Ready & Input_Key_Special & Input_Key_Release & Input_Scancode == 8'h6B)),
        .Output_Signal_Enable( Wire_ButtonLeft_Enabled ),
        .Output_Signal( Wire_ButtonLeft_Signal ));

    FilterDrebezga #(Delay) Filter_ButtonRight(
        .Input_clk( Input_clk ),
        .Input_Signal( Input_Signal_ButtonRight | (Input_Key_Ready & Input_Key_Special & Input_Key_Release & Input_Scancode == 8'h74)),
        .Output_Signal_Enable( Wire_ButtonRight_Enabled ),
        .Output_Signal( Wire_ButtonRight_Signal ));

    FilterDrebezga #(Delay) Filter_ButtonDown(
        .Input_clk( Input_clk ),
        .Input_Signal( Input_Signal_ButtonDown | (Input_Key_Ready & Input_Key_Special & Input_Key_Release & Input_Scancode == 8'h72)),
        .Output_Signal_Enable( Wire_ButtonDown_Enabled ),
        .Output_Signal( Wire_ButtonDown_Signal ));

endmodule
