`timescale 1ns / 1ps

module UART_Hex_To_ASCII(
    Input_clk,
    Input_Hex_5bits,
    Output_ASCII_8bits);
    
    input wire Input_clk;
    input wire [4:0] Input_Hex_5bits;
    output wire [7:0] Output_ASCII_8bits;
    
    assign Output_ASCII_8bits = 
        ({8{Input_Hex_5bits == 5'd0}}  & 8'h30) |
        ({8{Input_Hex_5bits == 5'd1}}  & 8'h31) |
        ({8{Input_Hex_5bits == 5'd2}}  & 8'h32) |
        ({8{Input_Hex_5bits == 5'd3}}  & 8'h33) |
        ({8{Input_Hex_5bits == 5'd4}}  & 8'h34) |
        ({8{Input_Hex_5bits == 5'd5}}  & 8'h35) |
        ({8{Input_Hex_5bits == 5'd6}}  & 8'h36) |
        ({8{Input_Hex_5bits == 5'd7}}  & 8'h37) |
        ({8{Input_Hex_5bits == 5'd8}}  & 8'h38) |
        ({8{Input_Hex_5bits == 5'd9}}  & 8'h39) |
        ({8{Input_Hex_5bits == 5'd10}} & 8'h41) |
        ({8{Input_Hex_5bits == 5'd11}} & 8'h42) |
        ({8{Input_Hex_5bits == 5'd12}} & 8'h43) |
        ({8{Input_Hex_5bits == 5'd13}} & 8'h44) |
        ({8{Input_Hex_5bits == 5'd14}} & 8'h45) |
        ({8{Input_Hex_5bits == 5'd15}} & 8'h46) |
        ({8{Input_Hex_5bits == 5'd16}} & 8'h0D);
endmodule
