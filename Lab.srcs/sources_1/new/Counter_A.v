`timescale 1ns / 1ps

module Counter_A#(Max = 1, Repeat = 1'd1)(
    Input_clk,
    Input_ClearCounter,
    Output_IsMax,
    Output_IsHalf,
    Output_Counter);

    input Input_clk;
    input Input_ClearCounter;
    output reg Output_IsMax;
    output reg Output_IsHalf;
    output reg [$clog2(Max):0] Output_Counter;

    initial begin
        Output_Counter = 0;
        Output_IsMax = 1'd0;
        Output_IsHalf = 1'd0;
    end

    always@(posedge Input_clk) begin
        if (Input_ClearCounter == 1) begin
            Output_Counter = 1'd0;
            Output_IsMax = 1'd0;
            Output_IsHalf = 1'd0;
        end
        else if (Output_Counter == (Max - 1) ) begin
            Output_IsMax = 1'd1;
            
            if(Repeat == 1)
                Output_Counter = 1'd0;
        end
        else begin
            Output_IsMax = 1'd0;
            Output_IsHalf = 1'd0;
            Output_Counter = Output_Counter + 1'd1;
        end
        
        if (Output_Counter == ((Max - 1) / 2)) begin
            Output_IsHalf = 1'd1;
        end
    end
endmodule