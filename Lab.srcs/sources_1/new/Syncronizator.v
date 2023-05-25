`timescale 1ns / 1ps

module Syncronizator(
    Input_clk,
    Input_AsyncSignal,
    Output_StableSignal);

    input Input_clk;
    input Input_AsyncSignal;
    output wire Output_StableSignal;
    
    reg RegisterA;
    reg RegisterB;
    
    assign Output_StableSignal = RegisterB;

    initial begin
        RegisterA <= 1'd0;
        RegisterB <= 1'd0;
    end

    always@(posedge Input_clk) begin
        RegisterA <= Input_AsyncSignal;
        RegisterB <= RegisterA;
    end
endmodule