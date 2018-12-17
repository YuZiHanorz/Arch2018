`include "Defines.v"

module EX(
    input wire                  rst,
    
    input wire[`AluOpBus]		aluop_i,
	input wire[`AluSelBus]	    alusel_i,
	input wire[`RegBus]			r1_data_i,
	input wire[`RegBus]			r2_data_i,
	input wire					w_enable_i,
	input wire[`RegAddrBus]		w_addr_i,
	input wire[`InstAddrBus]	pc_i,
    input wire[`RegBus]         offset_i,
	input wire[`InstAddrBus]    link_addr_i,

    output reg 					w_enable_o,
	output reg[`RegAddrBus]		w_addr_o,
	output reg[`RegBus]			w_data_o,

	output reg[`RegBus]			ram_addr_o,
	output wire[`AluOpBus]		aluop_o,
	output wire				    ex_stall_req_o
);

reg[`RegBus] logic_out;
reg[`RegBus] shift_out;
reg[`RegBus] arith_out;
reg[`RegBus] ram_addr_out;

assign ex_stall_req_o = 1'b0;
assign aluop_o = ((aluop_i == `EX_LB_OP) || 
				(aluop_i == `EX_LH_OP) ||
				(aluop_i == `EX_LW_OP) ||
				(aluop_i == `EX_LBU_OP)||
				(aluop_i == `EX_LHU_OP)||
				(aluop_i == `EX_SB_OP) ||
				(aluop_i == `EX_SH_OP) ||
				(aluop_i == `EX_SW_OP) ) ? aluop_i : `EX_NOP_OP;

//Logic
always @ (*)
begin
    if (rst)
    begin
        logic_out = `ZeroWord;
    end
    else begin
        case (aluop_i)

            `EX_OR_OP:
            begin
                logic_out = r1_data_i | r2_data_i;
            end

            `EX_XOR_OP:
			begin
				logic_out =	r1_data_i ^ r2_data_i;
			end

            `EX_AND_OP:
			begin
				logic_out =	r1_data_i & r2_data_i;
			end

            default:
            begin
                logic_out = `ZeroWord;
            end

        endcase
    end
end

//SHIFT
always @ (*)
begin
	if (rst)
    begin
		shift_out = `ZeroWord;
    end 
    else begin
		case (aluop_i)

			`EX_SLL_OP:
			begin
				shift_out =	r1_data_i << r2_data_i[4:0];
			end

			`EX_SRL_OP:
			begin
				shift_out =	r1_data_i  >> r2_data_i[4:0];
			end

			`EX_SRA_OP:
			begin
				shift_out =	({32{r1_data_i[31]}} << (6'd32 - {1'b0,r2_data_i[4:0]})) | (r1_data_i >> r2_data_i[4:0]);
			end

			default:
			begin
				shift_out =	`ZeroWord;
			end

		endcase
	end	
end

//ARITH
always @ (*) 
begin
	if (rst) 
	begin
		arith_out =	`ZeroWord;
	end
	else begin
		case (aluop_i)

			`EX_ADD_OP: 
			begin
				arith_out =	r1_data_i + r2_data_i;
			end
			
		     `EX_SUB_OP:
			begin
				arith_out =	r1_data_i - r2_data_i;
			end

            `EX_SLT_OP:
            begin
                arith_out = $signed(r1_data_i) < $signed(r2_data_i);
            end

            `EX_SLTU_OP:
            begin
                arith_out = r1_data_i < r2_data_i;
            end

			`EX_AUIPC_OP:
			begin
			  	arith_out =	pc_i + offset_i;
			end


			default: 
			begin
				arith_out =	`ZeroWord;
			end
            
		endcase
	end
end

//LD_ST
always @ (*) 
begin
	if(rst) 
	begin
		ram_addr_out = 0;
	end 
	else begin
		ram_addr_out = r1_data_i + offset_i;
	end
end 

always @ (*)
begin
    w_addr_o = w_addr_i;
    w_enable_o = w_enable_i;
    
    case (alusel_i)

        `EX_RES_LOGIC:
        begin
            w_data_o = logic_out;
        end

        `EX_RES_SHIFT:
        begin
            w_data_o = shift_out;
        end

        `EX_RES_ARITH:
		begin
			w_data_o = arith_out;
		end

		`EX_RES_JUMP_BRANCH:
		begin
			w_data_o = link_addr_i;
		end

		`EX_RES_LOAD_STORE:
		begin
			ram_addr_o = ram_addr_out;
		  	w_data_o = 0;
		end
        
        default:
        begin
            w_data_o = `ZeroWord;
        end
    endcase
end

endmodule