`timescale 1ns / 1ps

module AnodesMaskRegister
(
 input clock,
 input[2:0] address, 
 input[31:0] value, 
 input[7:0] mask, // 11100000
 output wire[7:0] anodes
);

// assign anodes = mask[address] ? -1 : ~(1 << address); 

reg[7:0] tempAnodes = -2;

always@ (posedge clock)
begin
//    if (value[(4 * address + 3)-:4] ~^ 4'hz)
    tempAnodes <= ~(1 << address) | mask;
//    else
//        tempAnodes = -1;
end

assign anodes = tempAnodes;

endmodule