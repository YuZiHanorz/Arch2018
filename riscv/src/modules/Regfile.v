`include "Defines.v"

module Regfile(
    input wire              clk,
    input wire              rst,

    input wire              w_enable,
    input wire[`RegAddrBus] w_addr,
    input wire[`RegBus]     w_data,

    input wire              r1_enable,
    input wire[`RegAddrBus] r1_addr,
    output reg[`RegBus]     r1_data,

    input wire              r2_enable,
    input wire[`RegAddrBus] r2_addr,
    output reg[`RegBus]     r2_data
);

reg[`RegBus] regs[`RegNum-1 : 0];

initial begin
	regs[0] = 32'h0;
end

always @ (posedge clk) 
begin
    if (rst == `Disable) 
    begin
        if (w_enable == `Enable && w_addr != `RegNumLog'h0) 
            regs[w_addr] <= w_data;
    end
end

always @ (*) 
begin
    if (rst == `Enable) 
        r1_data <= `ZeroWord;

    else if (r1_addr == 5'b00000)
        r1_data <= `ZeroWord;

    else if (r1_enable == `Enable && r1_addr == w_addr && w_enable == `Enable)
        r1_data <= w_data;

    else if (r1_enable == `Enable)
        r1_data <= regs[r1_addr];

    else 
        r1_data <= `ZeroWord;
end


always @ (*) 
begin
    if (rst == `Enable) 
        r2_data <= `ZeroWord;

    else if (r2_addr == 5'b00000)
        r2_data <= `ZeroWord;

    else if (r2_enable == `Enable && r2_addr == w_addr && w_enable == `Enable)
        r2_data <= w_data;

    else if (r2_enable == `Enable)
        r2_data <= regs[r2_addr];

    else 
        r2_data <= `ZeroWord;
end

endmodule