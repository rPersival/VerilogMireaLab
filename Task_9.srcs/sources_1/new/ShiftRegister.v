`timescale 1ns / 1ps

module ShiftRegister(input clock, input[3:0] inp, input button, input[31:0] tempDigits, input isReadyOutput, output[31:0] out);

reg[31:0] bus = 32'h00000000;

always@ (posedge clock)
begin
    if (button == 1)
    
        bus <= {bus[27:0], inp[3:0]};
        
    else if (isReadyOutput == 1)
        bus = tempDigits;
end

assign out = bus;

endmodule
