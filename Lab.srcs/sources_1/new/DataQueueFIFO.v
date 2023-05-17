`timescale 1ns / 1ps

module DataQueueFIFO #
(
    memorySize = 6,
    dataCellSize = 4
)
(
    input clock,
    input reset,
    input enable,
    
    input readMode,
    input writeMode,
    input[dataCellSize - 1:0] dataInPacket,
    
    output reg[dataCellSize - 1:0] dataOutPacket,
    output reg full,
    output reg empty,
    output reg valid
);

reg[dataCellSize - 1:0] queueMemory [0:memorySize - 1];
reg[$clog2(memorySize) - 1:0] writePointer, writePointerNext, writePointerSuccessor;
reg[$clog2(memorySize) - 1:0] readPointer, readPointerNext, readPointerSuccessor;
reg fullNext, emptyNext;

integer i;
initial
begin
    writePointer <= 0;
    writePointerNext <= 0;
    writePointerSuccessor <= 0;
    
    readPointer <= 0;
    readPointerNext <= 0;
    readPointerSuccessor <= 0;
    
    full <= 0;
    fullNext <= 0;
    empty <= 1;
    emptyNext <= 1;
    
    valid <= 0;
    
    dataOutPacket <= 0;
    
    for(i = 0; i < memorySize; i = i + 1)
    begin
        queueMemory[i] <= {dataCellSize{1'b0}};
    end
end

always@ (posedge clock)
begin
    if (enable && readMode && !empty)
    begin
        dataOutPacket = queueMemory[readPointer];
        valid <= 1;
    end
    else
    begin
        valid <= 0;
    end
end

always@ (posedge clock)
begin
    if (enable && writeMode && !full)
    begin
        queueMemory[writePointer] <= dataInPacket;
    end
end

always@ (posedge clock)
begin
    if (reset)
    begin
        writePointer <= 0;
        readPointer <= 0;
        full <= 0;
        empty <= 1'b1;
    end
    else if (enable)
    begin
        writePointer <= writePointerNext;
        readPointer <= readPointerNext;
        full <= fullNext;
        empty <= emptyNext;
    end
end

always@ *
begin
    writePointerSuccessor = (writePointer + 1) % memorySize;
    readPointerSuccessor = (readPointer + 1) % memorySize;
    
    writePointerNext = writePointer;
    readPointerNext = readPointer;
    fullNext = full;
    emptyNext = empty;
    
    case ({writeMode, readMode})
        2'b01:
        begin
            if (!empty)
            begin
                readPointerNext = readPointerSuccessor;
                fullNext = 0;
                if (readPointerSuccessor == writePointer)
                begin
                    emptyNext = 1;
                end
            end
        end
        
        2'b10:
        begin
            if (!full)
            begin
                writePointerNext = writePointerSuccessor;
                emptyNext = 0;
                if (writePointerSuccessor == readPointer)
                begin
                    fullNext = 1;
                end
            end
        end
        
        2'b11:
        begin
            case ({full, empty})
                2'b10:
                begin
                    readPointerNext = readPointerSuccessor;
                    fullNext = 0;
                    if (readPointerSuccessor == writePointer)
                    begin
                        emptyNext = 1;
                    end
                end
                
                2'b01:
                begin
                    writePointerNext = writePointerSuccessor;
                    emptyNext = 0;
                    if (writePointerSuccessor == readPointer)
                    begin
                        fullNext = 1;
                    end
                end
                
                default:
                begin
                    writePointerNext = writePointerSuccessor;
                    readPointerNext = readPointerSuccessor;
                end
            endcase
        end
    endcase
end

endmodule
