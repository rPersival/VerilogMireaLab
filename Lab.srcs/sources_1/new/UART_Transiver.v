`timescale 1ns / 1ps

module UART_Transiver#(CLOCK_RATE = 10416)(
    Input_clk,
    Input_Clear_clk,
    Input_Package_Data,
    Input_Transfer,
    Output_Queue_Full,
    Output_UART_Tx);

    input wire Input_clk;
    input wire Input_Clear_clk;
    input wire [7:0] Input_Package_Data;
    input wire Input_Transfer;
    output wire Output_UART_Tx;
    output wire Output_Queue_Full;

    wire Wire_Transfer;
    wire [7:0] Wire_Package_Data;

    //// UART_Package_Transiver
    wire Wire_WaitingForTransfer;
    ////

    //// UART_Distributor
    wire Wire_Write;
    wire Wire_Distributor_ReadyToOutput;
    ////

    //// UART_Queue
    //wire Wire_Full;
    wire Wire_Empty;
    wire Wire_Queue_ReadyToOutput;
    wire [7:0] Wire_Queue_Package_Data;
    ////

    reg [1:0] FromState = 2'd0;
    reg [7:0] Temp_Package_Data = 8'd0;

    assign Wire_Package_Data = Temp_Package_Data;

    assign Wire_Transfer =
    (Wire_Queue_ReadyToOutput & FromState == 2'd2) |
    (Wire_Distributor_ReadyToOutput & FromState == 2'd1 & Temp_Package_Data == Input_Package_Data);

    always@(posedge Wire_Queue_ReadyToOutput or posedge Wire_Distributor_ReadyToOutput or posedge Input_Clear_clk) begin
        if (Input_Clear_clk == 1'd1) begin
            Temp_Package_Data = 8'h30;
        end
        else if(Wire_Queue_ReadyToOutput == 1'd1) begin
            FromState = 2'd2;
            Temp_Package_Data = Wire_Queue_Package_Data;
        end
        else if(Wire_Distributor_ReadyToOutput == 1'd1) begin
            FromState = 2'd1;
            Temp_Package_Data = Input_Package_Data;
        end
    end

    UART_Package_Transiver #(CLOCK_RATE) module_UART_Package_Transiver(
        .Input_clk( Input_clk ),
        .Input_Transfer( Wire_Transfer ),
        .Input_Package_Data( Wire_Package_Data ),
        .Output_Tx( Output_UART_Tx ),
        .Output_WaitingForTransfer( Wire_WaitingForTransfer ));

    UART_Distributor module_UART_Distributor(
        .Input_clk( Input_clk ),
        .Input_Queue_Full( Output_Queue_Full ),
        .Input_Queue_Empty( Wire_Empty ),
        .Input_Transfer( Input_Transfer ),
        .Input_Package_Error( 1'd0 ),
        .Input_WaitingForTransfer( Wire_WaitingForTransfer ),
        .Output_Write( Wire_Write ),
        .Output_Transfer( Wire_Distributor_ReadyToOutput));

    UART_Queue module_UART_Queue(
        .Input_clk( Input_clk ),
        .Input_Write( Wire_Write ),
        .Input_Read( Wire_WaitingForTransfer ),
        .Input_Package_Data( Input_Package_Data ),
        .Output_Full( Output_Queue_Full ),
        .Output_Empty( Wire_Empty ),
        .Output_Queue_Ready( Wire_Queue_ReadyToOutput ),
        .Output_Queue_Package_Data( Wire_Queue_Package_Data ));
endmodule
