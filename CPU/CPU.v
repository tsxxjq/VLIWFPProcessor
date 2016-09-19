module CPU(clock, nReset, iMemOut, dMemOut, iAddr, dAddr, dWr, dMemIn);

`include "..//SRC//CPU//FPDef.v"

input						clock;
input						nReset;
input	[31:0]				iMemOut;
input	[31:0]				dMemOut;
output	[19:0]				iAddr;
output	[19:0]				dAddr;
output						dWr;
output	[31:0]				dMemIn;

wire	[31:0]				ed1, ed2;
wire						ewreg1, ewreg2;
wire						ewmem;
wire	[3:0]				rna, rnb, wn1, wn2, ewn1, ewn2;
wire	[31:0]				qa, qb, da, db;
wire	[19:0]				NPC1, PC, DatRAMAddr;
wire	[31:0]				instruction;
wire	[3:0]				ALUFun;

wire	[3:0]				rn1a, rn1b, rn2a, rn2b, eFP_Wn_CH1, eFP_Wn_CH2;
wire	[3:0]				FP_Wn_CH1, FP_Wn_CH2;
wire						eFP_WReg_CH1, eFP_WReg_CH2, FP_WReg_CH1, FP_WReg_CH2;
wire	[FPRegWidth - 1:0]	eFP_ed1, eFP_ed2, FP_q1a, FP_q1b, FP_q2a, FP_q2b;
wire	[2:0]				FP_InPathSel_CH1, FP_InPathSel_CH2, FP_OutPathSel_CH1, FP_OutPathSel_CH2;
wire						FP_AddSub, iFMOV_CH1, iFMOV_CH2;
wire	[FPRegWidth - 1:0]	FP_d1a, FP_d1b, FP_d2a, FP_d2b;
wire						FP_Neg_CH1, FP_Neg_CH2;
wire						FP_Zero_CH1, FP_Zero_CH2;
wire						FP_AbsOpp_CH1, FP_AbsOpp_CH2;

assign dWr = ewmem;
RegFile i_RegFile(
	.rna(rna),
	.rnb(rnb),
	.d1(ed1),
	.d2(ed2),
	.wn1(ewn1),
	.wn2(ewn2),
	.we1(ewreg1),
	.we2(ewreg2),
	.clk(clock),
	.nClr(nReset),
	.qa(qa),
	.qb(qb)
	);
FPRegFile i_FPRegFile(
	.rn1a(rn1a),
	.rn1b(rn1b),
	.rn2a(rn2a),
	.rn2b(rn2b),
	.d1(eFP_ed1),
	.d2(eFP_ed2),
	.wn1(eFP_Wn_CH1),
	.wn2(eFP_Wn_CH2),
	.we1(eFP_WReg_CH1),
	.we2(eFP_WReg_CH2),
	.clk(clock),
	.nClr(nReset),
	.q1a(FP_q1a),
	.q1b(FP_q1b),
	.q2a(FP_q2a),
	.q2b(FP_q2b)
	);	
InstructionFetch i_IF(
	.clock(clock),
	.nReset(nReset),
	.NPC1(NPC1),
	.NPCSel(NPCSel),
	.freeze(IFFreeze),
	.IMemDataOut(iMemOut),
	.IMemAddr(iAddr),
	.PC(PC),
	.instruction(instruction)
	);
InstuctionDecode i_ID(
	.clock(clock),
	.nReset(nReset),
	.instruction(instruction),
	.pc(PC),
	.INT_Zero(INT_Zero),
	.INT_Neg(INT_Neg),
	.qa(qa),
	.qb(qb),
	.ewn1(ewn1),
	.ewn2(ewn2),
	.ed1(ed1),
	.ed2(ed2),

	.FP_q1a(FP_q1a),
	.FP_q1b(FP_q1b),
	.FP_q2a(FP_q2a),
	.FP_q2b(FP_q2b),
	.eFP_Wn_CH1(eFP_Wn_CH1),
	.eFP_Wn_CH2(eFP_Wn_CH2),
	.eFP_WReg_CH1(eFP_WReg_CH1),
	.eFP_WReg_CH2(eFP_WReg_CH2),
	.eFP_ed1(eFP_ed1),
	.eFP_ed2(eFP_ed2),
	.FP_Neg_CH1(FP_Neg_CH1),
	.FP_Neg_CH2(FP_Neg_CH2),
	.FP_Zero_CH1(FP_Zero_CH1),
	.FP_Zero_CH2(FP_Zero_CH2),
	
	.rna(rna),
	.rnb(rnb),
	.wn1(wn1),
	.wn2(wn2),
	.ewreg1(ewreg1),
	.ewreg2(ewreg2),
	.wreg1(wreg1),
	.wreg2(wreg2),
	.wmem(wmem),
	.da(da),
	.db(db),
	.ALUFun(ALUFun),
	.NPCSel(NPCSel),
	.NPC1(NPC1),
	.IFFreeze(IFFreeze),
	.DatRAMAddr(DatRAMAddr),
	.iLD(iLD),
	.iPOP_iFPOP(iPOP_iFPOP),
	.wra(wra),
	
	.FP_Wn_CH1(FP_Wn_CH1),
	.FP_Wn_CH2(FP_Wn_CH2),																
	.FP_WReg_CH1(FP_WReg_CH1),
	.FP_WReg_CH2(FP_WReg_CH2),
	.FP_Rna_CH1(rn1a),
	.FP_Rnb_CH1(rn1b),
	.FP_Rna_CH2(rn2a),
	.FP_Rnb_CH2(rn2b),
	.FP_InPathSel_CH1(FP_InPathSel_CH1),
	.FP_InPathSel_CH2(FP_InPathSel_CH2),
	.FP_OutPathSel_CH1(FP_OutPathSel_CH1),
	.FP_OutPathSel_CH2(FP_OutPathSel_CH2),
	.FP_AddSub(FP_AddSub),
	.FP_AbsOpp_CH1(FP_AbsOpp_CH1),
	.FP_AbsOpp_CH2(FP_AbsOpp_CH2),
	.FP_LowWordSel(FP_LowWordSel),
	.FP_WMem(FP_WMem),	
	.iFMOV_CH1(iFMOV_CH1),
	.iFMOV_CH2(iFMOV_CH2),
	.iFMEM_iFSTK_CH1(iFMEM_iFSTK_CH1),
	.iFMEM_iFSTK_CH2(iFMEM_iFSTK_CH2),	
	.iTRNS2INT(iTRNS2INT),
	.FP_d1a(FP_d1a),
	.FP_d1b(FP_d1b),
	.FP_d2a(FP_d2a),
	.FP_d2b(FP_d2b)
	);
execute i_EXE(
	.clock(clock),
	.nReset(nReset),
	.da(da),
	.db(db),
	.DatRAMOut(dMemOut),
	.ALUFun(ALUFun),
	.DatRAMAddr(DatRAMAddr),
	.iLD(iLD),
	.iPOP_iFPOP(iPOP_iFPOP),
	.wra(wra),
	.wn1(wn1),
	.wn2(wn2),
	.wreg1(wreg1),
	.wreg2(wreg2),
	.wmem(wmem),

	.FP_Wn_CH1(FP_Wn_CH1),
	.FP_Wn_CH2(FP_Wn_CH2),
	.FP_WReg_CH1(FP_WReg_CH1),
	.FP_WReg_CH2(FP_WReg_CH2),
	.FP_InPathSel_CH1(FP_InPathSel_CH1),
	.FP_InPathSel_CH2(FP_InPathSel_CH2),
	.FP_OutPathSel_CH1(FP_OutPathSel_CH1),
	.FP_OutPathSel_CH2(FP_OutPathSel_CH2),
	.FP_AddSub(FP_AddSub),
	.FP_AbsOpp_CH1(FP_AbsOpp_CH1),
	.FP_AbsOpp_CH2(FP_AbsOpp_CH2),	
	.iFMOV_CH1(iFMOV_CH1),
	.iFMOV_CH2(iFMOV_CH2),
	.iFMEM_iFSTK_CH1(iFMEM_iFSTK_CH1),
	.iFMEM_iFSTK_CH2(iFMEM_iFSTK_CH2),	
	.iTRNS2INT(iTRNS2INT),
	.FP_LowWordSel(FP_LowWordSel),
	.FP_WMem(FP_WMem),	
	.FP_d1a(FP_d1a),
	.FP_d1b(FP_d1b),
	.FP_d2a(FP_d2a),
	.FP_d2b(FP_d2b),
			
	.ed1(ed1),
	.ed2(ed2),
	.eDatRAMAddr(dAddr),
	.DatRAMIn(dMemIn),
	.ewn1(ewn1),
	.ewn2(ewn2),
	.ewreg1(ewreg1),
	.ewreg2(ewreg2),
	.INT_Neg(INT_Neg),
	.INT_Zero(INT_Zero),
	.ewmem(ewmem),
	
	.eFP_ed1(eFP_ed1),
	.eFP_ed2(eFP_ed2),
	.eFP_Wn_CH1(eFP_Wn_CH1),
	.eFP_Wn_CH2(eFP_Wn_CH2),
	.eFP_WReg_CH1(eFP_WReg_CH1),
	.eFP_WReg_CH2(eFP_WReg_CH2),
	.FP_Neg_CH1(FP_Neg_CH1),
	.FP_Neg_CH2(FP_Neg_CH2),
	.FP_Zero_CH1(FP_Zero_CH1),
	.FP_Zero_CH2(FP_Zero_CH2)	
	);
		
endmodule
