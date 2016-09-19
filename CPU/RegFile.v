`define	UD #1

module RegFile (rna, rnb, d1, d2, wn1, wn2, we1, we2, clk, nClr, qa, qb);

input	[3:0]	rna, rnb, wn1, wn2;
input	[31:0]	d1, d2;
input			we1, we2, clk, nClr;
output	[31:0]	qa, qb;
reg		[31:0]	registers	[0:15];
integer 		i;

assign qa = registers[rna];
assign qb = registers[rnb];

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
