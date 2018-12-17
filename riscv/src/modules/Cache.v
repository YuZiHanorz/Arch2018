//based on Zhang Zhekai's code

`timescale 1ns / 1ps

`include "Defines.v"

module Cache_Ram
#(
	parameter ADDR_WIDTH = 8,
	parameter DATA_BYTE_WIDTH = 1
)
(
	input wire								clk,
	input wire								rst,
	
	input wire 								r_flag,
	input wire [ADDR_WIDTH-1:0]				r_addr,
	
	input wire 								w_flag,
	input wire [ADDR_WIDTH-1:0]				w_addr,
	input wire [8*DATA_BYTE_WIDTH-1:0]		w_data,
	input wire [DATA_BYTE_WIDTH-1:0]		w_mask,

    output reg [8*DATA_BYTE_WIDTH-1:0]		r_data_o
);
	
	reg [8*DATA_BYTE_WIDTH-1:0]	data[(1<<ADDR_WIDTH)-1:0];
	
	always @ (posedge clk)
	begin
		if (rst)
		begin
			r_data_o <= 0;
		end
		else begin
			if (r_flag)
				r_data_o <= data[r_addr];
			if (w_flag)
			begin
				if (w_mask[0])
					data[w_addr][7:0]	<= w_data[7:0];
				if (w_mask[1])
					data[w_addr][15:8]	<= w_data[15:8];
				if (w_mask[2])
					data[w_addr][23:16]	<= w_data[23:16];
				if (w_mask[3])
					data[w_addr][31:24]	<= w_data[31:24];
			end
		end
	end

endmodule