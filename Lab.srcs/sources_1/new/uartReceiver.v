`timescale 1ns / 1ps

module uartReceiver #
(
    parameter clockRate = 100_000_000,
    parameter baudRate = 9600
)
(
    input clock,
    input rxData,
    
    output reg[7:0] rxDataPacket,
    output reg rxIsReadyOutput
);

reg[1:0] state;
reg[3:0] bitCounter;
reg[$clog2(clockRate / baudRate):0] baudClock;
reg baudHalfTact;

localparam reset = 0, startBitExpectation = 1, loadBitExpectation = 2, halfTactExpectation = 3;

initial
begin
    state = reset;
    baudHalfTact = 0;
    bitCounter = 0;
    rxDataPacket = 0;
    rxIsReadyOutput = 0;
end

reg[2:0] majorityBuffer = 0;
wire majorityOut = majorityBuffer[0] & majorityBuffer[1] | majorityBuffer[0] & majorityBuffer[2] | majorityBuffer[1] & majorityBuffer[2];

always@ (posedge clock)
begin
    majorityBuffer <= {majorityBuffer[1:0], rxData}; 
end

always@ (posedge clock)
begin
    case(state)

        reset:
        begin
            bitCounter <= 0;
            baudClock <= 0;
            rxDataPacket <= 0;
            rxIsReadyOutput <= 0;
            state = startBitExpectation;
        end

        startBitExpectation:
        begin
            if (~majorityOut)
            begin
                state <= loadBitExpectation;
            end
        end

        loadBitExpectation:
        begin
            if (baudHalfTact)
            begin
                if (bitCounter == 9)
                begin
                    if (rxData)
                    begin
                        rxIsReadyOutput = 1;
                    end
                    state = reset;
                end
                else
                begin
                    if (bitCounter != 0)
                    begin
                        rxDataPacket <= {majorityOut, rxDataPacket[7:1]};
                        bitCounter = bitCounter + 1;
                        state = halfTactExpectation;
                    end
                end
            end
        end
        
        halfTactExpectation:
        begin
            if (baudHalfTact)
            begin
                state <= loadBitExpectation;
            end
        end
        
    endcase
    
if (baudClock == clockRate / baudRate / 2)
begin
    baudHalfTact <= 1;
    baudClock <= 0;
end
else
begin
    baudHalfTact <= 0;
    baudClock = baudClock + 1;
end

end

endmodule
