`define	UD #1

module execute (
		clock,
		nReset,
		da,
		db,
		DatRAMOut,
		ALUFun,
		DatRAMAddr,
		iLD,
		iPOP_iFPOP,
		wra,
		wn1,
		wn2,
		wreg1,
		wreg2,
		wmem,

		FP_Wn_CH1,
		FP_Wn_CH2,
		FP_WReg_CH1,
		FP_WReg_CH2,
		FP_InPathSel_CH1,
		FP_InPathSel_CH2,
		FP_OutPathSel_CH1,
		FP_OutPathSel_CH2,
		FP_AddSub,
		FP_AbsOpp_CH1,
		FP_AbsOpp_CH2,
		iFMOV_CH1,
		iFMOV_CH2,
		iFMEM_iFSTK_CH1,
		iFMEM_iFSTK_CH2,
		iTRNS2INT,
		FP_LowWordSel,		
		FP_WMem,
		FP_d1a,
		FP_d1b,
		FP_d2a,
		FP_d2b,
		
		ed1,
		ed2,
		eDatRAMAddr,
		DatRAMIn,
		ewn1,
		ewn2,
		ewreg1,
		ewreg2,
		INT_Neg,
		INT_Zero,
		ewmem,
		
		eFP_ed1,
		eFP_ed2,
		eFP_Wn_CH1,
		eFP_Wn_CH2,
		eFP_WReg_CH1,
		eFP_WReg_CH2,
		FP_Neg_CH1,
		FP_Neg_CH2,
		FP_Zero_CH1,
		FP_Zero_CH2
		);

`include "..//SRC//CPU//FPDef.v"
		
input						clock;
input						nReset;
input	[31:0]				da;
input	[31:0]				db;
input	[31:0]				DatRAMOut;
input	[3:0]				ALUFun;
input	[19:0]				DatRAMAddr;
input						iLD;
input						iPOP_iFPOP;
input						wra;
input	[3:0]				wn1, wn2;
input						wreg1, wreg2;
input						wmem;

input	[3:0]				FP_Wn_CH1, FP_Wn_CH2;																
input						FP_WReg_CH1, FP_WReg_CH2;
input	[2:0]				FP_InPathSel_CH1, FP_InPathSel_CH2;
input	[2:0]				FP_OutPathSel_CH1, FP_OutPathSel_CH2;
input						FP_AddSub;
input						FP_AbsOpp_CH1, FP_AbsOpp_CH2;
input						iFMOV_CH1, iFMOV_CH2;
input						iFMEM_iFSTK_CH1, iFMEM_iFSTK_CH2;
input						iTRNS2INT;
input						FP_WMem;
input						FP_LowWordSel;
input	[FPRegWidth - 1:0]	FP_d1a, FP_d1b;
input	[FPRegWidth - 1:0]	FP_d2a, FP_d2b;

output	[31:0]				ed1, ed2;
output	[3:0]				ewn1, ewn2;
output						ewreg1, ewreg2;
output						ewmem;
output	[19:0]				eDatRAMAddr;
output						INT_Neg;
output						INT_Zero;
output	[31:0]				DatRAMIn;

output	[FPRegWidth - 1:0]	eFP_ed1, eFP_ed2;
output	[3:0]				eFP_Wn_CH1, eFP_Wn_CH2;
output						eFP_WReg_CH1, eFP_WReg_CH2;
output						FP_Neg_CH1, FP_Neg_CH2;
output						FP_Zero_CH1, FP_Zero_CH2;

reg		[31:0]				ed1, ed2;
reg		[3:0]				ewn1, ewn2;
reg							ewreg1, ewreg2;
reg							ewmem;
reg		[19:0]				eDatRAMAddr;
reg		[3:0]				eALUFun;
reg		[31:0]				ea;
reg		[31:0]				eb;
reg							eiLD;
reg							eiPOP_iFPOP;
reg							ewra;

reg		[3:0]				eFP_Wn_CH1, eFP_Wn_CH2;
reg							eFP_WReg_CH1, eFP_WReg_CH2;
reg							eFP_AddSub;
reg							eFP_AbsOpp_CH1, eFP_AbsOpp_CH2;
reg							eiFMOV_CH1, eiFMOV_CH2;
reg							eiTRNS2INT;
reg							eFP_WMem;
reg		[FPRegWidth - 1:0]	eFP_d1a, eFP_d1b;
reg		[FPRegWidth - 1:0]	eFP_d2a, eFP_d2b;
reg		[2:0]				eFP_InPathSel_CH1, eFP_InPathSel_CH2;
reg		[2:0]				eFP_OutPathSel_CH1, eFP_OutPathSel_CH2;
reg							eiFMEM_iFSTK_CH1, eiFMEM_iFSTK_CH2;
reg							eFP_LowWordSel;
reg		[FPRegWidth - 1:0]	TrnsOut;

wire 	[31:0]				ALUResult;
wire	[31:0]				TrnsInLowWord, TrnsInHighWord;
wire	[FPRegWidth - 1:0]	eFP_ed1, eFP_ed2;
wire	[FPRegWidth - 1:0]	TrnsIn;
wire	[FPRegWidth - 1:0]	AddSubOut, AddSubIn1, AddSubIn2;
wire	[FPRegWidth - 1:0]	MulOut, MulIn1, MulIn2;
wire	[FPRegWidth - 1:0]	DivOut, DivIn1, DivIn2;
wire	[FPRegWidth - 1:0]	SqrtOut, SqrtIn;
wire	[FPRegWidth - 1:0]	AbsOpp1Out, AbsOpp2Out, AbsOpp1In, AbsOpp2In;
wire	[FPRegWidth - 1:0]	FP_result1, FP_result2;
wire	[FPRegWidth - 1:0]	FP_RMemDWord1, FP_RMemDWord2;

assign TrnsInLowWord = TrnsIn[31:0];
assign TrnsInHighWord = {{(32 - (FPRegWidth - 32)){1'b0}}, TrnsIn[FPRegWidth - 1:32]};

always @(posedge clock or negedge nReset)
if(!nReset)	begin
	ewreg1 <= `UD 0;
	ewreg2 <= `UD 0;
	end
else begin
	ewreg1 <= `UD wreg1;
	ewreg2 <= `UD wreg2;
	end
		
always @(posedge clock or negedge nReset)
if(!nReset)
	ewmem <= `UD 0;
else
	ewmem <= `UD wmem;

always @(posedge clock or negedge nReset)
if(!nReset)	begin
	eFP_WReg_CH1 <= `UD 0;
	eFP_WReg_CH2 <= `UD 0;
	end
else begin
	eFP_WReg_CH1 <= `UD FP_WReg_CH1;
	eFP_WReg_CH2 <= `UD FP_WReg_CH2;
	end

always @(posedge clock)
	begin
	ea <= `UD da;
	eb <= `UD db;
	ewn1 <= `UD wn1;
	ewn2 <= `UD wn2;	
	eALUFun <= `UD ALUFun;
	eDatRAMAddr <= `UD DatRAMAddr;
	eiLD <= `UD iLD;
	eiPOP_iFPOP <= `UD iPOP_iFPOP;
	ewra <= `UD wra;
	eFP_Wn_CH1 <= `UD FP_Wn_CH1;
	eFP_Wn_CH2 <= `UD FP_Wn_CH2;
	eFP_AddSub <= `UD FP_AddSub;
	eFP_AbsOpp_CH1 <= `UD FP_AbsOpp_CH1;
	eFP_AbsOpp_CH2 <= `UD FP_AbsOpp_CH2;
	eiFMOV_CH1 <= `UD iFMOV_CH1;
	eiFMOV_CH2 <= `UD iFMOV_CH2;
	eiTRNS2INT <= `UD iTRNS2INT;	
	eFP_d1a <= `UD FP_d1a;
	eFP_d1b <= `UD FP_d1b;
	eFP_d2a <= `UD FP_d2a;
	eFP_d2b <= `UD FP_d2b;
	eFP_InPathSel_CH1 <= `UD FP_InPathSel_CH1;
	eFP_InPathSel_CH2 <= `UD FP_InPathSel_CH2;
	eFP_OutPathSel_CH1 <= `UD FP_OutPathSel_CH1;
	eFP_OutPathSel_CH2 <= `UD FP_OutPathSel_CH2;
	eFP_WMem <= `UD FP_WMem;
	eiFMEM_iFSTK_CH1 <= `UD iFMEM_iFSTK_CH1;
	eiFMEM_iFSTK_CH2 <= `UD iFMEM_iFSTK_CH2;
	eFP_LowWordSel <= `UD FP_LowWordSel;
	end

always @ ( * )
	case ({eiLD, ewra, eiTRNS2INT, eiPOP_iFPOP})
		4'b1000 : ed1 = DatRAMOut;			//eiLD
		4'b0100 : ed1 = ea;					//ewra
		4'b0010 : ed1 = TrnsInLowWord;		//eiTRNS2INT
		4'b0001 : ed1 = eDatRAMAddr;		//eiPOP_iFPOP
		default : ed1 = ALUResult;
	endcase

always @ ( * ) begin
	if(eiPOP_iFPOP)
		ed2 = DatRAMOut;					//when FPOP, wreg2 = 0, so no effect
	else
		ed2 = TrnsInHighWord;
	end

assign DatRAMIn = eFP_WMem ? (eFP_LowWordSel ? TrnsInLowWord : TrnsInHighWord) : eb;

ALU iALU(.a(ea), .b(eb), .func(eALUFun), .result(ALUResult));

assign FP_RMemDWord1 = eFP_LowWordSel ? {eFP_d1a[FPRegWidth - 1:32], DatRAMOut} : {DatRAMOut[FPRegWidth - 32 - 1:0], eFP_d1a[31:0]};
assign FP_RMemDWord2 = eFP_LowWordSel ? {eFP_d2a[FPRegWidth - 1:32], DatRAMOut} : {DatRAMOut[FPRegWidth - 32 - 1:0], eFP_d2a[31:0]};

always @ ( * )
	if (eiFMEM_iFSTK_CH1)
		TrnsOut = FP_RMemDWord1;
	else if (eiFMEM_iFSTK_CH2)
		TrnsOut = FP_RMemDWord2;
	else
		TrnsOut = {eb[FPRegWidth - 32 - 1 : 0], ea[31:0]};
		
assign eFP_ed1 = eiFMOV_CH1 ? eFP_d1a : FP_result1;
assign eFP_ed2 = eiFMOV_CH2 ? eFP_d2a : FP_result2;

assign INT_Zero = ~|ed1;
assign INT_Neg = ed1[31];
assign FP_Zero_CH1 = ~|eFP_ed1[FPRegWidth - 2:0];
assign FP_Zero_CH2 = ~|eFP_ed2[FPRegWidth - 2:0];
assign FP_Neg_CH1 = eFP_ed1[FPRegWidth - 1];
assign FP_Neg_CH2 = eFP_ed2[FPRegWidth - 1];

FPUPathSel iFPPathSel(
	.a1(eFP_d1a),
	.b1(eFP_d1b),
	.a2(eFP_d2a),
	.b2(eFP_d2b),
	.InSel1(eFP_InPathSel_CH1),
	.InSel2(eFP_InPathSel_CH2),
	.OutSel1(eFP_OutPathSel_CH1),
	.OutSel2(eFP_OutPathSel_CH2),
	.TrnsOut(TrnsOut),
	.AddSubOut(AddSubOut),
	.MulOut(MulOut),
	.DivOut(DivOut),
	.SqrtOut(SqrtOut),
	.AbsOpp1Out(AbsOpp1Out),
	.AbsOpp2Out(AbsOpp2Out),	
	.TrnsIn(TrnsIn),
	.AddSubIn1(AddSubIn1),
	.AddSubIn2(AddSubIn2),
	.MulIn1(MulIn1),
	.MulIn2(MulIn2),
	.DivIn1(DivIn1),
	.DivIn2(DivIn2),
	.SqrtIn(SqrtIn),
	.AbsOpp1In(AbsOpp1In),
	.AbsOpp2In(AbsOpp2In),	
	.result1(FP_result1),
	.result2(FP_result2)
	);
FP_ALU iFP_ALU(
	.clock(clock),
	.nReset(nReset),
	.AddSubSel(eFP_AddSub),
	.AbsOpp1Sel(eFP_AbsOpp_CH1),
	.AbsOpp2Sel(eFP_AbsOpp_CH2),
	.AddSubOut(AddSubOut),
	.MulOut(MulOut),
	.DivOut(DivOut),
	.SqrtOut(SqrtOut),
	.AbsOpp1Out(AbsOpp1Out),
	.AbsOpp2Out(AbsOpp2Out),	
	.AddSubIn1(AddSubIn1),
	.AddSubIn2(AddSubIn2),
	.MulIn1(MulIn1),
	.MulIn2(MulIn2),
	.DivIn1(DivIn1),
	.DivIn2(DivIn2),
	.SqrtIn(SqrtIn),
	.AbsOpp1In(AbsOpp1In),
	.AbsOpp2In(AbsOpp2In)
	);
	
endmodule
