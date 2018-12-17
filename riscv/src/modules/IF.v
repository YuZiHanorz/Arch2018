`include "Define.v"

module IF(
    input                       rst,
    input wire[`InstAddrBus]    pc_i,
    input wire                  branch_flag_i,
    input wire[`InstAddrBus]    branch_addr_i,                
    input wire                  ram_busy_i,
    input wire[`InstBus]        ram_inst_i,
    input wire                  me_req_i,
    input wire                  right_one_i,
    //to ram
    output reg[InstAddrBus]     ram_addr_o,
    output reg                  if_req_o,
    //to ID
    output reg[`InstAddrBus]    pc_o,
    output reg[`InstBus]        inst_o,
    output reg                  if_stall_req_o

);

reg     doing;
reg     wait_one;


always @ (*)
begin
    if (right_one_i)
    begin
        wait_one = `False; //revive
    end

    if (rst)
    begin
        doing           =   `False;
        ram_addr_o      =   `ZeroWord;
        pc_o            =   `ZeroWord;
        inst_o          =   `ZeroWord;
        if_stall_req_o  =   `False;
        if_req_o        =   `False;
        wait_one        =   `False;
    end

    else if (branch_flag_i) begin
		pc_o            =   `ZeroWord;
		inst_o          =   `ZeroWord;
	    doing           =   `False;
		if_stall_req_o  =   `False;
        if_req_o        =   `False;
		wait_one     =   `True;
    end

    else if (!wait_one && !ram_busy_i && !doing && !me_req_i)
    begin
        doing           =   `True;
        ram_addr_o      =   pc_i;
        if_stall_req_o  =   `True;
        if_req_o        =   `True;
    end
    
    else if (!wait_one && !ram_busy_i && doing)
    begin
        doing           =   `False;
        pc_o            =   pc_i;
        inst_o          =   ram_inst_i;
        if_stall_req_o  =   `False;
        if_req_o        =   `False;
    end

    else if (!wait_one && ram_busy_i)
    begin
    end

end

endmodule