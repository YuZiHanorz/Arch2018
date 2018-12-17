`include "Defines.v"

module MEM_WB(
    input wire					clk,
	input wire					rst,

	input wire					me_w_enable,
	input wire[`RegAddrBus]		me_w_addr,
	input wire[`RegBus]			me_w_data,

	input wire[5:0]				stall,

	output reg					wb_w_enable,
	output reg[`RegAddrBus]		wb_w_addr,
	output reg[`RegBus]			wb_w_data
);

always @ (posedge clk)
begin
    if (rst)
	begin
		wb_w_enable	<=	`Disable;
		wb_w_addr	<=	`NOPRegAddr;
		wb_w_data	<=	`ZeroWord;
	end

	else if(stall[4] && !stall[5])
	begin
		wb_w_enable	<=	`Disable;
		wb_w_addr	<=	`NOPRegAddr;
		wb_w_data	<=	`ZeroWord;
	end 

    else if(!stall[4])
	begin
        wb_w_enable	<=	me_w_enable;
		wb_w_addr	<=	me_w_addr;
		wb_w_data	<=	me_w_data;
	end
end

endmodule