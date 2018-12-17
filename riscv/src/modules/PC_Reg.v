`include "Defines.v"

module PC_Reg(
    input wire                  clk,
    input wire                  rst,

    input wire[5:0]			    stall,

    input wire                  branch_flag_i,
    input wire[`InstAddrBus]    branch_addr_i,     

    output reg[`InstAddrBus]    pc_o,
    output reg                  right_one_o
);

reg[`InstAddrBus]   pc;
reg                 right_one;

/*always @ (posedge clk) 
begin
    if (rst == `Enable) 
    begin
        chip_enable <= `Disable;
    end 
    else begin
        chip_enable <= `Enable;
    end
end

always @ (posedge clk) 
begin
    if (chip_enable == `Disable) 
    begin
        pc <= `ZeroWord;
    end 
    else if(!stall[0])
    begin
        if (branch_flag_i)
        begin
            pc <= branch_addr_i;
        end
        else begin
            pc <= pc + 4'h4;
        end
    end
end*/

always @ (posedge clk) 
begin
	if (!rst && branch_flag_i) 
    begin
		pc <= branch_addr_i;
		right_one <= 1;
	end 
    else if (!rst && !stall[0]) 
    begin
		pc <= pc + 4;
		right_one <= 0;
	end
	if (rst) 
    begin
		pc_o      <= 0;
		right_one <= 0;
		pc        <= 4;
	end 
    else if (!stall[0]) 
    begin
		pc_o <= pc;
		right_one_o <= right_one;
	end
end


endmodule