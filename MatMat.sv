//#################### Module ####################
module MatMat #(
	parameter elementsNum = 4,
	parameter dataWidth = 4
)
(
	input clk,
	input rst,
	input [dataWidth-1:0] in,
	input valid_in,
	output reg ready_in,
	input ready_out,
	output [dataWidth*2+$clog2(elementsNum):0] out [elementsNum-1:0],
	output reg valid_out
);

//#################### Local Parameters ####################
localparam IDLE=2'b00, LOAD=2'b01, PROCESS=2'b10, WAIT_OUT=2'b11;

//#################### Wires ####################


//#################### Regs ####################
reg zero_in;
reg we_out;
reg [elementsNum-1:0] we_mem;
reg [elementsNum-1:0] we_mem_prev;
reg [$clog2(elementsNum)-1:0] wraddr;
reg [$clog2(elementsNum)-1:0] rdaddr;
reg start;
reg [$clog2(elementsNum)-1:0] count; 
reg [2:0] wait_count; 
reg [1:0] STATE; 
reg valid_out_0;
reg valid_out_1;
reg [dataWidth-1:0] in_1;
reg zero_in_1;
reg zero_in_2;
reg ready_out_1;
reg ready_out_2;
reg we_out_1;
reg done_0;
reg done_1;

integer i;

//#################### Logic ####################
//-------------------- Delay Registers --------------------
always@(posedge clk) begin
	if(rst==1) begin
		valid_out_1 <= 0;
		valid_out <= 0;
		in_1 <= '0;
		zero_in_1 <= 0;
		zero_in_2 <= 0;
		ready_out_1 <= 0;
		ready_out_2 <= 0;
		we_out_1 <= 0;
		done_1 <= 0;
	end 
	else begin
		valid_out_1 <= valid_out_0;
		valid_out <= valid_out_1;
		zero_in_1 <= zero_in;
		zero_in_2 <= zero_in_1;
		ready_out_1 <= ready_out;
		ready_out_2 <= ready_out_1;
		we_out_1 <= we_out;
		done_1 <= done_0;
		if (ready_in == 1) begin
			in_1 <= in;
		end
	end
end

//-------------------- Block Instantiation --------------------
generate
	genvar k;
	for (k = 0; k < elementsNum; k=k+1) begin:block
		Block #(
		.elementsNum(elementsNum),
		.dataWidth(dataWidth)
		) Block_inst (
		.clk(clk),
		.rst(rst),
		.zero_in(zero_in_2),
		.we_out(we_out_1),
		.we_mem(we_mem[k]),	
		.wraddr(wraddr),
		.in(in_1),
		.rdaddr(rdaddr),
		.out(out[k])
		);
	end
endgenerate


//-------------------- Main FSM --------------------
always@(posedge clk) begin
	if(rst==1) begin
		STATE <= IDLE;
		zero_in <= 1;
		ready_in <= 0;
		valid_out_0 <= 0;
		we_out <= 0;
		wraddr <= '0;
		rdaddr <= '0;
		start <= 1;
		count <= 0;	
		we_mem_prev = 0;
		we_mem <= 0;
		done_0 <= 0;


	end	
	else begin
		case(STATE)
			IDLE: begin
				ready_in <= 1;
				wraddr <= '0;
				we_mem_prev = 1;
				we_mem <= we_mem_prev;
				if(valid_in==1) begin
					STATE <= LOAD;
				end
			end
			LOAD: begin
				if(wraddr == elementsNum-1) begin
					wraddr <= 0;
					we_mem_prev = we_mem_prev << 1 ;
					we_mem <= we_mem_prev;
					count <= count + 1;
					if (count == elementsNum-1) begin
						count <= 0;
						STATE <= PROCESS;
						we_mem <= 0;
						zero_in <= 1;
					end 
				end
				else begin
					if(valid_in==1) begin
						wraddr <= wraddr + 1;
						we_mem <= we_mem_prev;
					end
					else begin
						we_mem <= 0;
					end
				end
			end
			PROCESS: begin
				done_0 <= 0;
				valid_out_0 <= 0;
				if(rdaddr == elementsNum-1) begin
						rdaddr <= 0;
						STATE <= WAIT_OUT;
						zero_in <= 1;
						valid_out_0 <= 1;
						/*if (ready_out == 0) begin
							ready_in <= 0;
							//we_out <= 0;
						end*/
				end
				else if(valid_in==1) begin
					zero_in <= 0;
					we_out <= 1;
					rdaddr <= rdaddr + 1;
				end
				else begin
					we_out <= 0;
				end
			end
			WAIT_OUT: begin
				if (ready_out == 1 & done_1 == 0) begin
					valid_out_0 <= 0;
					STATE <= PROCESS;
					done_0 <= 1;
					ready_in <= 1;
					if(count == elementsNum-1) begin
							count <= 0;
					end					
					if(valid_in == 1) begin
						we_out <= 1;
						rdaddr <= rdaddr + 1;
						zero_in <= 0;
					end
				end
				else begin
					ready_in <= 0;
					we_out <= 0;
				end	
			end
 			default : $display("Error in case statement"); 
		endcase
	end
end

endmodule


