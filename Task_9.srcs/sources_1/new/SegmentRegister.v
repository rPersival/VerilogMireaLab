`timescale 1ns / 1ps

module SegmentRegister
(
 input clock,
 input[2:0] address,
 input[31:0] value,
 output[7:0] segmentValues
);

reg[7:0] tempSegmentReg;

always@ (posedge clock)
begin
     
    case(value[(4 * address + 3)-:4])
        4'h0: tempSegmentReg <= 8'b11000000;
        4'h1: tempSegmentReg <= 8'b11111001;
        4'h2: tempSegmentReg <= 8'b10100100;
        4'h3: tempSegmentReg <= 8'b10110000;
        4'h4: tempSegmentReg <= 8'b10011001;
        4'h5: tempSegmentReg <= 8'b10010010;
        4'h6: tempSegmentReg <= 8'b10000010;
        4'h7: tempSegmentReg <= 8'b11111000;
        4'h8: tempSegmentReg <= 8'b10000000;
        4'h9: tempSegmentReg <= 8'b10010000;
        4'ha: tempSegmentReg <= 8'b10001000;
        4'hb: tempSegmentReg <= 8'b10000011;
        4'hc: tempSegmentReg <= 8'b11000110;
        4'hd: tempSegmentReg <= 8'b10100001;
        4'he: tempSegmentReg <= 8'b10000110;
        4'hf: tempSegmentReg <= 8'b10001110;
    endcase
end

assign segmentValues = tempSegmentReg;

endmodule
