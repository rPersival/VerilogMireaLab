`timescale 1ns / 1ps

module keyboardSymbolDecoder
(
    input clock,
    input keyboardClock,
    input keyboardData,
    
    output isReadyOutput,
    output[3:0] out,
    output[1:0] flags
);

parameter setSignalExpectation = 0;
parameter resetSignalExpectation = 1;
reg state;

wire keyboardIsReadyOutput, keyboardError;
wire[7:0] keyboardOut;

reg releaseFlag;

initial
begin
    state = 0; isReadyOutput = 0;
    releaseFlag = 0;
end

always@ (posedge clock)
begin
    case(state)
        setSignalExcpectation:
        begin
            if (keyboardIsReadyOutput)
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
            if (!keyboardIsReadyOutput)
                state <= setSignalExcpectation;
        end
    endcase
end

packetHandler handler(.clock(clock), .keyboardClock(keyboardClock), .keyboardData(keyboardData), .out(keyboardOut), .isReadyOutput(keyboardIsReadyOutput), .error(keyboardError));
packetDecoder decoder(.scancode(keyboardOut), .out(out), .flags(flags));

endmodule
