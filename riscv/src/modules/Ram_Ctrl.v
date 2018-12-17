`include "Defines.v"

module Ram_Ctrl(
    input wire                  clk,
    input wire                  rst,
    //input wire                  rdy,

    input wire[`InstAddrBus]    if_addr_i,
    input wire                  if_req_i,

    input wire[`InstAddrBus]    me_addr_i,
    input wire[`RegBus]         me_data_i,
    input wire                  me_req_i,

    input wire                  is_load_i,
    input wire[3:0]             wait_time_i, 

    input wire[7:0]             din,

    output reg                  ram_busy_o,
    output reg[`InstBus]        if_inst_o,
    output reg[`RegBus]         me_data_o,

    output wire                 wr_o,
    output reg[7:0]             dout,
    output reg[`InstAddrBus]    addr_o
);

assign wr_o = ((op_kind == 3) && (counter != wait_time))? 1: 0;

reg[1:0]            op_kind; //0:do_nothing, 1:if, 2:ld, 3:st
reg[4:0]            counter;
reg[4:0]            wait_time;

initial begin
    op_kind = 0;
end

always @ (posedge clk)
begin
    if (rst)
    begin
        op_kind     <=  0;
        counter     <=  0;
        wait_time   <=  5;
        ram_busy_o  <=  `False;
        addr_o      <=  `ZeroWord;
        dout        <=  8'b00000000;
    end

    else if (counter == wait_time)
    begin
        counter     <=  0;
        op_kind     <=  0;
        ram_busy_o  <=  `False;
    end

    else begin
        counter     <=  counter + 1;
        ram_busy_o  <=  `True;

        if (me_req_i)
        begin
            op_kind     <=  is_load_i?2:3;
            wait_time   <=  wait_time_i;

            if (!is_load_i)
            begin
                addr_o  <=  me_addr_i + counter;
                if (counter == 0)
                begin
                    dout    <=  me_data_i[7:0];
                end
                else if (counter == 1)
                begin
                    dout    <=  me_data_i[15:8];   
                end
                else if (counter == 2)
                begin
                    dout    <=  me_data_i[23:16];
                end
                else if (counter == 3)
                begin
                    dout    <=  me_data_i[31:24];
                end
            end

            else begin
                if (counter == 0)
                begin
                    addr_o  <=  me_addr_i;
                end
                else if (counter == 2)
                begin
                    addr_o  <=  me_addr_i + 1;
                end
                else if (counter == 4)
                begin
                    addr_o  <=  me_addr_i + 2;
                end
                else if (counter == 6)
                begin
                    addr_o  <=  me_addr_i + 3;
                end
            end
        end

        else if (if_req_i)
        begin
            op_kind     <=  1;
            wait_time   <=  5;
            addr_o      <=  if_addr_i + counter;
        end
    end
end


//if
always @ (negedge clk)
begin
    if (rst) 
    begin
        if_inst_o   <=  `ZeroWord;
    end
    else if (op_kind == 1)
    begin
        if (counter == 0 || 1)
        begin
            //if_inst_o = if_inst_o;
        end
        else if (counter == 2)
        begin
            if_inst_o   <=  {if_inst_o[31:8], din};
        end
        else if (counter == 3)
        begin
            if_inst_o   <=  {if_inst_o[31:16], din, if_inst_o[7:0]};
        end
        else if (counter == 4)
        begin
            if_inst_o   <=  {if_inst_o[31:24], din, if_inst_o[15:0]};
        end
        else if (counter == 5)
        begin
            if_inst_o   <=  {din, if_inst_o[23:0]};
        end
    end
end

//ld
always @ (negedge clk)
begin
    if (rst)
    begin
        me_data_o   <=  `ZeroWord;
    end
    else if (op_kind == 2)
    begin
        if (counter == 2)
        begin
            me_data_o   <=  {me_data_o[31:8], din};
        end
        else if (counter == 4)
        begin
            me_data_o   <=  {me_data_o[31:16], din, me_data_o[7:0]};
        end
        else if (counter == 6)
        begin
            me_data_o   <=  {me_data_o[31:24], din, me_data_o[15:0]};
        end
        else if (counter == 8)
        begin
            me_data_o   <=  {din, me_data_o[23:0]};
        end
    end
end

endmodule