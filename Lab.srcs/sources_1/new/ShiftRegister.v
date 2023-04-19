`timescale 1ns / 1ps

module ShiftRegister(input clock, input[3:0] inp, input isResetted, input[1:0] inputFlags, input inputButton, input leftButton, input rightButton,
        input[63:0] tempDigits, input isReadyOutput, output[31:0] out, output[63:0] innerBus);

reg[63:0] value = 64'h123456789ABCDEF;
reg[3:0] pos = 4'h8;
reg flagsDelayed = 0;
reg[3:0] inputBuffer = 0;

always@(posedge inputFlags[0])
    inputBuffer = inp;

always@ (posedge clock)
begin
    flagsDelayed <= inputFlags[1];
    if (isResetted == 1)
        begin
            value = 64'h123456789ABCDEF;
            pos = 4'h8;
        end
    if ((inputButton == 1 || (inputFlags[1] && ~flagsDelayed) == 1) && pos == 'h8 && isReadyOutput != 1)
        value <= {value[59:0], inputBuffer};
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
