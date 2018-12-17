`include "Defines.v"

module ID_EX(
    input wire                  clk,
    input wire                  rst,

    input wire[`AluOpBus]		id_aluop,
	input wire[`AluSelBus]	    id_alusel,
	input wire[`RegBus]			id_r1_data,
	input wire[`RegBus]			id_r2_data,
	input wire					id_w_enable,
	input wire[`RegAddrBus]		id_w_addr,
    input wire[`InstAddrBus]    id_pc,
    input wire[`RegBus]         id_offset,
    input wire[`InstAddrBus]    id_link_addr,

    input wire[5:0]             stall,

    output reg[`AluOpBus]		ex_aluop,
	output reg[`AluSelBus]	    ex_alusel,
	output reg[`RegBus]			ex_r1_data,
	output reg[`RegBus]			ex_r2_data,
	output reg					ex_w_enable,
	output reg[`RegAddrBus]		ex_w_addr,
    output reg[`InstAddrBus]    ex_pc,
    output reg[`RegBus]         ex_offset,
    output reg[`InstAddrBus]    ex_link_addr

);

always @ (posedge clk)
begin 
    if (rst) 
    begin
        ex_aluop        <=  `EX_NOP_OP;
        ex_alusel       <=  `EX_RES_NOP;
        ex_r1_data      <=  `ZeroWord;
        ex_r2_data      <=  `ZeroWord;
        ex_w_enable     <=  `Disable;
        ex_w_addr       <=  `NOPRegAddr;
        ex_pc           <=  `ZeroWord;
        ex_offset       <=  `ZeroWord;
        ex_link_addr    <=  `ZeroWord;
    end 
    else if (stall[2] && !stall[3])
    begin
        ex_aluop        <=  `EX_NOP_OP;
        ex_alusel       <=  `EX_RES_NOP;
        ex_r1_data      <=  `ZeroWord;
        ex_r2_data      <=  `ZeroWord;
        ex_w_enable     <=  `Disable;
        ex_w_addr       <=  `NOPRegAddr;
        ex_pc           <=  `ZeroWord;
        ex_offset       <=  `ZeroWord;
        ex_link_addr    <=  `ZeroWord;
    end
    else if (!stall[2])
    begin
        ex_aluop        <=  id_aluop;
        ex_alusel       <=  id_alusel;
        ex_r1_data      <=  id_r1_data;
        ex_r2_data      <=  id_r2_data;
        ex_w_enable     <=  id_w_enable;
        ex_w_addr       <=  id_w_addr;
        ex_pc           <=  id_pc;
        ex_offset       <=  id_offset;
        ex_link_addr    <=  id_link_addr;
    end
end

endmodule


