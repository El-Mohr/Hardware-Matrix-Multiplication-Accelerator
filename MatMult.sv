//#################### Module ####################
module MatMult #(
	parameter elementsNum = 3,
	parameter dataWidth = 4
)
(
	input clk,
	input rst,
	input [dataWidth-1:0] in,
	input valid_in,
	output ready_in,
	input ready_out,
	output reg [dataWidth*2+$clog2(elementsNum):0] out,
	output reg valid_out,
	output reg last
);

//#################### Local Parameters ####################
localparam LOAD=1'b0, TRAVERSE=1'b1;

//#################### Wires ####################
wire [dataWidth*2+$clog2(elementsNum):0] out_inter [elementsNum-1:0];
wire valid_out_inter;
wire ready_in_inter;

//#################### Regs ####################
reg ready_out_inter;
reg STATE;
reg done;
reg [$clog2(elementsNum)-1:0]elemCount;
reg [$clog2(elementsNum)-1:0]vecCount;
reg [dataWidth*2+$clog2(elementsNum):0] reg_inter [elementsNum-1:0];

integer i;


//#################### Logic ####################
//-------------------- Registers --------------------
/*
always@(posedge clk) begin
	if(rst==1) begin	
		ready_in <= 0;
	end	
	else begin
		ready_in <= ready_in_inter;
	end
end
*/
//-------------------- Block Instantiation --------------------
MatMat #(
	.elementsNum(elementsNum),
	.dataWidth(dataWidth)
) MatMat_inst (
	.clk(clk),
	.rst(rst),
	.in(in),
	.valid_in(valid_in),
	.ready_in(ready_in),
	.ready_out(ready_out_inter),
	.out(out_inter),
	.valid_out(valid_out_inter)
);

//-------------------- Main FSM --------------------
always@(posedge clk) begin
	if(rst==1) begin
		STATE <= LOAD;
		done <= 1;
		last <= 0;
		ready_out_inter <= 1;
		elemCount <= 0;
		vecCount <= 0;
		out <= 0;
		valid_out <= 0;
	end 
	else begin
		case(STATE)
			LOAD: begin
				last <= 0;
				valid_out <= 0;
				elemCount <= 0;
				if ((valid_out_inter == 1) & (done == 1)) begin
					for (i=0; i<elementsNum; i=i+1) begin
					reg_inter[i] <= out_inter[i];
					end
					STATE <= TRAVERSE;
					done <= 0;
					ready_out_inter <= 0;
				end
			end
			TRAVERSE: begin
				if(ready_out == 1) begin
					valid_out <= 1;
					out <= reg_inter[elemCount];
					if (elemCount == elementsNum-1) begin
						elemCount <= 0;
						STATE <= LOAD;
						done <= 1;
						ready_out_inter <= 1;
						if (vecCount == elementsNum-1) begin
							last <= 1;
							vecCount <= 0;
						end
						else begin
							vecCount <= vecCount + 1;
						end
					end
					else begin
						elemCount <= elemCount + 1;
					end
				end
				else begin
					valid_out <= 0;
				end
			end
 			default : $display("Error in case statement"); 
		endcase		
	end
end

endmodule



