`timescale 1ns / 1ps

module UART_Reader#(CLOCK_RATE = 10416)(
    Input_clk,
    Input_Clear_clk,
    Input_RX,
    Input_ReadNextPackage,
    Output_ASCII_Package_8bits,
    Output_Error,
    Output_PackageReady,
    Output_Listening);

    input wire Input_clk;
    input wire Input_Clear_clk;
    input wire Input_RX;
    input wire Input_ReadNextPackage;
    output wire [7:0] Output_ASCII_Package_8bits;
    output wire Output_PackageReady;
    output wire Output_Error;
    output wire Output_Listening;

    //// UART_Listener
    wire [7:0] Wire_Package_Data;
    wire Wire_Listener_Transfer;
    ////

    //// UART_Distributor
    wire Wire_Write;
    wire Wire_Distributor_Transfer;
    ////

    //// UART_Queue
    wire Wire_Full;
    wire Wire_Empty;
    wire Wire_Queue_ReadyToOutput;
    wire [7:0] Wire_Queue_Package_Data;
    ////

    reg [1:0] FromState = 2'd0;
    reg [7:0] Temp_Package_Data = 8'd0;

    assign Output_Listening = Wire_Listener_Transfer;

    assign Output_ASCII_Package_8bits = Temp_Package_Data;

    assign Output_PackageReady =
    (FromState == 2'd2) |
    (FromState == 2'd1 & Temp_Package_Data == Wire_Package_Data);

    always@(posedge Input_clk) begin
        if (Input_Clear_clk == 1'd1) begin
            Temp_Package_Data = 8'h30;
        end
        else if(Wire_Queue_ReadyToOutput == 1'd1 & Wire_Empty == 1'd0) begin
            FromState = 2'd2;
            Temp_Package_Data = Wire_Package_Data;
        end
        else if(Wire_Distributor_Transfer == 1'd1) begin
            FromState = 2'd1;
            Temp_Package_Data = Wire_Package_Data;
        end
        else if(Output_PackageReady == 1'd1)
            FromState = 2'd0;
    end

    UART_Listener #(CLOCK_RATE) module_UART_ListenerUART_Listener(
        .Input_clk( Input_clk ),
        .Input_RX_async( Input_RX ),
        .Output_Package_Data( Wire_Package_Data ),
        .Output_Package_Error( Output_Error ),
        .Output_Transfer( Wire_Listener_Transfer ));

    UART_Distributor module_UART_Distributor(
        .Input_clk( Input_clk ),
        .Input_Queue_Full( Wire_Full ),
        .Input_Queue_Empty( Wire_Empty ),
        .Input_Transfer( Wire_Listener_Transfer ),
        .Input_Package_Error( Output_Error ),
        .Input_WaitingForTransfer( Input_ReadNextPackage ),
        .Output_Write( Wire_Write ),
        .Output_Transfer( Wire_Distributor_Transfer));

    UART_Queue module_UART_Queue(
        .Input_clk( Input_clk ),
        .Input_Write( Wire_Write ),
        .Input_Read( Input_ReadNextPackage ),
        .Input_Package_Data( Wire_Package_Data ),
        .Output_Full( Wire_Full ),
        .Output_Empty( Wire_Empty ),
        .Output_Queue_Ready( Wire_Queue_ReadyToOutput ),
        .Output_Queue_Package_Data( Wire_Queue_Package_Data ));
endmodule
