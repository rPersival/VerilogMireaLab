`timescale 1ns / 1ps

module uartReceiverManager #
(
    clockRate = 100_000_000,
    baudRate = 9600,
    inputDataDimension = 4
)
(
    input clock,
    input reset,
    input rxManagerData,
    
    output reg[inputDataDimension * 4 - 1:0] out,
    output reg rxIsReadyManagerOutput
);

wire uartReceiverIsReadyOutput;
wire[7:0] uartReceiverDataPacket;

localparam uartReceiverDataSize = 8;
uartReceiver #(.clockRate(clockRate), .baudRate(baudRate)) receiver
(
    .clock(clock),
    .rxData(rxManagerData),
    
    .rxDataPacket(uartReceiverDataPacket),
    .rxIsReadyOutput(uartReceiverIsReadyOutput)
);

localparam queueMemorySize = 6;
localparam queueDataCellSize = uartReceiverDataSize;

wire queueWriteMode;
assign queueWriteMode = uartReceiverIsReadyOutput;
wire[queueDataCellSize - 1:0] queueDataPacketIn;
assign queueDataPacketIn = uartReceiverDataPacket;

reg queueReadMode;
wire[queueDataCellSize - 1:0] queueDataPacketOut;

wire queueEmpty;
wire queueFull;
wire queueValid;

DataQueueFIFO #(.memorySize(queueMemorySize), .dataCellSize(queueDataCellSize)) dataQueue
(
    .clock(clock),
    .reset(reset),
    .enable(1'b1),
    
    .readMode(queueReadMode),
    .writeMode(queueWriteMode),
    .dataInPacket(queueDataPacketIn),
    
    .dataOutPacket(queueDataPacketOut),
    .full(queueFull),
    .empty(queueEmpty),
    .valid(queueValid)
);

localparam asciiSize = 8;
localparam hexSize = 4;
wire[asciiSize - 1:0] asciiInPacket = queueDataPacketOut;
wire[hexSize - 1:0] hexOutPacket;
ASCII_To_HEX a1(asciiInPacket, hexOutPacket);

localparam CR = 8'h0D;

always@ (posedge clock)
begin
    if (reset)
    begin
        rxIsReadyManagerOutput <= 0;
        out <= 0;
        queueReadMode <= 1;
    end
    else
    begin
        if (queueValid)
        begin
            if (queueDataPacketOut == CR)
            begin
                rxIsReadyManagerOutput <= 1;
            end
            else
            begin
                out <= {out[inputDataDimension * 4 - 5:0], hexOutPacket};
            end
        end
        else
        begin
            rxIsReadyManagerOutput <= 0;
        end
    end
end

initial
begin
    queueReadMode <= 1;
    out <= 0;
    rxIsReadyManagerOutput <= 0;
end

endmodule
