`include "Defines.v"

module CPU(
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,

    input wire[7:0]             din,

    output wire[`InstAddrBus]   addr,
    output wire[7:0]            dout,
    output wire                 wr

   // output wire[`RegBus] rom_addr_o,
    //output wire          rom_ce_o
);

//PC -> IF
wire                right_one;
wire[`InstAddrBus]	if_pc_i;
wire[`InstAddrBus]	if_pc_o;
wire[`InstAddrBus]  if_inst_o;

//IF_ID -> ID
wire[`InstAddrBus]  id_pc_i;
wire[`InstBus]		id_inst_i;

//ID -> ID_EX
wire[`InstAddrBus]	id_pc_o;
wire[`RegBus]		id_offset_o;
wire[`AluOpBus]     id_aluop_o;
wire[`AluSelBus]    id_alusel_o;
wire[`RegBus]       id_r1_data_o;
wire[`RegBus]       id_r2_data_o;
wire                id_w_enable_o;
wire[`RegAddrBus]   id_w_addr_o;
wire[`InstAddrBus]  id_link_addr_o;

//ID -> Regfile
wire				id_r1_enable_o;
wire				id_r2_enable_o;
wire[`RegAddrBus]	id_r1_addr_o;
wire[`RegAddrBus]	id_r2_addr_o;

//Regfile -> ID
wire[`RegBus]		id_r1_data_i;
wire[`RegBus]		id_r2_data_i;

//ID_EX -> EX
wire[`AluOpBus]     ex_aluop_i;
wire[`AluSelBus]    ex_alusel_i;
wire[`RegBus]       ex_r1_data_i;
wire[`RegBus]       ex_r2_data_i;
wire                ex_w_enable_i;
wire[`RegAddrBus]   ex_w_addr_i;
wire[`InstAddrBus]	ex_pc_i;
wire[`RegBus]		ex_offset_i;
wire[`InstAddrBus]  ex_link_addr_i;

//EX -> EX_MEM
wire                ex_w_enable_o;
wire[`RegAddrBus]   ex_w_addr_o;
wire[`RegBus]       ex_w_data_o;
wire[`RegBus]       ex_ram_addr_o;
wire[`AluOpBus]     ex_aluop_o;

//EX_MEM -> MEM
wire                me_w_enable_i;
wire[`RegAddrBus]   me_w_addr_i;
wire[`RegBus]       me_w_data_i;
wire[`AluOpBus]     me_aluop_i;
wire[`RegBus]       me_ram_addr_i;

//MEM -> MEM_WB
wire                me_w_enable_o;
wire[`RegAddrBus]   me_w_addr_o;
wire[`RegBus]       me_w_data_o;

//MEM_WB -> WB
wire                wb_w_enable_i;
wire[`RegAddrBus]   wb_w_addr_i;
wire[`RegBus]       wb_w_data_i;

//Ctrl
wire[5:0]			stall;
wire 				stall_req_from_if;
wire 				stall_req_from_id;
wire 				stall_req_from_ex;
wire 				stall_req_from_me;

// ID -> PC_reg
wire                branch_flag;
wire[`InstAddrBus]  branch_addr;

//ram_ctrl
wire                ram_busy;
//ram_ctrl <-> if
wire                if_addr;
wire                if_req;
wire[`RegBus]       if_inst;

//ram_ctrl_me <-> me
wire[`InstAddrBus]  me_addr;
wire[`RegBus]       me_to_ram_data;
wire                me_req;
wire                is_load;
wire[3:0]           wait_time; 
wire[`RegBus]       ram_to_me_data;

//assign rom_addr_o = pc;

Ctrl ctrl0(
    .rst(rst),
    .stall_req_from_if(stall_req_from_if),
    .stall_req_from_id(stall_req_from_id),
    .stall_req_from_ex(stall_req_from_ex),
    .stall_req_from_me(stall_req_from_me),
    
    .stall(stall)
);

Ram_Ctrl ram_ctrl0(
    .clk(clk),
    .rst(rst),

    .if_addr_i(if_addr),
    .if_req_i(if_req),

    .me_addr_i(me_addr),
    .me_data_i(me_to_ram_data),
    .me_req_i(me_req),

    .is_load_i(is_load),
    .wait_time_i(wait_time),
    
    .din(din),
    .ram_busy_o(ram_busy),
    .if_inst_o(if_inst),
    .me_data_o(ram_to_me_data),
    .wr_o(wr),
    .dout(dout),
    .addr_o(addr)
);

PC_Reg pc_reg0(
    .clk(clk),
    .rst(rst),
    .stall(stall),

    .branch_flag_i(branch_flag),
    .branch_addr_i(branch_addr),

    .pc_o(pc),
    .right_one_o(right_one)
);

IF if0(
    .rst(rst),
    .pc_i(if_pc_i),
    .branch_flag_i(branch_flag),
    .branch_addr_i(branch_addr),
    .ram_busy_i(ram_busy),
    .ram_inst_i(if_inst),
    .me_req_i(me_req),
    .right_one_i(right_one),

    .ram_addr_o(if_addr),
    .if_req_o(if_req),

    .pc_o(if_pc_o),
    .inst_o(if_inst_o),
    .if_stall_req_o(stall_req_from_if)
);

IF_ID if_id0(

    //input
    .clk(clk),
    .rst(rst),

    .if_pc(if_pc_o),
    .if_inst(if_inst_o),

    .stall(stall),
    .branch_flag_i(branch_flag),

    //output
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

ID id0(
    
    //input
    .rst(rst),

    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    .r1_data_i(id_r1_data_i),
    .r2_data_i(id_r2_data_i),

    //.ex_w_enable_i(ex_w_enable_o),
    //.ex_w_addr_i(ex_w_addr_o),
    //.ex_w_data_i(ex_w_data_o),

    //.me_w_enable_i(me_w_enable_o),
    //.me_w_addr_i(me_w_addr_o),
    //.me_w_data_i(me_w_data_o),

    //output
    .r1_enable_o(id_r1_enable_o),
    .r1_addr_o(id_r1_addr_o),
    .r1_data_o(id_r1_data_o),
    
    .r2_enable_o(id_r2_enable_o),
    .r2_addr_o(id_r2_addr_o), 
    .r2_data_o(id_r2_data_o),

    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    
    .w_enable_o(id_w_enable_o),
    .w_addr_o(id_w_addr_o),

    .pc_o(id_pc_o),
    .offset_o(id_offset_o),

    .id_stall_req_o(stall_req_from_id),
    .link_addr_o(id_link_addr_o),
    .branch_flag_o(branch_flag),
    .branch_addr_o(branch_addr)
);

Regfile regfile0(

    .clk(clk),
    .rst(rst),

    .w_enable(wb_w_enable_i),
    .w_addr(wb_w_addr_i),
    .w_data(wb_w_data_i),

    .r1_enable(id_r1_enable_o),
    .r1_addr(id_r1_addr_o),
    //output
    .r1_data(id_r1_data_i),

    .r2_enable(id_r2_enable_o),
    .r2_addr(id_r2_addr_o),
    //output
    .r2_data(id_r2_data_i)
);

ID_EX id_ex0(

    //input
    .clk(clk),
    .rst(rst),

    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_r1_data(id_r1_data_o),
    .id_r2_data(id_r2_data_o),
    .id_w_enable(id_w_enable_o),
    .id_w_addr(id_w_addr_o),
    .id_pc(id_pc_o),
    .id_offset(id_offset_o),
    .id_link_addr(id_link_addr_o),

    .stall(stall),

    //output
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_r1_data(ex_r1_data_i),
    .ex_r2_data(ex_r2_data_i),
    .ex_w_enable(ex_w_enable_i),
    .ex_w_addr(ex_w_addr_i),
    .ex_pc(ex_pc_i),
    .ex_offset(ex_offset_i),
    .ex_link_addr(ex_link_addr_i)
);

EX ex0(

    //input
    .rst(rst),

    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),

    .r1_data_i(ex_r1_data_i),
    .r2_data_i(ex_r2_data_i),

    .w_enable_i(ex_w_enable_i),
    .w_addr_i(ex_w_addr_i),

    .pc_i(ex_pc_i),
    .offset_i(ex_offset_i),
    .link_addr_i(ex_link_addr_i),

    //output
    .w_enable_o(ex_w_enable_o),
    .w_addr_o(ex_w_addr_o),
    .w_data_o(ex_w_data_o),

    .ram_addr_o(ex_ram_addr_o),
    .aluop_o(ex_aluop_o),
    .ex_stall_req_o(stall_req_from_ex)
);

EX_MEM ex_mem0(

    //input
    .clk(clk),
    .rst(rst),

    .ex_w_enable(ex_w_enable_o),
    .ex_w_addr(ex_w_addr_o),
    .ex_w_data(ex_w_data_o),
    .ex_aluop(ex_aluop_o),
    .ex_ram_addr(ex_ram_addr_o),

    .stall(stall),

    //output
    .me_w_enable(me_w_enable_i),
    .me_w_addr(me_w_addr_i),
    .me_w_data(me_w_data_i),
    .me_aluop(me_aluop_i),
    .me_ram_addr(me_ram_addr_i)
);

MEM mem0(

    //input
    .rst(rst),

    .w_enable_i(me_w_enable_i),
    .w_addr_i(me_w_addr_i),
    .w_data_i(me_w_data_i),
    
    .aluop_i(me_aluop_i),

    .ram_busy_i(ram_busy),
    .ram_addr_i(me_ram_addr_i),
    .ram_data_i(ram_to_me_data),

    //output
    .me_req_o(me_req),
    .ram_addr_o(me_addr),
    .ram_data_o(me_to_ram_data),
    .me_stall_req_o(stall_req_from_me),
    .wait_time_o(wait_time),
    .is_load_o(is_load),

    .w_enable_o(me_w_enable_o),
    .w_addr_o(me_w_addr_o),
    .w_data_o(me_w_data_o)
);

MEM_WB mem_wb0(

    //input
    .clk(clk),
    .rst(rst),

    .me_w_enable(me_w_enable_o),
    .me_w_addr(me_w_addr_o),
    .me_w_data(me_w_data_o),

    .stall(stall),
    
    //output
    .wb_w_enable(wb_w_enable_i),
    .wb_w_addr(wb_w_addr_i),
    .wb_w_data(wb_w_data_i)
);

endmodule