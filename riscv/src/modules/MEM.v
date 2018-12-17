`include "Defines.v"

module MEM(
    input wire              rst,

	
	input wire				w_enable_i,
	input wire[`RegAddrBus]	w_addr_i,
	input wire[`RegBus]		w_data_i,

	input wire[`AluOpBus] 	aluop_i,
	
	input wire              ram_busy_i,
	input wire[`RegBus]		ram_addr_i,
	input wire[`RegBus]		ram_data_i,

	//to ram
	output reg				me_req_o,
	output reg[`RegBus]		ram_addr_o,
	output reg[`RegBus]		ram_data_o,
	output reg				me_stall_req_o,
	output reg[3:0]			wait_time_o,
	output reg				is_load_o,

	//to wb
	output reg 				w_enable_o,
	output reg[`RegAddrBus]	w_addr_o,
	output reg[`RegBus]		w_data_o	
);

reg					doing;

always @ (*)
begin
    if (rst)
    begin
		doing			=	`False;
		ram_addr_o		=	`ZeroWord;
		ram_data_o		=	`ZeroWord;
		me_stall_req_o  =	`False;
		wait_time_o		= 	0;
		is_load_o		=	`False;
 		
		w_enable_o		=	`Disable;
		w_addr_o		=	`NOPRegAddr;
	    w_data_o		=	`ZeroWord;
    end

	if (!aluop_i)
	begin
		me_stall_req_o	=	`False;
		me_req_o		=	`False;
		doing			=	`False;
	  	w_enable_o 		=	w_enable_i;
		w_addr_o		=	w_addr_i;
		w_data_o		=	w_data_i;
	end

	else if (!ram_busy_i && !doing)
	begin	
		doing			=	`True;
		me_req_o		=	`True;
		me_stall_req_o	=	`True;
		ram_addr_o		=	ram_addr_i;

		case (aluop_i)	
			`EX_LB_OP:
			begin
				is_load_o		=	`True;
				wait_time_o		=	2;
			end

			`EX_LBU_OP:
			begin
				is_load_o		=	`True;
				wait_time_o		=	2;
			end
			
			`EX_LH_OP:
			begin
				is_load_o		=	`True;
				wait_time_o		=	4;
			end

			`EX_LHU_OP:
			begin
				is_load_o		=	`True;
				wait_time_o		=	4;
			end

			`EX_LW_OP:
			begin
				is_load_o		=	`True;
				wait_time_o		=	8;
			end
				
			`EX_SB_OP:
			begin
			  	is_load_o		=	`False;
				wait_time_o		=	1;
				ram_data_o 		= 	{w_data_i[7:0], w_data_i[7:0], w_data_i[7:0], w_data_i[7:0]};
			end

			`EX_SH_OP:
			begin
			  	is_load_o		=	`False;
				wait_time_o		=	2;
				ram_data_o 		= 	{w_data_i[15:0], w_data_i[15:0]};	
			end

			`EX_SW_OP:
			begin
			  	is_load_o		=	`False;
				wait_time_o		=	4;
				ram_data_o 		= 	w_data_i;
			end

			default:
			begin
			end

		endcase
	end

	else if (!ram_busy_i && doing)
	begin
	  	doing			=	`False;
		me_stall_req_o	=	`False;
		me_req_o		=	`False;

		w_enable_o		=	w_enable_i;
		w_addr_o		=	w_addr_i;
	    w_data_o		=	`ZeroWord;

		case (aluop_i)	
			`EX_LB_OP:
			begin
				w_data_o	=	{{24{ram_data_i[7]}}, ram_data_i[7:0]};
			end

			`EX_LBU_OP:
			begin
				w_data_o 	= 	{{24{1'b0}}, ram_data_i[7:0]};
			end
			
			`EX_LH_OP:
			begin
				w_data_o 	= 	{{16{ram_data_i[15]}}, ram_data_i[15:0]};
			end

			`EX_LHU_OP:
			begin
				w_data_o 	= 	{{16{1'b0}}, ram_data_i[15:0]};
			end

			`EX_LW_OP:
			begin
				w_data_o 	= 	ram_data_i;
			end
				
			`EX_SB_OP:
			begin
			end

			`EX_SH_OP:
			begin
			end

			`EX_SW_OP:
			begin
			end

			default:
			begin
			end

		endcase 
	end
end

endmodule