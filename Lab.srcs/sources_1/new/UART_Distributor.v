`timescale 1ns / 1ps

module UART_Distributor(
    Input_clk,
    Input_Transfer,
    Input_Queue_Empty,
    Input_Queue_Full,
    Input_Package_Error,
    Input_WaitingForTransfer,
    Output_Write,
    Output_Transfer);

    input wire Input_clk;
    input wire Input_Transfer;
    input wire Input_Queue_Full;
    input wire Input_Queue_Empty;
    input wire Input_Package_Error;
    input wire Input_WaitingForTransfer;
    output reg Output_Write = 1'd0;
    output reg Output_Transfer = 1'd0;

    reg LastTransferState = 1'd0;

    always@(posedge Input_clk) begin
        Output_Transfer = 1'd0;
        Output_Write = 1'd0;
        
        if (LastTransferState != Input_Transfer) begin
            LastTransferState = Input_Transfer;
            if (Input_Transfer == 1'd1 & Input_Package_Error == 1'd0) begin
                if (Input_WaitingForTransfer == 1'd1 & Input_Queue_Empty == 1'd1) begin
                    Output_Transfer = 1'd1;
                end
                else if(Input_Queue_Full == 1'd0) begin
                    Output_Write = 1'd1;
                end
            end
        end
    end
endmodule
