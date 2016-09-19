`define	UD #1

module FPUPathSel (
	a1,
	b1,
	a2,
	b2,
	InSel1,
	InSel2,
	OutSel1,
	OutSel2,
	TrnsOut,
	AddSubOut,
	MulOut,
	DivOut,
	SqrtOut,
	AbsOpp1Out,
	AbsOpp2Out,
	TrnsIn,
	AddSubIn1,
	AddSubIn2,
	MulIn1,
	MulIn2,
	DivIn1,
	DivIn2,
	SqrtIn,
	AbsOpp1In,
	AbsOpp2In,
	result1,
	result2
	);
	
`include "..//SRC//CPU//FPDef.v"

input	[FPRegWidth - 1:0]	a1, b1, a2, b2;
input	[2:0]				InSel1, InSel2, OutSel1, OutSel2;
input	[FPRegWidth - 1:0]	TrnsOut;	//from INT-Regs
input	[FPRegWidth - 1:0]	AddSubOut;
input	[FPRegWidth - 1:0]	MulOut;
input	[FPRegWidth - 1:0]	DivOut;
input	[FPRegWidth - 1:0]	SqrtOut;
input	[FPRegWidth - 1:0]	AbsOpp1Out, AbsOpp2Out;

output	[FPRegWidth - 1:0]	TrnsIn;		//to INT-Regs
output	[FPRegWidth - 1:0]	AddSubIn1, AddSubIn2;
output	[FPRegWidth - 1:0]	MulIn1, MulIn2;
output	[FPRegWidth - 1:0]	DivIn1, DivIn2;
output	[FPRegWidth - 1:0]	SqrtIn;
output	[FPRegWidth - 1:0]	AbsOpp1In, AbsOpp2In;
output	[FPRegWidth - 1:0]	result1, result2;

reg		[FPRegWidth - 1:0]	TrnsIn;
reg		[FPRegWidth - 1:0]	AddSubIn1, AddSubIn2;
reg		[FPRegWidth - 1:0]	MulIn1, MulIn2;
reg		[FPRegWidth - 1:0]	DivIn1, DivIn2;
reg		[FPRegWidth - 1:0]	SqrtIn;
reg		[FPRegWidth - 1:0]	result1, result2;

always @ ( * ) begin
	if (InSel1 == F_Trns) begin
		TrnsIn = a1;
		end
	else begin
		TrnsIn = a2;
		end	
	end

always @ ( * ) begin
	if (InSel1 == F_AddSub) begin
		AddSubIn1 = a1;
		AddSubIn2 = b1;
		end
	else begin
		AddSubIn1 = a2;
		AddSubIn2 = b2;
		end	
	end

always @ ( * ) begin
	if (InSel1 == F_Mul) begin
		MulIn1 = a1;
		MulIn2 = b1;
		end
	else begin
		MulIn1 = a2;
		MulIn2 = b2;
		end	
	end

always @ ( * ) begin
	if (InSel1 == F_Div) begin
		DivIn1 = a1;
		DivIn2 = b1;
		end
	else begin
		DivIn1 = a2;
		DivIn2 = b2;
		end	
	end

always @ ( * ) begin
	if (InSel1 == F_Sqrt) begin
		SqrtIn = a1;
		end
	else begin
		SqrtIn = a2;
		end	
	end

assign AbsOpp1In = a1;
assign AbsOpp2In = a2;

always @ ( * )
	case (OutSel1)
	F_AddSub	: result1 = AddSubOut;
	F_Mul		: result1 = MulOut;
	F_Div		: result1 = DivOut;
	F_Sqrt		: result1 = SqrtOut;
	F_AbsOpp	: result1 = AbsOpp1Out;
	F_Trns		: result1 = TrnsOut;
	default		: result1 = 0;
	endcase

always @ ( * )
	case (OutSel2)
	F_AddSub	: result2 = AddSubOut;
	F_Mul		: result2 = MulOut;
	F_Div		: result2 = DivOut;
	F_Sqrt 		: result2 = SqrtOut;
	F_AbsOpp 	: result2 = AbsOpp2Out;
	F_Trns 		: result2 = TrnsOut;	
	default 	: result2 = 0;
	endcase
	
endmodule
