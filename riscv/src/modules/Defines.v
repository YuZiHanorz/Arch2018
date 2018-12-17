`ifndef _Def
`define _Def

`define Enable          1'b1
`define Disable         1'b0
`define ZeroWord        32'h00000000
`define AluOpBus        7:0
`define AluSelBus       2:0
`define True            1'b1
`define False           1'b0

// opcode related
`define OP_LUI      		7'b0110111
`define OP_AUIPC    		7'b0010111
`define OP_JAL      		7'b1101111
`define OP_JALR     		7'b1100111
`define OP_BRANCH   		7'b1100011
`define OP_LOAD     		7'b0000011
`define OP_STORE    		7'b0100011
`define OP_OPI				7'b0010011
`define OP_OP       		7'b0110011
`define OP_MISC_MEM 		7'b0001111

// funct3
// JALR
`define FUNCT3_JALR		 	3'b000
// BRANCH
`define FUNCT3_BEQ  		3'b000
`define FUNCT3_BNE  		3'b001
`define FUNCT3_BLT  		3'b100
`define FUNCT3_BGE  		3'b101
`define FUNCT3_BLTU 		3'b110
`define FUNCT3_BGEU 		3'b111
// LOAD
`define FUNCT3_LB   		3'b000
`define FUNCT3_LH   		3'b001
`define FUNCT3_LW   		3'b010
`define FUNCT3_LBU  		3'b100
`define FUNCT3_LHU  		3'b101
// STORE
`define FUNCT3_SB   		3'b000
`define FUNCT3_SH   		3'b001
`define FUNCT3_SW   		3'b010
// OP_OPI
`define FUNCT3_ADDI     	3'b000
`define FUNCT3_SLTI     	3'b010
`define FUNCT3_SLTIU    	3'b011
`define FUNCT3_XORI     	3'b100
`define FUNCT3_ORI      	3'b110
`define FUNCT3_ANDI     	3'b111
`define FUNCT3_SLLI     	3'b001
`define FUNCT3_SRLI_SRAI	3'b101
// OP_OP
`define FUNCT3_ADD_SUB		3'b000
`define FUNCT3_SLL    		3'b001
`define FUNCT3_SLT    		3'b010
`define FUNCT3_SLTU   		3'b011
`define FUNCT3_XOR    		3'b100
`define FUNCT3_SRL_SRA		3'b101
`define FUNCT3_OR     		3'b110
`define FUNCT3_AND    		3'b111
// MISC-MEM
`define FUNCT3_FENCE  		3'b000
`define FUNCT3_FENCEI 		3'b001

// funct7
`define FUNCT7_SLLI			1'b0
// SRLI_SRAI
`define FUNCT7_SRLI 		1'b0
`define FUNCT7_SRAI 		1'b1
// ADD_SUB
`define FUNCT7_ADD  		1'b0
`define FUNCT7_SUB  		1'b1
`define FUNCT7_SLL  		1'b0
`define FUNCT7_SLT  		1'b0
`define FUNCT7_SLTU 		1'b0
`define FUNCT7_XOR  		1'b0
// SRL_SRA
`define FUNCT7_SRL			1'b0
`define FUNCT7_SRA			1'b1
`define FUNCT7_OR 			1'b0
`define FUNCT7_AND			1'b0

`define EX_NOP_OP       0
`define EX_AND_OP       1
`define EX_OR_OP        2
`define EX_XOR_OP       3

`define EX_SLL_OP       4
`define EX_SRL_OP       5
`define EX_SRA_OP       6

`define EX_ADD_OP       7
`define EX_SLT_OP       8
`define EX_SLTU_OP      9
`define EX_SUB_OP       10

`define EX_JAL_OP       11
`define EX_JALR_OP      12
`define EX_BEQ_OP       13
`define EX_BNE_OP       14
`define EX_BLT_OP       15
`define EX_BGE_OP       16
`define EX_BLTU_OP      17
`define EX_BGEU_OP      18

`define EX_LB_OP        19
`define EX_LH_OP        20
`define EX_LW_OP        21
`define EX_LBU_OP       22
`define EX_LHU_OP       23

`define EX_SB_OP        24
`define EX_SH_OP        25
`define EX_SW_OP        26

`define EX_AUIPC_OP     27

`define EX_RES_NOP          3'b000
`define EX_RES_LOGIC        3'b001
`define EX_RES_SHIFT        3'b010
`define EX_RES_ARITH	    3'b011
`define EX_RES_JUMP_BRANCH  3'b100
`define	EX_RES_LOAD_STORE	3'b101

`define InstAddrBus     31:0
`define InstBus         31:0
`define RegAddrBus      4:0
`define RegBus          31:0

`define InstMemNum      131071
`define InstMemNumLog   17
`define RegNum          32
`define RegNumLog       5

`define RegWidth        32
`define DoubleRegWidth  64
`define DoubleRegBus    63:0
`define NOPRegAddr      5'b00000

`endif