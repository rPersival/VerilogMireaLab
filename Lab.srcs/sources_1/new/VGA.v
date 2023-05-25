`timescale 1ns / 1ps

`define WIDTH 800 
`define H_FRONT_PORCH 56
`define H_BACK_PORCH 64 
`define H_SYNC 120   
`define HEIGHT 600 
`define V_FRONT_PORCH 37 
`define V_BACK_PORCH 23 
`define V_SYNC 6   
`define RESET 4'd0
`define HOR_PERIOD 4'd1
`define H_NOT_ACTIVE_PERIOD 4'd2
`define V_NOT_ACTIVE_PERIOD 4'd3
`define COLOR_BIT_SIZE 3 

module VGA(
    Input_clk,
    Input_Color_Data,
    Output_Color_Address,
    Output_VGA_RED,
    Output_VGA_GREEN,
    Output_VGA_BLUE,
    Output_Hsync,
    Output_Vsync,
    Output_VGA_Begin,
    Output_VGA_End
);

    input Input_clk;
    input [`COLOR_BIT_SIZE-1:0] Input_Color_Data;
    output reg [$clog2(`WIDTH * `HEIGHT)-1:0] Output_Color_Address;
    output [3:0] Output_VGA_RED;
    output [3:0] Output_VGA_GREEN;
    output [3:0] Output_VGA_BLUE;
    output reg Output_Hsync;
    output reg Output_Vsync;
    output reg Output_VGA_Begin;
    output reg Output_VGA_End;

    reg [1:0] state;
    reg [`COLOR_BIT_SIZE-1:0] vgaColor;
    reg VGA_clk;
    reg [$clog2(`WIDTH + `H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH)-1:0] H_counter;
    reg [$clog2(`HEIGHT + `V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH)-1:0] V_counter;

    assign Output_VGA_RED = vgaColor[2] ? 4'hF : 0;
    assign Output_VGA_GREEN = vgaColor[1] ? 4'hF : 0;
    assign Output_VGA_BLUE = vgaColor[0] ? 4'hF : 0;

    always@(posedge Input_clk) begin
        VGA_clk <= ~VGA_clk;
    end

    initial begin
        VGA_clk <= 0;
        vgaColor <= 0;
        Output_Hsync <= 0;
        Output_Vsync <= 0;
        state <= `RESET;
    end

    always@(posedge VGA_clk) begin
        case(state)
            `RESET: begin
                Output_Color_Address <= 0;
                V_counter <= 0;
                H_counter <= 0;
                Output_VGA_Begin <= 1;
                Output_VGA_End <= 0;
                vgaColor <= 0;
                state <= `HOR_PERIOD;
            end
            `HOR_PERIOD: begin
                if (H_counter == `WIDTH) begin
                    vgaColor <= 0;
                    state <= `H_NOT_ACTIVE_PERIOD;
                end
                else begin
                    if (V_counter < `HEIGHT) begin
                        vgaColor <= Input_Color_Data;
                        if (Output_Color_Address < `WIDTH * `HEIGHT-1)
                            Output_Color_Address <= Output_Color_Address + 1;
                        else
                            Output_Color_Address <= 0;
                    end
                    H_counter <= H_counter + 1;
                end
                    Output_VGA_Begin <= 0;
            end
            `H_NOT_ACTIVE_PERIOD: begin
                if (H_counter == `WIDTH + `H_FRONT_PORCH - 1 || 
                    H_counter ==`WIDTH + `H_FRONT_PORCH + `H_SYNC - 1) begin
                    Output_Hsync <= ~Output_Hsync;
                    H_counter <= H_counter + 1;
                end
                else begin
                    if (H_counter == `WIDTH + `H_FRONT_PORCH + `H_SYNC +`H_BACK_PORCH - 1)
                        state <= `V_NOT_ACTIVE_PERIOD;
                    else
                        H_counter <= H_counter + 1;
                end
            end
            `V_NOT_ACTIVE_PERIOD: begin
                if (V_counter == `HEIGHT + `V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH - 1)
                    begin
                        state <= `RESET;
                        Output_VGA_End <= 1;
                    end
                else begin
                    if (V_counter == `HEIGHT + `V_FRONT_PORCH - 1 ||
                        V_counter == `HEIGHT + `V_FRONT_PORCH + `V_SYNC - 1)
                        Output_Vsync <= ~Output_Vsync;
                    H_counter <= 0;
                    V_counter <= V_counter + 1;
                    state <= `HOR_PERIOD;
                end
            end
        endcase
    end
endmodule