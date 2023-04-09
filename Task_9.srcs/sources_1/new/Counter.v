`timescale 1ns / 1ps

module Counter #(step = 1, mod = 16, startValue = 0) (input wire clock, input wire isEnabled,
                        input wire isResetted, output reg [$clog2(mod) - 1:0] out = startValue);

always @(posedge clock)
begin 
   if (isEnabled) out = (mod + step + out) % mod;
   if (isResetted) out = startValue;
end

endmodule
