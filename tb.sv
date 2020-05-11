`timescale 1ns / 1ps

module tb ();

//#################### Parameter Declarations ####################
parameter elementsNum = 2;
parameter dataWidth = 16;
parameter Tclk = 2;

//#################### Regs ####################
reg clk;
reg rst;
reg [dataWidth-1:0] in;
reg valid_in;
reg ready_out;

//#################### Wires ####################
wire ready_in;
wire [dataWidth*2+$clog2(elementsNum):0] out;
wire valid_out;
wire last;

SimWrapper #(
	.elementsNum(elementsNum),
	.dataWidth(dataWidth)
) SimWrapper_inst (
	.clk(clk),
	.rst(rst),
	.in(in),
	.valid_in(valid_in),
	.ready_in(ready_in),
	.ready_out(ready_out),
	.out(out),
	.valid_out(valid_out),
	.last(last)
);

always begin
#(Tclk/2) clk <= !clk;
end

initial begin
	$dumpfile("tb.vcd");
	$dumpvars(0,tb);
	clk <= 1;
	rst <= 1;
	in <= '0;
	valid_in <= 0;
	ready_out <= 1;
end

always@(posedge clk) begin

	#(Tclk) rst <= 1; 
	#(Tclk) rst <= 0;
	#(Tclk) 


	//1st Matrix	
	for (int i=0; i<elementsNum; i=i+1) begin	
		in=i+1;
		valid_in=1;	
		#(Tclk);
	end 

/*
	valid_in=0;
	#(5*Tclk) 
*/
	for (int i=elementsNum; i<(elementsNum**2); i=i+1) begin	
		in=i+1;
		valid_in=1;	
		#(Tclk);
	end

	in=0;
	//valid_in=0;
	#(Tclk) 


	//2nd Matrix	
	for (int i=0; i<elementsNum; i=i+1) begin
		while (ready_in == 0) begin
			#(Tclk);
		end
		in=i+100;
		valid_in=1;	
		#(Tclk);
	end
/*
	valid_in=0;
	#(5*Tclk) 
*/

	
	for (int i=elementsNum; i<(elementsNum*2); i=i+1) begin	
		while (ready_in == 0) begin
			#(Tclk);
		end
		in=i+100;
		valid_in=1;	
		#(Tclk);
	end

/*	ready_out <= 0;

	valid_in=0;
	#(5*Tclk) 


	//ready_out <= 1;
*/
	
/*
	ready_out <= 1;

	valid_in=0;
	#(5*Tclk) 
*/
	for (int i=elementsNum*2; i<(elementsNum**2); i=i+1) begin	
		while (ready_in == 0) begin
			#(Tclk);
		end
		in=i+100;
		valid_in=1;	
		#(Tclk);
	end

/*
	valid_in=0;
	#(5*Tclk)

	//ready_out <= 1;
*/

/*
	//3rd Matrix
	for (int i=0; i<(elementsNum**2); i=i+1) begin	
		while (ready_in == 0) begin
			#(Tclk);
		end
		in=i+100;
		valid_in=1;	
		#(Tclk);
	end
*/

	valid_in=0;	

	#(50*Tclk) $finish;


end

endmodule

