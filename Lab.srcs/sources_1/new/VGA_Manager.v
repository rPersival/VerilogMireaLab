`timescale 1ns / 1ps

`define CHAR_WIDTH 9
`define CHAR_HEIGHT 12
`define SPACE_HOR 12
`define SPACE_VER 9
`define KERNING 3
`define A 5'd10
`define B 5'd11
`define C 5'd12
`define D 5'd13
`define E 5'd14
`define F 5'd15
`define L 5'd16
`define O 5'd17
`define R 5'd18
`define S 5'd19
`define T 5'd20
`define S0 4'd0
`define U 5'd21
`define COLON 5'd22
`define SCREAMER 5'd23
`define SPACE 5'd24
`define RESULT_VGA_STR_SIZE 24
`define ERROR_VGA_STR_SIZE 8
`define MAX_STRING_SIZE 31
`define S0 4'd0
`define S1 4'd1
`define S2 4'd2
`define S3 4'd3
`define S4 4'd4
`define S5 4'd5
`define S6 4'd6
`define S7 4'd7
`define SHIFT_1 4'd9
`define SHIFT_2 4'd10
`define SHIFT_3 4'd11
`define SHIFT_4 4'd12
`define SHIFT_5 4'd13
`define CLEAR_1 4'd14
`define CLEAR_2 4'd15

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

module VGA_Manager #(ALPHABET_SIZE = 25,COLOR_COUNT = 4)(
    Input_clk,
    Input_Backpack_Answer,
    Input_Error,
    Input_Display,
    Input_VGA_Begin,
    Input_VGA_End,
    Input_Color_Address,
    Output_Color_Data);

    input Input_clk;
    input [63:0] Input_Backpack_Answer;
    input [$clog2(COLOR_COUNT) - 1:0] Input_Error;
    input Input_Display;
    input Input_VGA_Begin;
    input Input_VGA_End;
    input [$clog2(`WIDTH*`HEIGHT)-1:0] Input_Color_Address;
    output [`COLOR_BIT_SIZE -1:0] Output_Color_Data;

    localparam MAX_PIXEL_COUNT = `WIDTH * `HEIGHT;
    localparam STR_WITH_KERNING_PIXEL_COUNT = `WIDTH * (`CHAR_HEIGHT + `KERNING);
    reg [3:0] state;
    reg [63:0] result_reg;
    reg [$clog2(COLOR_COUNT)-1:0] error_reg;
    reg [$clog2(`WIDTH)-1:0] x0;
    reg [$clog2(`HEIGHT)-1:0] y0;
    reg [$clog2(`CHAR_WIDTH)-1:0] x_char;
    reg [$clog2(`CHAR_HEIGHT)-1:0] y_char;
    reg [$clog2(`MAX_STRING_SIZE)-1:0] char_counter;
    reg [0:$clog2(ALPHABET_SIZE)-1] string_reg [0:`MAX_STRING_SIZE-1];
    reg [`COLOR_BIT_SIZE-1:0] char_color_list [0:`MAX_STRING_SIZE-1];
    reg [$clog2(`MAX_STRING_SIZE)-1:0] string_size;
    reg [0:`CHAR_WIDTH-1] char_reg [0:`CHAR_HEIGHT-1];
    reg [`COLOR_BIT_SIZE-1:0] color_reg;
    reg [`COLOR_BIT_SIZE-1:0] color_arr [0:COLOR_COUNT-1];
    reg [0:`CHAR_WIDTH-1] alphabet [0:`CHAR_HEIGHT-1] [0:ALPHABET_SIZE-1];
    reg [$clog2(MAX_PIXEL_COUNT)-1:0] frame_buf_addr;
    reg [`COLOR_BIT_SIZE-1:0] frame_buf_data_in;
    wire [`COLOR_BIT_SIZE-1:0] frame_buf_data_out;
    reg frame_buf_we;
    reg [$clog2(MAX_PIXEL_COUNT):0] pixel_counter;
    reg Last_Input_Display_State;

    blk_mem_gen_0 frame_buf
    (
        .clka(Input_clk),
        .wea(frame_buf_we),
        .addra(frame_buf_addr),
        .dina(frame_buf_data_in),
        .douta(frame_buf_data_out),

        .clkb(Input_clk),
        .web(1'b0),
        .addrb(Input_Color_Address),
        .dinb(0),
        .doutb(Output_Color_Data)
    );

    integer i, j, k;

    initial begin
        $readmemb("colors.mem", color_arr);
        $readmemb("alphabet.mem", alphabet);

        for (i = 0; i < `MAX_STRING_SIZE; i = i + 1) begin
            string_reg[i] <= 0;
            char_color_list[i] <= 0;
        end

        for (j = 0; j < `CHAR_HEIGHT; j = j + 1)
            char_reg[j] <= 0;

        color_reg <= 0;
        result_reg <= 0;
        error_reg <= 0;
        x0 <= `SPACE_HOR;
        y0 <= `SPACE_VER;
        frame_buf_addr <= 0;
        frame_buf_data_in <= 0;
        frame_buf_we <= 0;
        state <= `S0;
        Last_Input_Display_State <= 0;
    end

    always@(posedge Input_clk) begin: main
        case(state)
            `S0: begin
                char_counter <= 0;
                x0 <= `SPACE_HOR; // Making some space from the left border
                state <= `S1;
            end
            `S1: begin
                if (Last_Input_Display_State != Input_Display) begin
                    Last_Input_Display_State <= Input_Display;
                    if (Input_Display == 1'd1) begin
                        result_reg <= Input_Backpack_Answer;
                        error_reg <= Input_Error;
                        state <= `S2;
                    end
                end
            end
            `S2: begin
                if (error_reg != 0) begin
                    string_reg[0] <= `E;
                    string_reg[1] <= `R;
                    string_reg[2] <= `R;
                    string_reg[3] <= `O;
                    string_reg[4] <= `R;
                    string_reg[5] <= `SPACE;
                    string_reg[6] <= error_reg;
                    string_reg[7] <= `SCREAMER;

                    string_size <= `ERROR_VGA_STR_SIZE;

                    for (i = 0; i < `ERROR_VGA_STR_SIZE; i = i+ 1)
                        if (i == 6)
                            char_color_list[6] = color_arr[error_reg];
                        else
                            char_color_list[i] = color_arr[0];
                end
                else begin
                    string_reg[0] <= `R; // 1
                    string_reg[1] <= `E; // 2
                    string_reg[2] <= `S; // 3
                    string_reg[3] <= `U; // 4
                    string_reg[4] <= `L; // 5
                    string_reg[5] <= `T; //6
                    string_reg[6] <= `COLON; //7
                    string_reg[7] <= `SPACE; //8
                    string_reg[8] <= result_reg[63-:4]; //1
                    string_reg[9] <= result_reg[59-:4]; //2
                    string_reg[10] <= result_reg[55-:4]; //3
                    string_reg[11] <= result_reg[51-:4]; //4
                    string_reg[12] <= result_reg[47-:4]; //5
                    string_reg[13] <= result_reg[43-:4]; //6
                    string_reg[14] <= result_reg[39-:4]; //7
                    string_reg[15] <= result_reg[35-:4]; //8
                    string_reg[16] <= result_reg[31-:4]; //9
                    string_reg[17] <= result_reg[27-:4]; //10
                    string_reg[18] <= result_reg[23-:4]; //11
                    string_reg[19] <= result_reg[19-:4]; //12
                    string_reg[20] <= result_reg[15-:4]; //13
                    string_reg[21] <= result_reg[11-:4]; //14
                    string_reg[22] <= result_reg[7-:4]; //15
                    string_reg[23] <= result_reg[3-:4]; //16
                    string_size <= `RESULT_VGA_STR_SIZE;

                    char_color_list[0] = color_arr[2];
                    char_color_list[1] = color_arr[2];
                    char_color_list[2] = color_arr[2];
                    char_color_list[3] = color_arr[2];
                    char_color_list[4] = color_arr[2];
                    char_color_list[5] = color_arr[2];
                    char_color_list[6] = color_arr[0];

                    char_color_list[7] = color_arr[0];

                    char_color_list[8] = color_arr[1];
                    char_color_list[9] = color_arr[1];
                    char_color_list[10] = color_arr[1];
                    char_color_list[11] = color_arr[1];
                    char_color_list[12] = color_arr[1];
                    char_color_list[13] = color_arr[1];
                    char_color_list[14] = color_arr[1];
                    char_color_list[15] = color_arr[1];

                    char_color_list[16] = color_arr[3];
                    char_color_list[17] = color_arr[3];
                    char_color_list[18] = color_arr[3];
                    char_color_list[19] = color_arr[3];
                    char_color_list[20] = color_arr[3];
                    char_color_list[21] = color_arr[3];
                    char_color_list[22] = color_arr[3];
                    char_color_list[23] = color_arr[3];

                    //for (k = 7; k < `RESULT_VGA_STR_SIZE; k = k + 1)
                    //    char_color_list[k] = color_arr[k%4];
                end
                state <= `S3;
            end
            `S3: begin
                if (char_counter == string_size) begin
                    y0 <= y0 + `CHAR_HEIGHT + `KERNING;
                    state <= `CLEAR_1;
                end
                else begin
                    for (i = 0; i < `CHAR_HEIGHT; i = i + 1)
                        char_reg[i] <= alphabet[i][string_reg[char_counter]];

                    color_reg <= char_color_list[char_counter];
                    x_char <= 0;
                    y_char <= 0;
                    pixel_counter <= y0 * `WIDTH + x0;
                    state <= `S4;
                end
            end
            `S4: begin
                if (y_char == `CHAR_HEIGHT) begin
                    frame_buf_we <= 0;
                    char_counter <= char_counter + 1;
                    x0 <= x0 + `CHAR_WIDTH + `KERNING;
                    state <= `S3;
                end
                else begin
                    if (x_char == `CHAR_WIDTH) begin
                        frame_buf_we <= 0;
                        y_char <= y_char + 1;
                        x_char <= 0;
                        pixel_counter <= pixel_counter + `WIDTH - `CHAR_WIDTH;
                    end
                    else begin
                        frame_buf_we <= 1;
                        frame_buf_data_in <= char_reg[y_char][x_char] ? color_reg : 0;
                        frame_buf_addr <= pixel_counter;
                        state <= `S5;
                    end
                end
            end
            `S5: begin
                x_char <= x_char + 1;
                pixel_counter <= pixel_counter + 1;
                state <= `S4;
            end
            `S6: begin
                if (Input_VGA_Begin)
                    state <= `S7;
            end
            `S7: begin
                if (Input_VGA_End)
                    state <= `S0;
            end
            `CLEAR_1: begin
                if (frame_buf_addr < MAX_PIXEL_COUNT-1) begin
                    frame_buf_data_in <= 0;
                    frame_buf_we <= 0;
                    state <= `CLEAR_2;
                end
                else begin
                    frame_buf_we <= 0;
                    state <= `S6;
                end
            end
            `CLEAR_2: begin
                frame_buf_addr <= frame_buf_addr + 1;
                frame_buf_we <= 1;
                state <= `CLEAR_1;
            end
        endcase
    end
endmodule
