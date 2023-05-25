`timescale 1ns / 1ps

module keyboardSymbolDecoder
(
    input clock,
    input keyboardClock,
    input keyboardData,
    
    output reg isReadyOutput,
    output isKeyboardReadyOutput,
    output[3:0] out,
    output[1:0] flags,
    output keyReleasedFlag,
    output rButtonFlagH
);

parameter setSignalExpectation = 0;
parameter resetSignalExpectation = 1;
reg state;

wire isKeyboardReadyOutputH, keyboardError;
wire[7:0] keyboardOut;

reg releaseFlag;

wire rButtonFlag;

initial
begin
    state = 0; isReadyOutput = 0;
    releaseFlag = 0;
end

always@ (posedge clock)
begin
    case(state)
        setSignalExpectation:
        begin
            if (isKeyboardReadyOutputH)
            begin
                if (!keyboardError)
                begin
                    if (keyboardOut == 8'hF0)
                        releaseFlag <= 1;
                    else if (releaseFlag)
                    begin
                        isReadyOutput <= 1;
                        releaseFlag <= 0;
                    end
                end
                state = resetSignalExpectation;
            end
        end
        resetSignalExpectation:
        begin
            isReadyOutput <= 0;
            if (!isKeyboardReadyOutputH)
                state <= setSignalExpectation;
        end
    endcase
end

assign keyReleasedFlag = releaseFlag;
assign rButtonFlagH = rButtonFlag;

assign isKeyboardReadyOutput = isKeyboardReadyOutputH;

packetHandler handler(.clock(clock), .keyboardClock(keyboardClock), .keyboardData(keyboardData),
                    .out(keyboardOut), .isReadyOutput(isKeyboardReadyOutputH), .error(keyboardError));
packetDecoder decoder(.scancode(keyboardOut), .out(out), .flags(flags), .rButtonFlagD(rButtonFlag));

endmodule
