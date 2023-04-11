`timescale 1ns / 1ps

module ShiftRegister(input clock, input[3:0] inp, input isResetted, input inputButton, input leftButton, input rightButton,
        input[63:0] tempDigits, input isReadyOutput, output[31:0] out, output[63:0] innerBus);

reg[63:0] value = 64'h0000000000000000;
reg[3:0] pos = 4'h8;

always@ (posedge clock)
begin
    if (isResetted == 1)
        begin
            value = 64'h0000000000000000;
            pos = 4'h8;
        end
    if (inputButton == 1 && pos == 'h8 && isReadyOutput != 1)
        value <= {value[59:0], inp[3:0]};
    else if (leftButton == 1 && pos > 'h0)
        pos = pos - 1'h1;
    else if (rightButton == 1 && pos < 'h8)
        pos = pos + 1'h1;
    else if (isReadyOutput == 1)
        value = tempDigits;
end

assign innerBus = value;
assign out = value[(63 - (4 * pos)) -: 32];

endmodule
