`timescale 1ns / 1ps

module UART_Queue(
    Input_clk,
    Input_Read,
    Input_Write,
    Input_Package_Data,
    Output_Full,
    Output_Empty,
    Output_Queue_Ready,
    Output_Queue_Package_Data);

    input wire Input_clk;
    input wire Input_Read;
    input wire Input_Write;
    input wire [7:0] Input_Package_Data;
    output reg Output_Full = 1'd0;
    output reg Output_Empty = 1'd1;
    output reg Output_Queue_Ready = 1'd0;
    output wire [7:0] Output_Queue_Package_Data;

    reg [31:0] Memory = 32'd0;
    reg [2:0] Blocks_Occupied = 3'd0;
    reg [1:0] Write_Address = 2'd0;
    reg [1:0] Read_Address = 2'd0;
    reg LastReadState = 1'd0;
    reg LastWriteState = 1'd0;

    assign Output_Queue_Package_Data[7:0] =
    Memory[7:0] & {8{Read_Address == 2'd0}} |
    Memory[15:8] & {8{Read_Address == 2'd1}} |
    Memory[23:16] & {8{Read_Address == 2'd2}} |
    Memory[31:24] & {8{Read_Address == 2'd3}};

    always@(posedge Input_clk) begin
        Output_Queue_Ready = 1'd0;

        if (LastReadState != Input_Read) begin
            if (Input_Read == 1'd1 & Blocks_Occupied > 3'd0) begin
                Read_Address = Write_Address - Blocks_Occupied;
                Blocks_Occupied = Blocks_Occupied - 3'd1;
                Output_Queue_Ready = 1'd1;
                LastReadState = 1'd1;
            end else
                LastReadState = 1'd0;
        end

        if (LastWriteState != Input_Write) begin
            LastWriteState = Input_Write;
            if (Input_Write == 1'd1 & Output_Full == 1'd0) begin
                case (Write_Address)
                    2'd0:Memory[7:0] = Input_Package_Data[7:0];
                    2'd1:Memory[15:8] = Input_Package_Data[7:0];
                    2'd2:Memory[23:16] = Input_Package_Data[7:0];
                    2'd3:Memory[31:24] = Input_Package_Data[7:0];
                endcase

                Blocks_Occupied = Blocks_Occupied + 3'd1;
                Write_Address = Write_Address + 2'd1;
            end
        end

        if (Blocks_Occupied == 3'd0) begin
            Output_Empty = 1'd1;
            Output_Full = 1'd0;
        end
        else if (Blocks_Occupied == 3'd4) begin
            Output_Empty = 1'd0;
            Output_Full = 1'd1;
        end else begin
            Output_Empty = 1'd0;
            Output_Full = 1'd0;
        end
    end
endmodule