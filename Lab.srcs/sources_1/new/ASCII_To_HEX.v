`timescale 1ns / 1ps

module ASCII_To_HEX
(
    input [7:0] asciiInPacket,
    
    output [3:0] hexOutPacket
);

always @*
begin
    case (asciiInPacket)
        8'h30: hexOutPacket = 4'h0;
        8'h31: hexOutPacket = 4'h1;
        8'h32: hexOutPacket = 4'h2;
        8'h33: hexOutPacket = 4'h3;
        8'h34: hexOutPacket = 4'h4;
        8'h35: hexOutPacket = 4'h5;
        8'h36: hexOutPacket = 4'h6;
        8'h37: hexOutPacket = 4'h7;
        8'h38: hexOutPacket = 4'h8;
        8'h39: hexOutPacket = 4'h9;
        8'h41: hexOutPacket = 4'hA;
        8'h42: hexOutPacket = 4'hB;
        8'h43: hexOutPacket = 4'hC;
        8'h44: hexOutPacket = 4'hD;
        8'h45: hexOutPacket = 4'hE;
        8'h46: hexOutPacket = 4'hF;
        default: hexOutPacket = 4'h0;
    endcase
end

endmodule
