`timescale 1ns / 1ps

module packetHandler
(
    input clock,
    input keyboardClock,
    input keyboardData,
    
    output[7:0] out,
    output reg isReadyOutput,
    output reg error
);

parameter startBitExpectation = 0,
          dataBitsExpectation = 1,
          parityBitExpectation = 2,
          stopBitExpectation = 3,
          packetEndExpectation = 4;
          
reg[2:0] state;

reg[3:0] counter;
reg[7:0] keyboardDataBuffer;
reg[1:0] keyboardClockSyncronized, keyboardDataSyncronized;

//reg[7:0] testBuffer = 8'h2E;

//assign out = testBuffer;
assign out = keyboardDataBuffer;

initial
begin
    counter = 0;
    isReadyOutput = 0;
    error = 0;
    state = startBitExpectation;
    keyboardDataBuffer = 0;
    keyboardClockSyncronized = 2'b11;
    keyboardDataSyncronized = 2'b11;
//    #500
//testBuffer = 8'h5A;
end

always@ (posedge clock)
begin
    keyboardClockSyncronized <= {keyboardClockSyncronized[0], keyboardClock};
    keyboardDataSyncronized <= {keyboardDataSyncronized[0], keyboardData};
end

always@ (negedge keyboardClockSyncronized[1])
begin
    case (state)
    
        startBitExpectation:
        begin
            isReadyOutput <= 0;
            error = 0;
            state = ~keyboardData ? dataBitsExpectation : packetEndExpectation;
        end
        
        dataBitsExpectation:
        begin
            if (counter == 4'd8)
                state = parityBitExpectation;
            keyboardDataBuffer <= {keyboardDataSyncronized[1], keyboardDataBuffer[7:1]};
        end
        
        parityBitExpectation:
        begin
            if ((~^keyboardDataBuffer) == keyboardDataSyncronized[1])
                state <= stopBitExpectation;
            else
                state <= packetEndExpectation;
        end
        
        stopBitExpectation:
        begin
            if (!keyboardData)
                error <= 1;
            isReadyOutput <= 1;
            state = startBitExpectation;
        end
        
        packetEndExpectation:
        begin
            if (counter == 4'd10)
            begin
                error <= 1;
                isReadyOutput <= 1;
                state = startBitExpectation;
            end
        end
    endcase
end

always@(negedge keyboardClockSyncronized[1])
begin
    counter <= counter + 1;
    if (counter == 4'd10)
        counter <= 0;
end

endmodule
