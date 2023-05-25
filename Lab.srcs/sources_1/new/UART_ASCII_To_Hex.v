`timescale 1ns / 1ps

module UART_ASCII_To_Hex(
    Input_clk,
    Input_Clear_clk,
    Input_ASCII_8bits,
    Input_UART_ReaderReady_State,
    Output_Hex_5bits);

    input wire Input_clk;
    input wire Input_Clear_clk;
    input wire [7:0] Input_ASCII_8bits;
    input wire Input_UART_ReaderReady_State;
    output reg [4:0] Output_Hex_5bits = 5'd0;

    wire Wire_UART_ReaderReady_stable;
    
    Syncronizator module_ReadyToOutput_Syncronizator(
        .Input_clk( Input_clk ),
        .Input_AsyncSignal( Input_UART_ReaderReady_State ),
        .Output_StableSignal( Wire_UART_ReaderReady_stable ));

    always@(posedge Wire_UART_ReaderReady_stable or posedge Input_Clear_clk) begin
        if (Input_Clear_clk == 1'd1) begin
            Output_Hex_5bits = 5'd0;
        end
        else begin
            case (Input_ASCII_8bits)
                8'h30:Output_Hex_5bits = 5'd0; // 0
                8'h31:Output_Hex_5bits = 5'd1; // 1
                8'h32:Output_Hex_5bits = 5'd2; // 2
                8'h33:Output_Hex_5bits = 5'd3; // 3
                8'h34:Output_Hex_5bits = 5'd4; // 4
                8'h35:Output_Hex_5bits = 5'd5; // 5
                8'h36:Output_Hex_5bits = 5'd6; // 6
                8'h37:Output_Hex_5bits = 5'd7; // 7
                8'h38:Output_Hex_5bits = 5'd8; // 8
                8'h39:Output_Hex_5bits = 5'd9; // 9
                8'h41:Output_Hex_5bits = 5'd10; // A
                8'h42:Output_Hex_5bits = 5'd11; // B
                8'h43:Output_Hex_5bits = 5'd12; // C
                8'h44:Output_Hex_5bits = 5'd13; // D
                8'h45:Output_Hex_5bits = 5'd14; // E
                8'h46:Output_Hex_5bits = 5'd15; // F
                default:Output_Hex_5bits = 5'd0; // 0
            endcase
        end
    end
endmodule
