`timescale 1ns / 1ps

module UART_Listener#(CLOCK_RATE = 10416)(
    Input_clk,
    Input_RX_async,
    Output_Package_Data,
    Output_Package_Error,
    Output_Transfer);

    input wire Input_clk;
    input wire Input_RX_async;
    output reg [7:0] Output_Package_Data = 8'd0;
    output reg Output_Transfer = 1'd1;
    output reg Output_Package_Error = 1'd1;

    wire Wire_RX_Stable;
    wire Wire_IsMax;
    wire Wire_IsHalf;
    wire [$clog2(CLOCK_RATE):0] Wire_Counter;

    reg [3:0] PackageCounter = 4'd0;
    reg ClearCounter = 1'd0;

    Counter_A #(CLOCK_RATE) module_counter(
        .Input_clk( Input_clk ),
        .Input_ClearCounter( ClearCounter ),
        .Output_IsMax( Wire_IsMax ),
        .Output_IsHalf( Wire_IsHalf ),
        .Output_Counter(Wire_Counter));

    Syncronizator module_UART_RX_Syncronizator(
        .Input_clk( Input_clk ),
        .Input_AsyncSignal( Input_RX_async ),
        .Output_StableSignal( Wire_RX_Stable ));

    always@(posedge Input_clk) begin
        if(PackageCounter == 4'd0 & Wire_RX_Stable == 1'd0) begin
            ClearCounter = 1'd0;
        end

        if (Wire_IsHalf == 1'd1) begin
            if(PackageCounter == 1'd0 & Wire_RX_Stable != 1'd0) begin
                Output_Package_Error = 1'd1;
                ClearCounter = 1'd1;
            end
            else if(PackageCounter == 1'd0) begin
                Output_Package_Error = 1'd0;
                Output_Transfer = 1'd0;
            end

            if(PackageCounter == 4'd9 & Wire_RX_Stable != 1'd1) begin
                Output_Package_Error = 1'd1;
                ClearCounter = 1'd1;
                PackageCounter = 4'd0;
            end

            if(Output_Package_Error == 1'd0) begin
                case (PackageCounter)
                    4'd1: Output_Package_Data[0] = Wire_RX_Stable;
                    4'd2: Output_Package_Data[1] = Wire_RX_Stable;
                    4'd3: Output_Package_Data[2] = Wire_RX_Stable;
                    4'd4: Output_Package_Data[3] = Wire_RX_Stable;

                    4'd5: Output_Package_Data[4] = Wire_RX_Stable;
                    4'd6: Output_Package_Data[5] = Wire_RX_Stable;
                    4'd7: Output_Package_Data[6] = Wire_RX_Stable;
                    4'd8: Output_Package_Data[7] = Wire_RX_Stable;
                endcase

                PackageCounter = PackageCounter + 1'd1;
            end

            if (PackageCounter == 4'd10) begin
                PackageCounter = 4'd0;
                ClearCounter = 1'd1;
                Output_Transfer = 1'd1;
            end
        end
    end
endmodule
