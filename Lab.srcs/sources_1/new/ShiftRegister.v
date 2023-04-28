`timescale 1ns / 1ps

module ShiftRegister(input clock, input[3:0] inp, input[3:0] inpKeyboard, input isResetted, input keyReleasedFlag, input[1:0] inputFlags, input rButtonFlagS, input inputButton, input leftButton, input rightButton,
        input[63:0] tempDigits, input isReadyOutput, input isKeyboardReadyOutput, output[31:0] out, output[63:0] innerBus);

reg[63:0] value = 64'h123456789ABCDEF;
reg[3:0] pos = 4'h8;
reg flagsDelayed = 0;
reg flagsDelayedKey = 0;
reg rButtonFlagDelayed = 0;
reg[3:0] inputBuffer = 4'h0;

always@ (posedge clock)
begin
    if (inputFlags[0] && isKeyboardReadyOutput)
            inputBuffer = inpKeyboard;
    flagsDelayed <= inputFlags[1];
    flagsDelayedKey <= inputFlags[0];
    rButtonFlagDelayed <= rButtonFlagS;
    if (isResetted == 1 || (rButtonFlagS && ~rButtonFlagDelayed) == 1 && keyReleasedFlag == 1)
        begin
            value <= 64'h123456789ABCDEF;
            pos <= 4'h8;
        end
    if (inputButton == 1 && pos == 'h8 && isReadyOutput != 1)
        value <= {value[59:0], inp};
    else if ((inputFlags[1] && ~flagsDelayed) == 1 && keyReleasedFlag == 1 && pos == 'h8 && isReadyOutput != 1)
        value <= {value[59:0], inputBuffer};
    else if (leftButton == 1 && pos > 'h0)
        pos <= pos - 1'h1;
    else if (rightButton == 1 && pos < 'h8)
        pos <= pos + 1'h1;
    else if (isReadyOutput == 1)
        value <= tempDigits;
end

assign innerBus = value;
assign out = value[(63 - (4 * pos)) -: 32];

endmodule
