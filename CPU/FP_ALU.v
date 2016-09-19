module FP_ALU(
	clock,
	nReset,
	AddSubSel,
	AbsOpp1Sel,
	AbsOpp2Sel,
	AddSubOut,
	MulOut,
	DivOut,
	SqrtOut,
	AbsOpp1Out,
	AbsOpp2Out,
	AddSubIn1,
	AddSubIn2,
	MulIn1,
	MulIn2,
	DivIn1,
	DivIn2,
	SqrtIn,
	AbsOpp1In,
	AbsOpp2In
	);

`include "..//SRC//CPU//FPDef.v"

input 						clock;
input						nReset;
input						AddSubSel;
input						AbsOpp1Sel, AbsOpp2Sel;
input	[FPRegWidth - 1:0]	AddSubIn1, AddSubIn2;
input	[FPRegWidth - 1:0]	MulIn1, MulIn2;
input	[FPRegWidth - 1:0]	DivIn1, DivIn2;
input	[FPRegWidth - 1:0]	SqrtIn;
input	[FPRegWidth - 1:0]	AbsOpp1In, AbsOpp2In;

output	[FPRegWidth - 1:0]	AddSubOut;
output	[FPRegWidth - 1:0]	MulOut;
output	[FPRegWidth - 1:0]	DivOut;
output	[FPRegWidth - 1:0]	SqrtOut;
output	[FPRegWidth - 1:0]	AbsOpp1Out, AbsOpp2Out;

wire	[FPRegWidth - 1:0]	Abs1, Abs2, Opp1, Opp2;
	
assign Abs1 = {1'b0, AbsOpp1In[FPRegWidth - 2:0]};
assign Abs2 = {1'b0, AbsOpp2In[FPRegWidth - 2:0]};
assign Opp1 = {~AbsOpp1In[FPRegWidth - 1], AbsOpp1In[FPRegWidth - 2:0]};
assign Opp2 = {~AbsOpp2In[FPRegWidth - 1], AbsOpp2In[FPRegWidth - 2:0]};
assign AbsOpp1Out = AbsOpp1Sel ? Abs1 : Opp1;
assign AbsOpp2Out = AbsOpp2Sel ? Abs2 : Opp2;

//FP_ADD_SUB i_FP_ADD_SUB(.add_sub(AddSubSel), .clock(clock), .dataa(AddSubIn1), .datab(AddSubIn2), .result(AddSubOut));
//FP_MULT i_FP_MULT(.clock(clock), .dataa(MulIn1), .datab(MulIn2), .result(MulOut));
//FP_DIV i_FP_DIV(.clock(clock), .dataa(DivIn1), .datab(DivIn2), .result(DivOut));
//FP_SQRT i_FP_SQRT(.clock(clock), .data(SqrtIn), .result(SqrtOut));

FP_ADD_SUB i_FP_ADD_SUB (
	.a(AddSubIn1), // Bus [42 : 0] 
	.b(AddSubIn2), // Bus [42 : 0] 
	.operation(AddSubSel ? 6'b000000 : 6'b000001), // Bus [5 : 0] 
	.clk(clock),
	.result(AddSubOut)); // Bus [42 : 0] 
FP_MULT i_FP_MULT (
	.a(MulIn1), // Bus [42 : 0] 
	.b(MulIn2), // Bus [42 : 0] 
	.clk(clock),
	.result(MulOut)); // Bus [42 : 0]
FP_DIV i_FP_DIV (
	.a(DivIn1), // Bus [42 : 0] 
	.b(DivIn2), // Bus [42 : 0] 
	.clk(clock),
	.result(DivOut)); // Bus [42 : 0] 
FP_SQRT i_FP_SQRT (
	.a(SqrtIn), // Bus [42 : 0] 
	.clk(clock),
	.result(SqrtOut)); // Bus [42 : 0] 
			
endmodule