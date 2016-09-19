`define	UD #1

module FPRegFile (
	rn1a,
	rn1b,
	rn2a,
	rn2b,
	d1,
	d2,
	wn1,
	wn2,
	we1,
	we2,
	clk,
	nClr,
	q1a,
	q1b,
	q2a,
	q2b
	);

`include "..//SRC//CPU//FPDef.v"

input	[3:0]				rn1a, rn1b, wn1;
input	[3:0]				rn2a, rn2b, wn2;
input	[FPRegWidth - 1:0]	d1, d2;
input						we1, we2, clk, nClr;
output	[FPRegWidth - 1:0]	q1a, q1b, q2a, q2b;
reg		[FPRegWidth - 1:0]	registers	[0:15];
integer 		i;

assign q1a = registers[rn1a];
assign q1b = registers[rn1b];
assign q2a = registers[rn2a];
assign q2b = registers[rn2b];

always @(posedge clk or negedge nClr)
	if(!nClr) begin
		for(i = 0; i < 16; i = i + 1)
			registers[i] <= `UD 0;
		end
	else begin
		if(we1)
			registers[wn1] <= `UD d1;
		if(we2 && (!we1 || (wn1 != wn2)))
			registers[wn2] <= `UD d2;
		end
		
endmodule
