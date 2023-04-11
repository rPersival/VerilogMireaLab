`timescale 1ns / 1ps

module CountSort(
    input clock,
    input[63:0] value,
    input isReadyInput,
    input isResetted,
    output reg isReadyOutput = 0,
    output wire[63:0] outValue);

reg[2:0] state = 0;
reg[63:0] currentValue = 0, outReg = 0;
reg[63:0] count = 0;

wire[3:0] firstIterator, thirdIterator;
wire[3:0] secondIterator;

Counter #(.step(1), .mod(16)) firstCounter (.clock(clock), .isEnabled(state == 1), .out(firstIterator), .isResetted(isResetted));
Counter #(.step(1), .mod(16), .startValue(1)) secondCounter (.clock(clock), .isEnabled(state == 2), .out(secondIterator), .isResetted(isResetted));
Counter #(.step(-1), .mod(16), .startValue(15)) thirdCounter (.clock(clock), .isEnabled(state == 3), .out(thirdIterator), .isResetted(isResetted));

always @(posedge clock) 
begin
    if (isResetted)
    begin
        state = 0;
        currentValue = 0;
        outReg = 0;
        count = 0;
        isReadyOutput = 0;
    end

    else 
        case (state)
            0: 
            begin 
                if (isReadyInput)
                begin
                    state = 1;
                    currentValue = value;
                end
            end
            
            1:
            begin 
                count[currentValue[4 * firstIterator +: 4] * 4 +:4] = count[currentValue[4 * firstIterator +: 4] * 4 +:4] + 1;

                //count[i]++
                if (firstIterator == 4'd15)
                    state = 2;
            end
            
            2:
            begin 
                count[4 * secondIterator +:4] = count[4 * secondIterator +:4] + count[4 * (secondIterator - 1) +:4];

                //count[i] += count[i - 1]
                if (secondIterator == 4'd15)
                    state = 3;
            end

            3:
            begin
                count[4 * currentValue[4 * thirdIterator +: 4] +:4] = count[4 * currentValue[4 * thirdIterator +: 4] +:4] - 1;

                //count[currentValue[i] - 1]--;
                outReg[4 * count[4 * currentValue[4 * thirdIterator +: 4] +:4] +:4] = currentValue[4 * thirdIterator +:4];

                //out[count[currentValue[i] - 1] - 1] = currentVaue[i]
                if (thirdIterator == 0)
                    state = 4;
            end
            
            4:
            begin 
                isReadyOutput = 1;
            end
        endcase
end

assign outValue = outReg;

endmodule
