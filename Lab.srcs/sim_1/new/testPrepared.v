`timescale 1ns / 1ps

module testPrepared();

parameter enterCode = 8'h5A;
parameter stopCode = 8'hF0;
parameter rButtonCode = 8'h2D;

parameter clockPeriod = 10;
parameter keyboardClockPeriod = 40;
parameter codeSpacePeriod = 60;

reg clock, keyboardClock, keyboardData;
reg[7:0] scancode;
reg[3:0] i;

wire[7:0] anodes;
wire[7:0] segments;

Main main(.clock(clock), .inp(4'b0000), .button(1'b0), .sortButton(1'b0),
          .resetButton(1'b0), .leftButton(1'b0), .rightButton(1'b0),
          .mask(8'b00000000), .keyboardClock(keyboardClock),
          .keyboardData(keyboardData), .segmentValues(segments), .outMask(anodes));

always #(clockPeriod) clock <= ~clock;

initial
begin
    keyboardClock <= 1;
    keyboardData <= 1;
    scancode  <= 0;
    
    clock <= 0;
    
    @(posedge clock);
    @(posedge clock);
    
    #(2 * clockPeriod) scancode = hexCoder(4'h1);
    pressKey(scancode);
    #(2 * clockPeriod) scancode = enterCode;
    pressKey(scancode);
    #(2 * clockPeriod) scancode = hexCoder(4'hF);
    pressKey(scancode);
    #(2 * clockPeriod) scancode = enterCode;
    pressKey(scancode);
    #(2 * clockPeriod) scancode = rButtonCode;
    pressKey(scancode);
    
    #(2 * clockPeriod)
    $finish;
end

task automatic pressKey
(
    input[7:0] scancode
);
    begin
        fork
            keyboardClockGenerator();
            keyboardDataGenerator(scancode);
        join
        #codeSpacePeriod;
        fork
            keyboardClockGenerator();
            keyboardDataGenerator(stopCode);
        join
//        #codeSpacePeriod;
//        fork
//            keyboardClockGenerator();
//            keyboardDataGenerator(scancode);
//        join
    end
endtask

task automatic keyboardDataGenerator
(
    input[7:0] scancode
);
    begin
        keyboardData <= 0;
        for (i = 0; i < 8; i = i + 1)
        begin
            @(posedge keyboardClock)
            keyboardData <= scancode[i];
        end
        @(posedge keyboardClock)
        keyboardData <= ~^(scancode);
        
        @(posedge keyboardClock)
        keyboardData <= 1;
    end
endtask

task automatic keyboardClockGenerator;
    begin
        #(clockPeriod);
        repeat(22)
        begin
            keyboardClock <= ~keyboardClock;
            #(keyboardClockPeriod);
        end
        keyboardClock <= 1;
    end
endtask

function[7:0] hexCoder;
    input[3:0] number;
    begin
        case(number)
            4'h0: hexCoder = 8'h45;
            4'h1: hexCoder = 8'h16;
            4'h2: hexCoder = 8'h1E;
            4'h3: hexCoder = 8'h26;
            4'h4: hexCoder = 8'h25;
            4'h5: hexCoder = 8'h2E;
            4'h6: hexCoder = 8'h36;
            4'h7: hexCoder = 8'h3D;
            4'h8: hexCoder = 8'h3E;
            4'h9: hexCoder = 8'h46;
            4'hA: hexCoder = 8'h1C;
            4'hB: hexCoder = 8'h32;
            4'hC: hexCoder = 8'h21;
            4'hD: hexCoder = 8'h23;
            4'hE: hexCoder = 8'h24;
            4'hF: hexCoder = 8'h2B;
            default: hexCoder = 0;
        endcase
    end
endfunction

endmodule
