`timescale 1ns / 1ps

module ShiftRegister(input clock, input[3:0] inp, input inputButton, input leftButton, input rightButton,
        input[31:0] tempDigits, input isReadyOutput, output[31:0] out, output[3:0] outPos);

reg[63:0] value = 64'h0123456789ABCDEF;
reg[3:0] pos = 4'h8;

always@ (posedge clock)
begin
    if (inputButton == 1 && pos == 'h8)
        value <= {value[59:0], inp[3:0]};
    else if (leftButton == 1 && pos > 'h0)
        pos = pos - 1'h1;
    else if (rightButton == 1 && pos < 'h8)
        pos = pos + 1'h1;
    else if (isReadyOutput == 1)
        value = tempDigits;
end

assign out = value[(63 - (4 * pos)) -: 32];
assign outPos = pos;

endmodule
