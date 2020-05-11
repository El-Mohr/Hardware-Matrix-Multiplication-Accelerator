//#################### Module ####################
module Mem #(
	parameter elementsNum = 4,
	parameter dataWidth = 4
)
(
	input clk,
	input rst,
	input we,	
	input [$clog2(elementsNum)-1:0] wraddr,
	input [dataWidth-1:0] wrdata,
	input [$clog2(elementsNum)-1:0] rdaddr,
	output reg [dataWidth-1:0] rddata
);

//#################### Regs ####################
reg [dataWidth-1:0] mem [elementsNum-1:0];

//#################### Logic ####################
always @(posedge clk) begin
	if(rst) begin
		rddata <= 0;
	end 
	else begin
		if(we) begin
			mem[wraddr] <= wrdata;
		end
		rddata <= mem[rdaddr];
	end
end

endmodule


