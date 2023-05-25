`timescale 1ns / 1ps

module UART_Package_Transiver#(CLOCK_RATE = 10416)(
    Input_clk,
    Input_Package_Data,
    Input_Transfer,
    Output_Tx,
    Output_WaitingForTransfer);

    input wire Input_clk;
    input wire [7:0] Input_Package_Data;
    input wire Input_Transfer;
    output reg Output_Tx = 1'd1;
    output reg Output_WaitingForTransfer = 1'd1;

    reg [3:0] PackageCounter = 4'd0;
    reg [$clog2(CLOCK_RATE):0] Counter = 15'd0;
    reg Transfer = 1'd0;

    always@(posedge Input_clk) begin
        Counter = Counter + 1'd1;

        if (Input_Transfer == 1'd1 & Transfer == 1'd0) begin
            Transfer = 1'd1;
            Output_WaitingForTransfer = 1'd0;
        end

        if (Counter == CLOCK_RATE & Transfer == 1'd1) begin
            Counter = 15'd0;
            case (PackageCounter)
                4'd0: Output_Tx = 1'd0;
                4'd1: Output_Tx = Input_Package_Data[0];
                4'd2: Output_Tx = Input_Package_Data[1];
                4'd3: Output_Tx = Input_Package_Data[2];
                4'd4: Output_Tx = Input_Package_Data[3];

                4'd5: Output_Tx = Input_Package_Data[4];
                4'd6: Output_Tx = Input_Package_Data[5];
                4'd7: Output_Tx = Input_Package_Data[6];
                4'd8: Output_Tx = Input_Package_Data[7];
                4'd9: Output_Tx = 1'd1;
            endcase

            PackageCounter = PackageCounter + 1'd1;

            if (PackageCounter == 5'd10) begin
                PackageCounter = 4'd0;
                Transfer = 1'd0;
                Output_WaitingForTransfer = 1'd1;
            end
        end
    end
endmodule