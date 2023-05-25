`timescale 1ns / 1ps

module FilterDrebezga#(Delay = 8)(
    Input_clk,
    Input_Signal,
    Output_Signal_Enable,
    Output_Signal);

    input Input_clk;
    input Input_Signal;
    output reg Output_Signal_Enable;
    output reg Output_Signal;

    wire Wire_StableSignal;
    wire Wire_IsMax;
    
    reg ClearCounter;

    initial begin
        ClearCounter = 0;
        Output_Signal_Enable = 0;
        Output_Signal = 0;
    end

    Syncronizator module_Syncronizator(
        .Input_clk( Input_clk ),
        .Input_AsyncSignal( Input_Signal ),
        .Output_StableSignal( Wire_StableSignal ));

    Counter_A #(Delay) module_Counter(
        .Input_clk( Input_clk ),
        .Input_ClearCounter( ClearCounter ),
        .Output_IsMax( Wire_IsMax ));

    always@(posedge Input_clk) begin
        if(Wire_IsMax == 1) begin
            Output_Signal_Enable = 1;
            Output_Signal = Wire_StableSignal;
        end else
            Output_Signal_Enable = 0;

        if(Wire_StableSignal == 0 & Output_Signal == 0)
            ClearCounter = 1;
        else if(Wire_StableSignal == 1 & Output_Signal == 1)
            ClearCounter = 1;
        else
            ClearCounter = 0;
    end
endmodule