//#################### Module ####################
module SimWrapper #(
	parameter elementsNum = 4,
	parameter dataWidth = 4
)
(
	input clk,
	input rst,
	input [dataWidth-1:0] in,
	input valid_in,
	output ready_in,
	input ready_out,
	output [dataWidth*2+$clog2(elementsNum):0] out,
	output valid_out,
	output last
);

//#################### Input Regsiters ####################
reg [dataWidth-1:0] in_reg;
reg valid_in_reg;
reg ready_out_reg;

always@(posedge clk) begin
	in_reg <= in;
	valid_in_reg <= valid_in;
	ready_out_reg <= ready_out;
end

//#################### Main Block Instantiation ####################
MatMult #(
	.elementsNum(elementsNum),
	.dataWidth(dataWidth)
) MatMult_inst (
	.clk(clk),
	.rst(rst),
	.in(in_reg),
	.valid_in(valid_in_reg),
	.ready_in(ready_in),
	.ready_out(ready_out_reg),
	.out(out),
	.valid_out(valid_out),
	.last(last)
);
endmodule


