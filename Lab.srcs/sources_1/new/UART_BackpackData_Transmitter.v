`timescale 1ns / 1ps

module UART_BackpackData_Transiver_Helper(
    Input_clk,
    Input_Queue_Full,
    Input_SortData_64bits,
    Input_Transfer,
    Output_HexNumber,
    Output_Transfer);

    input wire Input_clk;
    input wire Input_Queue_Full;
    input wire [63:0] Input_SortData_64bits;
    input wire Input_Transfer;
    output wire [4:0] Output_HexNumber;
    output reg Output_Transfer = 1'd0;

    reg [4:0] BitCounter = 5'd0;
    reg [3:0] TransferingDelay = 4'd0;
    reg Transfering_State = 1'd0;
    reg Last_Transfering_State = 1'd0;

    assign Output_HexNumber =
    (Input_SortData_64bits[63-:4] & {5{BitCounter == 5'd1}}) |
    (Input_SortData_64bits[59-:4] & {5{BitCounter == 5'd2}}) |
    (Input_SortData_64bits[55-:4] & {5{BitCounter == 5'd3}}) |
    (Input_SortData_64bits[51-:4] & {5{BitCounter == 5'd4}}) |
    (Input_SortData_64bits[47-:4] & {5{BitCounter == 5'd5}}) |
    (Input_SortData_64bits[43-:4] & {5{BitCounter == 5'd6}}) |
    (Input_SortData_64bits[39-:4]  & {5{BitCounter == 5'd7}})  |
    (Input_SortData_64bits[35-:4]  & {5{BitCounter == 5'd8}})  |
    (Input_SortData_64bits[31-:4] & {5{BitCounter == 5'd9}}) |
    (Input_SortData_64bits[27-:4] & {5{BitCounter == 5'd10}}) |
    (Input_SortData_64bits[23-:4]  & {5{BitCounter == 5'd11}})  |
    (Input_SortData_64bits[19-:4]  & {5{BitCounter == 5'd12}})  |
    (Input_SortData_64bits[15-:4] & {5{BitCounter == 5'd13}}) |
    (Input_SortData_64bits[11-:4] & {5{BitCounter == 5'd14}}) |
    (Input_SortData_64bits[7-:4]  & {5{BitCounter == 5'd15}})  |
    (Input_SortData_64bits[3-:4]  & {5{BitCounter == 5'd16}})  |
    (5'd16 & {5{BitCounter == 5'd17}});

    always@(posedge Input_clk) begin
        Output_Transfer = 1'd0;
    
        if (Transfering_State == 1'd1 & Input_Queue_Full == 1'd0) begin
            TransferingDelay = TransferingDelay + 1'd1;

            if (TransferingDelay == 4'd14)
                BitCounter = BitCounter + 1'd1;

            if (TransferingDelay == 4'd15)
                Output_Transfer = 1'd1;

            if (BitCounter == 5'd18) begin
                Transfering_State = 1'd0;
                TransferingDelay = 4'd0;
            end
        end
        else if (Last_Transfering_State != Input_Transfer) begin
            Last_Transfering_State = Input_Transfer;
            if (Input_Transfer == 1'd1) begin
                BitCounter = 5'd0;
                Transfering_State = 1'd1;
                TransferingDelay = 4'd0;
            end
        end
    end
endmodule

