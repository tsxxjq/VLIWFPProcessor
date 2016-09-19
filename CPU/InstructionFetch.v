`define	UD #1

module InstructionFetch (clock, nReset, NPC1, NPCSel, freeze, IMemDataOut, IMemAddr, PC, instruction);

input			clock;
input			nReset;
input	[19:0]	NPC1;
input			NPCSel;
input			freeze;
input	[31:0]	IMemDataOut;
output	[19:0]	IMemAddr;
output	[31:0]	instruction;
output	[19:0]	PC;
reg		[19:0]	PC;
wire	[19:0]	NPC0;
wire	[19:0]	NextPC;

assign NPC0 = PC + 4;
assign IMemAddr = PC;
assign instruction = IMemDataOut;
assign NextPC = (NPCSel == 0) ? NPC0 : NPC1;

always @(posedge clock or negedge nReset)
	if(!nReset)
		PC <= `UD 0;
	else if(!freeze)
		PC <= `UD NextPC;
			
endmodule
