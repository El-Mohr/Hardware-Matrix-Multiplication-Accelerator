//#################### Module ####################
module Block #(
	parameter elementsNum = 4,
	parameter dataWidth = 4
)
(
	input clk,
	input rst,
	input zero_in,
	input we_out,
	input we_mem,	
	input [$clog2(elementsNum)-1:0] wraddr,
	input [dataWidth-1:0] in,
	input [$clog2(elementsNum)-1:0] rdaddr,
	output reg [dataWidth*2+$clog2(elementsNum):0] out
);

//#################### Regs ####################
reg [dataWidth*2-1:0] mult_reg;

//#################### Wires ####################
wire [dataWidth-1:0] mult_in;
wire [dataWidth*2-1:0] mult_out;
wire [dataWidth*2+$clog2(elementsNum):0] add_out;
wire [dataWidth*2+$clog2(elementsNum):0] add_in;

//#################### Logic ####################
//-------------------- Multiplier --------------------
assign mult_out = mult_in * in;

//-------------------- Sequential Adder --------------------
assign add_out = add_in + mult_reg;

//-------------------- Adder Input Mux --------------------
assign add_in = zero_in? '0 : out;

//-------------------- Registers --------------------

always@(posedge clk) begin
	if(rst==1) begin	
		mult_reg <= '0;
		out <= '0;
	end	
	else begin
		mult_reg <= mult_out;
		if(we_out) begin
			out <= add_out;
		end
	end
end

//-------------------- Mem Instantiation --------------------
Mem #(
	.elementsNum(elementsNum),
	.dataWidth(dataWidth)
) Mem_inst (
	.clk(clk),
	.rst(rst),
	.we(we_mem),	
	.wraddr(wraddr),
	.wrdata(in),
	.rdaddr(rdaddr),
	.rddata(mult_in)
);

endmodule


