`include "Defines.v"

module IF_ID(
    input wire                  clk,
    input wire                  rst,
    
    input wire[`InstAddrBus]    if_pc,
    input wire[`InstBus]        if_inst,

    input wire[5:0]             stall, 

    output reg[`InstAddrBus]    id_pc,
    output reg[`InstBus]        id_inst
);

always @ (posedge clk) 
begin
    if (rst == `Enable)
    begin
        id_pc   <=  `ZeroWord;
        id_inst <=  `ZeroWord;
    end

    else if (stall[1] && !stall[2])
    begin
        id_pc   <=  `ZeroWord;
        id_inst <=  `ZeroWord;
    end

    else if (!stall[1])
    begin
        id_pc   <=  if_pc;
        id_inst <=  if_inst;
    end 
end

endmodule