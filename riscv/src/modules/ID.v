`include "Defines.v"

module ID(
    input wire                  rst,
    
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    input wire[`RegBus]         r1_data_i,
	input wire[`RegBus]	        r2_data_i,

    //forward_ex
    //input wire                  ex_w_enable_i,
    //input wire[`RegBus]         ex_w_data_i,
    //input wire[`RegAddrBus]     ex_w_addr_i,

    //forward_mem
    //input wire                  me_w_enable_i,
    //input wire[`RegBus]         me_w_data_i,
    //input wire[`RegAddrBus]     me_w_addr_i,

    output reg                  r1_enable_o,
    output reg                  r2_enable_o,
    output reg[`RegAddrBus]     r1_addr_o,
	output reg[`RegAddrBus] 	r2_addr_o,

    output reg[`AluOpBus]		aluop_o,
	output reg[`AluSelBus]	    alusel_o,
	output reg[`RegBus]		 	r1_data_o,
	output reg[`RegBus]		 	r2_data_o,

	output reg					w_enable_o,
	output reg[`RegAddrBus]	 	w_addr_o,

	output reg[`InstAddrBus]	pc_o,
	output reg[`RegBus]			offset_o,

	output wire					id_stall_req_o,
	
	output reg[`InstAddrBus]	link_addr_o,
	output reg					branch_flag_o,
	output reg[`InstAddrBus]	branch_addr_o
);

reg[`RegBus] 	imm;
reg 			InstValid;

wire[6:0]		opcode;
wire[4:0]		rd;
wire[2:0]		funct3;
wire[4:0]		rs1;
wire[4:0]		rs2;
wire			funct7;
wire[11:0]		imm_I;
wire[11:0]		imm_S;
wire[31:0]		imm_B;
wire[31:0]	 	imm_U;
wire[31:0]		imm_J;

wire[`InstAddrBus] 	imm_J_plus_pc;
wire[`InstAddrBus] 	imm_B_plus_pc;
wire[`InstAddrBus] 	imm_I_plus_rs1;
wire[`InstAddrBus] 	pc_plus_4;

wire rs1_rs2_eq;
wire rs1_rs2_ne;
wire rs1_rs2_lt;
wire rs1_rs2_ge;
wire rs1_rs2_ltu;
wire rs1_rs2_geu;

assign id_stall_req_o 	= 1'b0;

assign opcode		=	inst_i[6:0];
assign rd			=	inst_i[11:7];
assign funct3		=	inst_i[14:12];
assign rs1			=	inst_i[19:15];
assign rs2			=	inst_i[24:20];
assign funct7		=	inst_i[30];
assign imm_I		=	inst_i[31:20];
assign imm_S		=	{inst_i[31:25], inst_i[11:7]};
assign imm_B		=	{{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8],1'h0};
assign imm_U		=	{inst_i[31:12], 12'h0};
assign imm_J		=	{{12{inst_i[31]}}, inst_i[19:12],inst_i[20], inst_i[30:21],1'h0};

assign imm_J_plus_pc 	= 	imm_J + pc_i;
assign imm_B_plus_pc	= 	imm_B + pc_i;
assign imm_I_plus_rs1 	=  	{{20{imm_I[11]}}, imm_I} + r1_data_o;
assign pc_plus_4		=	pc_i + 4;

assign rs1_rs2_eq 	= 	(r1_data_o == r2_data_o);
assign rs1_rs2_ne	=	(r1_data_o != r2_data_o);
assign rs1_rs2_lt 	= 	($signed(r1_data_o) < $signed(r2_data_o));
assign rs1_rs2_ge	=	($signed(r1_data_o) >= $signed(r2_data_o));
assign rs1_rs2_ltu 	= 	(r1_data_o < r2_data_o);
assign rs1_rs2_geu	=	(r1_data_o >= r2_data_o);


always @ (*) 
begin
    if (rst)
    begin
		pc_o			=	`ZeroWord;
		aluop_o			=	`EX_NOP_OP;
		alusel_o		=	`EX_RES_NOP;
		r1_enable_o		=	`Disable;
		r2_enable_o		=	`Disable;
		r1_addr_o		=	`NOPRegAddr;
		r2_addr_o		=	`NOPRegAddr;
        imm 			=	`ZeroWord;
		w_enable_o		= 	`Disable;
		w_addr_o		= 	`NOPRegAddr;
		InstValid		=	`True;
		link_addr_o		=	`ZeroWord;
		branch_flag_o   =   `False;
		branch_addr_o	=	`ZeroWord;
    end

    else begin
		pc_o			=	pc_i;
        aluop_o			=	`EX_NOP_OP;
		alusel_o		=	`EX_RES_NOP;
		r1_enable_o		=	`Disable;
		r2_enable_o		=	`Disable;
        r1_addr_o		=	`NOPRegAddr;
		r2_addr_o		=	`NOPRegAddr;
		imm				=	`ZeroWord;
		w_enable_o		= 	`Disable;
        w_addr_o		= 	`NOPRegAddr;
		InstValid		=	`False;
		link_addr_o		=	`ZeroWord;
		branch_flag_o   =   `False;
		branch_addr_o	=	`ZeroWord;

        case (opcode)

			`OP_LUI:
			begin
				aluop_o			=	`EX_OR_OP;
				alusel_o		=	`EX_RES_LOGIC;
				r1_enable_o		=	1'b0;
				r2_enable_o		=	1'b0;
				r1_addr_o		=	rs1;
				r2_addr_o		=	rs2;
				imm				=	imm_U;
				w_enable_o		=	`Enable;
				w_addr_o		=	rd;
				InstValid		=	`True;		
			end

			`OP_AUIPC:
			begin
				aluop_o			=	`EX_AUIPC_OP;
				alusel_o		=	`EX_RES_ARITH;
				r1_enable_o		=	1'b0;
				r2_enable_o		=	1'b0;
				r1_addr_o		=	rs1;
				r2_addr_o		=	rs2;
				imm				=	imm_U;
				w_enable_o		=	`Enable;
				w_addr_o		=	rd;
				InstValid		=	`True;

			end

            `OP_OPI:
            begin
                case (funct3)

                    `FUNCT3_ADDI:
					begin
						aluop_o			=	`EX_ADD_OP;
						alusel_o		=	`EX_RES_ARITH;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;
					end

                    `FUNCT3_SLTI:
					begin
						aluop_o			=	`EX_SLT_OP;
						alusel_o		=	`EX_RES_ARITH;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;
					end

                    `FUNCT3_SLTIU:
					begin
						aluop_o			=	`EX_SLTU_OP;
						alusel_o		=	`EX_RES_ARITH;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};	
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;
					end

                    `FUNCT3_ORI:
                    begin 
                        aluop_o     =   `EX_OR_OP;
                        alusel_o    =   `EX_RES_LOGIC;
                        r1_enable_o =   `Enable;
                        r2_enable_o =   `Disable;
                        r1_addr_o   =   rs1;
						r2_addr_o	=	rs2;
                        imm         =   {20'h0, imm_I};
                        w_enable_o  =   `Enable;
                        w_addr_o    =   rd;
                        InstValid   =   `True;
                    end
                    
                    `FUNCT3_XORI:
					begin
						aluop_o			=	`EX_XOR_OP;
						alusel_o		=	`EX_RES_LOGIC;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{20'h0, imm_I};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;
					end

                    `FUNCT3_ANDI:
					begin
						aluop_o			=	`EX_AND_OP;
						alusel_o		=	`EX_RES_LOGIC;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{20'h0, imm_I};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;
					end

                    `FUNCT3_SLLI:
					begin
						aluop_o			=	`EX_SLL_OP;
						alusel_o		=	`EX_RES_SHIFT;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{27'h0, rs2};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;
					end

                    `FUNCT3_SRLI_SRAI:
					begin
						case (funct7)

							`FUNCT7_SRLI:
							begin
								aluop_o		=	`EX_SRL_OP;
								alusel_o	=	`EX_RES_SHIFT;
								r1_enable_o	=	1'b1;
								r2_enable_o	=	1'b0;
								r1_addr_o	=	rs1;
								r2_addr_o	=	rs2;
								imm			=	{27'h0, rs2};
								w_enable_o	=	`Enable;
								w_addr_o	=	rd;
								InstValid	=	`True;
							end

							`FUNCT7_SRAI:
							begin
								aluop_o		=	`EX_SRA_OP;
								alusel_o	=	`EX_RES_SHIFT;
								r1_enable_o	=	1'b1;
								r2_enable_o	=	1'b0;
								r1_addr_o	=	rs1;
								r2_addr_o	=	rs2;
								imm			=	{27'h0, rs2};
								w_enable_o	=	`Enable;
								w_addr_o	=	rd;
								InstValid	=	`True;
							end

						 	default:
							begin
							end

						endcase
					end

                    default:
                    begin
                    end

                endcase
            end

            `OP_OP:
            begin
                case (funct3)

                    `FUNCT3_ADD_SUB:
				    begin
						case (funct7)

							`FUNCT7_ADD:
							begin
								aluop_o		=	`EX_ADD_OP;
								alusel_o	=	`EX_RES_ARITH;
								r1_enable_o	=	1'b1;
								r2_enable_o	=	1'b1;
								r1_addr_o	=	rs1;
								r2_addr_o	=	rs2;
								imm			=	`ZeroWord;
								w_enable_o	=	`Enable;
								w_addr_o	=	rd;
								InstValid	=	`True;
							end

							`FUNCT7_SUB:
							begin
								aluop_o		=	`EX_SUB_OP;
								alusel_o	=	`EX_RES_ARITH;
								r1_enable_o	=	1'b1;
								r2_enable_o	=	1'b1;
								r1_addr_o	=	rs1;
								r2_addr_o	=	rs2;
								imm			=	`ZeroWord;
								w_enable_o	=	`Enable;
								w_addr_o	=	rd;
								InstValid	=	`True;
							end

							default:
							begin
							end

						endcase
					end

                    `FUNCT3_SLL:
					begin
						aluop_o		=	`EX_SLL_OP;
						alusel_o	=	`EX_RES_SHIFT;
						r1_enable_o	=	1'b1;
						r2_enable_o	=	1'b1;
						r1_addr_o	=	rs1;
						r2_addr_o	=	rs2;
						imm			=	`ZeroWord;
						w_enable_o	=	`Enable;
						w_addr_o	=	rd;
						InstValid	=	`True;
					end

                    `FUNCT3_SLT:
					begin
						aluop_o		=	`EX_SLT_OP;
						alusel_o	=	`EX_RES_ARITH;
						r1_enable_o	=	1'b1;
						r2_enable_o	=	1'b1;
						r1_addr_o	=	rs1;
						r2_addr_o	=	rs2;
						imm			=	`ZeroWord;
						w_enable_o	=	`Enable;
						w_addr_o	=	rd;
						InstValid	=	`True;
					end

                    `FUNCT3_SLTU:
					begin
						aluop_o		=	`EX_SLTU_OP;
						alusel_o	=	`EX_RES_ARITH;
						r1_enable_o	=	1'b1;
						r2_enable_o	=	1'b1;
						r1_addr_o	=	rs1;
						r2_addr_o	=	rs2;
						imm			=	`ZeroWord;
						w_enable_o	=	`Enable;
						w_addr_o	=	rd;
						InstValid	=	`True;
					end

                    `FUNCT3_XOR:
					begin
						aluop_o		=	`EX_XOR_OP;
						alusel_o	=	`EX_RES_LOGIC;
						r1_enable_o	=	1'b1;
						r2_enable_o	=	1'b1;
						r1_addr_o	=	rs1;
						r2_addr_o	=	rs2;
						imm			=	`ZeroWord;
						w_enable_o	=	`Enable;
						w_addr_o	=	rd;
						InstValid	=	`True;
					end

                    `FUNCT3_SRL_SRA:
                    begin
                        case (funct7)

                            `FUNCT7_SRL:
                            begin
                                aluop_o		=	`EX_SRL_OP;
                                alusel_o	=	`EX_RES_SHIFT;
                                r1_enable_o	=	1'b1;
                                r2_enable_o	=	1'b1;
                                r1_addr_o	=	rs1;
                                r2_addr_o	=	rs2;
                                imm			=	`ZeroWord;
                                w_enable_o	=	`Enable;
                                w_addr_o	=	rd;
                                InstValid	=	`True;
                            end
    
                            `FUNCT7_SRA:
                            begin
                                aluop_o		=	`EX_SRA_OP;
                                alusel_o	=	`EX_RES_SHIFT;
                                r1_enable_o	=	1'b1;
                                r2_enable_o	=	1'b1;
                                r1_addr_o	=	rs1;
                                r2_addr_o	=	rs2;
                                imm			=	`ZeroWord;
                                w_enable_o	=	`Enable;
                                w_addr_o	=	rd;
                                InstValid	=	`True;
                            end

                            default:
                            begin
                            end

                        endcase
                    end

                    `FUNCT3_OR:
					begin
						aluop_o		=	`EX_OR_OP;
						alusel_o	=	`EX_RES_LOGIC;
						r1_enable_o	=	1'b1;
						r2_enable_o	=	1'b1;
						r1_addr_o	=	rs1;
						r2_addr_o	=	rs2;
						imm			=	`ZeroWord;
						w_enable_o	=	`Enable;
						w_addr_o	=	rd;
						InstValid	=	`True;
					end

					`FUNCT3_AND:
					begin
						aluop_o		=	`EX_AND_OP;
						alusel_o	=	`EX_RES_LOGIC;
						r1_enable_o	=	1'b1;
						r2_enable_o	=	1'b1;
						r1_addr_o	=	rs1;
						r2_addr_o	=	rs2;
						imm			=	`ZeroWord;
						w_enable_o	=	`Enable;
						w_addr_o	=	rd;
						InstValid	=	`True;
					end

                    default:
                    begin
                    end

                endcase
            end

			`OP_JAL:
			begin
				aluop_o			=	`EX_JAL_OP;
				alusel_o		=	`EX_RES_JUMP_BRANCH;
				r1_enable_o		=	1'b0;
				r2_enable_o		=	1'b0;
				r1_addr_o		=	rs1;
				r2_addr_o		=	rs2;
				imm				=	imm_J;
				w_enable_o		=	`Enable;
				w_addr_o		=	rd;
				InstValid		=	`True;
				link_addr_o		=	pc_plus_4;
				branch_flag_o	=	`True;
				branch_addr_o	=	imm_J_plus_pc;	
			end

			`OP_JALR:
			begin
				aluop_o			=	`EX_JALR_OP;
				alusel_o		=	`EX_RES_JUMP_BRANCH;
				r1_enable_o		=	1'b1;
				r2_enable_o		=	1'b0;
				r1_addr_o		=	rs1;
				r2_addr_o		=	rs2;
				imm				=	{{20{imm_I[11]}}, imm_I};
				w_enable_o		=	`Enable;
				w_addr_o		=	rd;
				InstValid		=	`True;
				link_addr_o		=	pc_plus_4;
				branch_flag_o	=	`True;
				branch_addr_o	=	imm_I_plus_rs1;
			end

			`OP_BRANCH:
			begin
				case (funct3)
					
					`FUNCT3_BEQ:
					begin
						aluop_o			=	`EX_BEQ_OP;
						alusel_o		=	`EX_RES_NOP;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	imm_B;
						w_enable_o		=	`Disable;
						w_addr_o		=	`ZeroWord;
						InstValid		=	`True;
						if (rs1_rs2_eq)
						begin
							branch_flag_o 	=	`True;
							branch_addr_o	=	imm_B_plus_pc;
						end
					end

					`FUNCT3_BNE:
					begin
						aluop_o			=	`EX_BNE_OP;
						alusel_o		=	`EX_RES_NOP;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	imm_B;
						w_enable_o		=	`Disable;
						w_addr_o		=	`ZeroWord;
						InstValid		=	`True;
						if (rs1_rs2_ne)
						begin
							branch_flag_o 	=	`True;
							branch_addr_o	=	imm_B_plus_pc;
						end
					end

					`FUNCT3_BLT:
					begin
						aluop_o			=	`EX_BLT_OP;
						alusel_o		=	`EX_RES_NOP;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	imm_B;
						w_enable_o		=	`Disable;
						w_addr_o		=	`ZeroWord;
						InstValid		=	`True;
						if (rs1_rs2_lt)
						begin
							branch_flag_o 	=	`True;
							branch_addr_o	=	imm_B_plus_pc;
						end
					end

					`FUNCT3_BGE:
					begin
						aluop_o			=	`EX_BGE_OP;
						alusel_o		=	`EX_RES_NOP;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	imm_B;
						w_enable_o		=	`Disable;
						w_addr_o		=	`ZeroWord;
						InstValid		=	`True;
						if (rs1_rs2_ge)
						begin
							branch_flag_o 	=	`True;
							branch_addr_o	=	imm_B_plus_pc;
						end
					end

					`FUNCT3_BLTU:
					begin
						aluop_o			=	`EX_BLTU_OP;
						alusel_o		=	`EX_RES_NOP;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	imm_B;
						w_enable_o		=	`Disable;
						w_addr_o		=	`ZeroWord;
						InstValid		=	`True;
						if (rs1_rs2_ltu)
						begin
							branch_flag_o 	=	`True;
							branch_addr_o	=	imm_B_plus_pc;
						end
					end

					`FUNCT3_BGEU:
					begin
						aluop_o			=	`EX_BGEU_OP;
						alusel_o		=	`EX_RES_NOP;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	imm_B;
						w_enable_o		=	`Disable;
						w_addr_o		=	`ZeroWord;
						InstValid		=	`True;
						if (rs1_rs2_geu)
						begin
							branch_flag_o 	=	`True;
							branch_addr_o	=	imm_B_plus_pc;
						end
					end

					default:
					begin
					end

				endcase
			end

			`OP_LOAD:
			begin
				case (funct3)

					`FUNCT3_LB:
					begin
						aluop_o			=	`EX_LB_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;

					end 
					
					`FUNCT3_LH:
					begin
						aluop_o			=	`EX_LH_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;

					end

					`FUNCT3_LW:
					begin
						aluop_o			=	`EX_LW_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;

					end

					`FUNCT3_LBU:
					begin
						aluop_o			=	`EX_LBU_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;

					end

					`FUNCT3_LHU:
					begin
						aluop_o			=	`EX_LHU_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b0;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_I[11]}}, imm_I[11: 0]};
						w_enable_o		=	`Enable;
						w_addr_o		=	rd;
						InstValid		=	`True;
					end

					default:
					begin
					end

				endcase
			end

			`OP_STORE:
			begin
				case (funct3)
				
				  	`FUNCT3_SB: 
					begin
						aluop_o			=	`EX_SB_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_S[11]}}, imm_S[11: 0]};
						w_enable_o		=	`Disable;
						w_addr_o		=	rd;
						InstValid		=	`True;

					end

					`FUNCT3_SH:
					begin
						aluop_o			=	`EX_SH_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_S[11]}}, imm_S[11: 0]};
						w_enable_o		=	`Disable;
						w_addr_o		=	rd;
						InstValid		=	`True;

					end

					`FUNCT3_SW:
					begin
						aluop_o			=	`EX_SW_OP;
						alusel_o		=	`EX_RES_LOAD_STORE;
						r1_enable_o		=	1'b1;
						r2_enable_o		=	1'b1;
						r1_addr_o		=	rs1;
						r2_addr_o		=	rs2;
						imm				=	{{20{imm_S[11]}}, imm_S[11: 0]};
						w_enable_o		=	`Disable;
						w_addr_o		=	rd;
						InstValid		=	`True;

					end

				  	default:
					begin
					end
				endcase
			end

            default:
			begin
			end

		endcase
    end
end

always @ (*) 
begin
    if (rst)
    begin
        r1_data_o = `ZeroWord;
    end
    //else if (r1_enable_o && ex_w_enable_i && ex_w_addr_i == r1_addr_o && r1_addr_o != `NOPRegAddr)
    //begin 
        //r1_data_o = ex_w_data_i;
    //end 
    //else if (r1_enable_o && me_w_enable_i && me_w_addr_i == r1_addr_o && r1_addr_o != `NOPRegAddr)
    //begin
        //r1_data_o = me_w_data_i;
    //end
    else if (r1_enable_o)
    begin
        r1_data_o = r1_data_i;
    end
    else if (!r1_enable_o)
    begin
        r1_data_o = imm;
    end
    else begin
        r1_data_o = `ZeroWord;
    end
end

always @ (*) 
begin
    if (rst)
    begin
        r2_data_o = `ZeroWord;
    end
    //else if (r2_enable_o && ex_w_enable_i && ex_w_addr_i == r2_addr_o && r2_addr_o != `NOPRegAddr)
    //begin 
        //r2_data_o = ex_w_data_i;
    //end 
    //else if (r2_enable_o && me_w_enable_i && me_w_addr_i == r2_addr_o && r2_addr_o != `NOPRegAddr)
    //begin
       //r2_data_o = me_w_data_i;
    //end
    else if (r2_enable_o)
    begin
        r2_data_o = r2_data_i;
    end
    else if (!r2_enable_o)
    begin
        r2_data_o = imm;
    end
    else begin
        r2_data_o = `ZeroWord;
    end
end

always @(*)
begin
	if (rst)
	begin
		offset_o = `ZeroWord;
	end
	else begin
		offset_o = imm;
	end
end

endmodule
