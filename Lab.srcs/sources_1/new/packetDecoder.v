`timescale 1ns / 1ps

module packetDecoder
(
    input[7:0] scancode,
    output reg[3:0] out,
    output reg[1:0] flags
);

reg[7:0] numberScancodes [0:15];
parameter[7:0] enterScancode = 8'h5A;
parameter numberFlag = 0, enterFlag = 1;

initial
begin
    numberScancodes[0] = 8'h45;
    numberScancodes[1] = 8'h16;
    numberScancodes[2] = 8'h1E;
    numberScancodes[3] = 8'h26;
    numberScancodes[4] = 8'h25;
    numberScancodes[5] = 8'h2E;
    numberScancodes[6] = 8'h36;
    numberScancodes[7] = 8'h3D;
    numberScancodes[8] = 8'h3E;
    numberScancodes[9] = 8'h46;
    numberScancodes[10] = 8'h1C;
    numberScancodes[11] = 8'h32;
    numberScancodes[12] = 8'h21;
    numberScancodes[13] = 8'h23;
    numberScancodes[14] = 8'h24;
    numberScancodes[15] = 8'h2B;

    out = 0;
    flags = 0;
end

always@ (scancode)
begin
    case (scancode)
        numberScancodes[0] : out = 4'h0;
        numberScancodes[1] : out = 4'h1;
        numberScancodes[2] : out = 4'h2;
        numberScancodes[3] : out = 4'h3;
        numberScancodes[4] : out = 4'h4;
        numberScancodes[5] : out = 4'h5;
        numberScancodes[6] : out = 4'h6;
        numberScancodes[7] : out = 4'h7;
        numberScancodes[8] : out = 4'h8;
        numberScancodes[9] : out = 4'h9;
        numberScancodes[10]: out = 4'hA;
        numberScancodes[11]: out = 4'hB;
        numberScancodes[12]: out = 4'hC;
        numberScancodes[13]: out = 4'hD;
        numberScancodes[14]: out = 4'hE;
        numberScancodes[15]: out = 4'hF;   
        
        enterScancode: out = 0;
        
        default: out = 0;
    endcase
end      

always@(scancode)
begin
    case(scancode)
        numberScancodes[0], numberScancodes[1], numberScancodes[2], numberScancodes[3],
        numberScancodes[4], numberScancodes[5], numberScancodes[6], numberScancodes[7],
        numberScancodes[8], numberScancodes[9], numberScancodes[10], numberScancodes[11],
        numberScancodes[12], numberScancodes[13], numberScancodes[14], numberScancodes[15]:
            flags <= 1 << numberFlag;
        enterScancode:
            flags <= 1 << enterFlag;
        default:
            flags <= 0;
    endcase
end

endmodule
