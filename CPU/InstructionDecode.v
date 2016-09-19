`define	UD #1

module InstuctionDecode(
		clock,
		nReset,
		instruction,
		pc,
		INT_Zero,
		INT_Neg,
		qa,
		qb,
		ewn1,
		ewn2,
		ewreg1,
		ewreg2,
		ed1,
		ed2,

		FP_q1a,
		FP_q1b,
		FP_q2a,
		FP_q2b,
		eFP_Wn_CH1,
		eFP_Wn_CH2,
		eFP_WReg_CH1,
		eFP_WReg_CH2,
		eFP_ed1,
		eFP_ed2,
		FP_Neg_CH1,
		FP_Neg_CH2,
		FP_Zero_CH1,
		FP_Zero_CH2,		
		
		rna,
		rnb,
		wn1,
		wn2,
		wreg1,
		wreg2,
		wmem,
		da,
		db,
		ALUFun,
		NPCSel,
		NPC1,
		IFFreeze,
		DatRAMAddr,
		iLD,
		iPOP_iFPOP,
		wra,
		
		FP_Wn_CH1,
		FP_Wn_CH2,																
		FP_WReg_CH1,
		FP_WReg_CH2,
		FP_Rna_CH1,
		FP_Rnb_CH1,
		FP_Rna_CH2,
		FP_Rnb_CH2,
		FP_InPathSel_CH1,
		FP_InPathSel_CH2,
		FP_OutPathSel_CH1,
		FP_OutPathSel_CH2,
		FP_AddSub,
		FP_AbsOpp_CH1,
		FP_AbsOpp_CH2,
		FP_LowWordSel,
		FP_WMem,
		iFMOV_CH1,
		iFMOV_CH2,
		iFMEM_iFSTK_CH1,
		iFMEM_iFSTK_CH2,
		iTRNS2INT,
		FP_d1a,
		FP_d1b,
		FP_d2a,
		FP_d2b
		);

`include "..//SRC//CPU//FPDef.v"
		
input						clock;
input						nReset;
input	[31:0]				instruction;
input	[19:0]				pc;
input						INT_Zero;
input						INT_Neg;
input	[31:0]				qa;							//reg file output port A
input	[31:0]				qb;							//reg file output port B
input	[3:0]				ewn1, ewn2;					//dest. reg. in exe stage
input						ewreg1, ewreg2;				//write reg in exe stage
input	[31:0]				ed1, ed2;					//write back data in exe stage

input	[FPRegWidth - 1:0]	FP_q1a, FP_q1b;				//FP reg file output port A
input	[FPRegWidth - 1:0]	FP_q2a, FP_q2b;				//FP reg file output port A
input	[3:0]				eFP_Wn_CH1, eFP_Wn_CH2;		//FP dest. reg. in exe stage
input						eFP_WReg_CH1, eFP_WReg_CH2;	//FP write reg in exe stage
input	[FPRegWidth - 1:0]	eFP_ed1, eFP_ed2;			//FP write back data in exe stage
input						FP_Neg_CH1, FP_Neg_CH2;
input						FP_Zero_CH1, FP_Zero_CH2;

output	[3:0]				rna;																
output	[3:0]				rnb;																
output	[3:0]				wn1, wn2;																
output						wreg1, wreg2;																
output						wmem;																
output	[31:0]				da;																
output	[31:0]				db;																
output	[3:0]				ALUFun;																
output						NPCSel;																
output	[19:0]				NPC1;																
output						IFFreeze;																
output	[19:0]				DatRAMAddr;																
output						iLD;
output						iPOP_iFPOP;																
output						wra;																

output	[3:0]				FP_Wn_CH1, FP_Wn_CH2;																
output						FP_WReg_CH1, FP_WReg_CH2;
output	[3:0]				FP_Rna_CH1, FP_Rnb_CH1, FP_Rna_CH2, FP_Rnb_CH2;
output	[2:0]				FP_InPathSel_CH1, FP_InPathSel_CH2;
output	[2:0]				FP_OutPathSel_CH1, FP_OutPathSel_CH2;
output						FP_AddSub;
output						iFMOV_CH1, iFMOV_CH2;
output						iFMEM_iFSTK_CH1, iFMEM_iFSTK_CH2;
output						iTRNS2INT;									
output	[FPRegWidth - 1:0]	FP_d1a, FP_d1b;
output	[FPRegWidth - 1:0]	FP_d2a, FP_d2b;
output						FP_AbsOpp_CH1, FP_AbsOpp_CH2;
output						FP_LowWordSel;
output						FP_WMem;

reg		[19:0]				IDPC;
reg		[31:0]				IR;
reg							wreg1, wreg2;
reg							wmem;
reg							NextDiscard;
reg		[31:0]				da;
reg		[31:0]				db;
reg		[3:0]				ALUFun;
reg							NPCSel;
reg		[19:0]				NPC1;
reg		[19:0]				DatRAMAddr;

wire	[5:0]				OpCode;
wire						IFFreeze;
wire	[17:0]				imm;
wire	[31:0]				zeimm;		//unsigned extension of imm.
wire	[31:0]				seimm;		//signed extension of imm.
wire	[15:0]				luimm;
wire	[31:0]				fqa;
wire	[31:0]				fqb;
wire	[31:0]				fqa_p4, fqa_m4;
wire	[3:0]				RegALUFun;
wire	[14:0]				FPSubInstruction_CH1, FPSubInstruction_CH2;
wire						FP_WMem_CH1, FP_WMem_CH2;
wire	[3:0]				INT_Wn_CH1, INT_Wn_CH2;
wire						INT_WReg_CH1, INT_WReg_CH2;
wire	[3:0]				INT_Rn_CH1, INT_Rn_CH2;
wire						INT_RReg_CH1, INT_RReg_CH2;
wire	[3:0]				FP_Wn_CH1, FP_Wn_CH2;
wire						FP_WReg_CH1, FP_WReg_CH2;
wire	[3:0]				FP_Rna_CH1, FP_Rnb_CH1, FP_Rna_CH2, FP_Rnb_CH2;
wire	[2:0]				FP_InPathSel_CH1, FP_InPathSel_CH2;
wire	[2:0]				FP_OutPathSel_CH1, FP_OutPathSel_CH2;
wire						FP_AddSub_CH1, FP_AddSub_CH2;
wire						iFMOV_CH1, iFMOV_CH2;
wire						iFADD_iFSUB_CH1, iFADD_iFSUB_CH2;
wire						iTRNS_CH1, iTRNS_CH2;
wire						iFSVFL_CH1, iFSVFL_CH2;
wire						iFMEM_iFSTK_CH1, iFMEM_iFSTK_CH2;
wire						FP_LowWordSel_CH1, FP_LowWordSel_CH2;
wire						FP_LowWordSel;
wire	[FPRegWidth - 1:0]	FP_fq1a, FP_fq1b;
wire	[FPRegWidth - 1:0]	FP_fq2a, FP_fq2b;
wire						FP_Discard;
wire						FP_AddSub;
wire	[FPRegWidth - 1:0]	FP_d1a, FP_d1b;
wire	[FPRegWidth - 1:0]	FP_d2a, FP_d2b;
wire	[1:0]				FlagSel;
wire						INT_Pos;
wire						FP_Pos_CH1, FP_Pos_CH2;
wire	[3:0]				FP_Wn1;
wire						iPUSH_iPOP;
wire						iPOP_iFPOP;
wire						FP_WMem;
wire						iFSTK_CH1, iFSTK_CH2;
wire 						iFPUSH_CH1, iFPUSH_CH2, iFPOP_CH1, iFPOP_CH2;

reg							iLD;
reg							iCALL;
reg							iPUSH;
reg							iPOP;
reg							wra;
reg							iFP;
reg							discard;
reg							positive, negtive, zero;
reg		[3:0]				INT_Wn;

assign iPUSH_iPOP = iPUSH | iPOP | (iFP & (iFSTK_CH1 | iFSTK_CH2));
assign OpCode = IR[31:26];
//for FP instruction, CH1 has a higher priority.
//When collsion, CH2 opration is ignored.
assign FP_Wn1 = INT_WReg_CH1 ? INT_Wn_CH1 : INT_Wn_CH2;
always @ ( * )
	case ({iCALL, iPUSH_iPOP})
		2'b10 : INT_Wn = 15;				// LR(R15)
		2'b01 : INT_Wn = 14;				// SP(R14)
		default : INT_Wn = IR[25:22];		// wn is given by IR
	endcase

assign wn1 = iFP ? FP_Wn1 : INT_Wn;
// for FP_REG transfer. wn1 must be an even number.
assign wn2 = iPOP ? IR[25:22] : wn1 | 4'b0001;
assign rna = iFP ? (INT_RReg_CH1 ? INT_Rn_CH1 : INT_Rn_CH2) : (iPUSH_iPOP ? 14 : IR[21:18]);
assign rnb = iFP ? (rna | 4'b0001) : IR[17:14];
assign imm = IR[17:0];
assign zeimm = {14'b0, IR[17:0]};
assign seimm = {{14{IR[17]}}, IR[17:0]};
assign luimm = IR[15:0];
assign RegALUFun = IR[3:0];
assign FlagSel = IR[21:20];

//assign fqa = (ewn1 == rna && ewreg1) ? ed1 : 
//			((ewn2 == rna && ewreg2 && ewn1 != ewn2) ? ed2 : qa);	//Internal forwarding
//assign fqb = (ewn1 == rnb && ewreg1) ? ed1 :
//			((ewn2 == rnb && ewreg2 && ewn1 != ewn2) ? ed2 : qb);	//Internal forwarding

//Internal forwarding
assign fqa = (ewn1 == rna && ewreg1) ? ed1 : 
			((ewn2 == rna && ewreg2) ? ed2 : qa);					
assign fqb = (ewn1 == rnb && ewreg1) ? ed1 :
			((ewn2 == rnb && ewreg2) ? ed2 : qb);
assign fqa_p4 = fqa + 4;
assign fqa_m4 = fqa - 4;
assign FP_fq1a = (eFP_Wn_CH1 == FP_Rna_CH1 && eFP_WReg_CH1) ? eFP_ed1 :
			((eFP_Wn_CH2 == FP_Rna_CH1 && eFP_WReg_CH2) ? eFP_ed2 : FP_q1a);
assign FP_fq1b = (eFP_Wn_CH1 == FP_Rnb_CH1 && eFP_WReg_CH1) ? eFP_ed1 :
			((eFP_Wn_CH2 == FP_Rnb_CH1 && eFP_WReg_CH2) ? eFP_ed2 : FP_q1b);
assign FP_fq2a = (eFP_Wn_CH1 == FP_Rna_CH2 && eFP_WReg_CH1) ? eFP_ed1 :
			((eFP_Wn_CH2 == FP_Rna_CH2 && eFP_WReg_CH2) ? eFP_ed2 : FP_q2a);
assign FP_fq2b = (eFP_Wn_CH1 == FP_Rnb_CH2 && eFP_WReg_CH1) ? eFP_ed1 :
			((eFP_Wn_CH2 == FP_Rnb_CH2 && eFP_WReg_CH2) ? eFP_ed2 : FP_q2b);
assign FP_d1a = FP_fq1a;
assign FP_d1b = FP_fq1b;
assign FP_d2a = FP_fq2a;
assign FP_d2b = FP_fq2b;
assign FP_Discard = discard | (~iFP);			
assign FP_AddSub = (iFADD_iFSUB_CH1 && !FP_WReg_CH1) ? FP_AddSub_CH1 : FP_AddSub_CH2;
assign FP_LowWordSel = iFMEM_iFSTK_CH1 ? FP_LowWordSel_CH1 : FP_LowWordSel_CH2;
assign iTRNS2INT = (iTRNS_CH1 && INT_WReg_CH1) | (iTRNS_CH2 && INT_WReg_CH2);
assign FP_WMem = wmem & iFP;
		
assign FPSubInstruction_CH1 = IR[29:15];
assign FPSubInstruction_CH2 = IR[14:0];

always @ ( * ) begin
	case (FlagSel)
		2'b01 : begin		//FP channel 1 flag
			negtive = FP_Neg_CH1;
			zero = FP_Zero_CH1;
			positive = FP_Pos_CH1;			
			end
		2'b10 : begin		//FP channel 2 flag
			negtive = FP_Neg_CH2;
			zero = FP_Zero_CH2;
			positive = FP_Pos_CH2;
			end
		default: begin		//INT flag
			negtive = INT_Neg;
			zero = INT_Zero;
			positive = INT_Pos;
			end
	endcase
end

assign INT_Pos = (~INT_Neg) & (~INT_Zero);
assign FP_Pos_CH1 = (~FP_Neg_CH1) & (~FP_Zero_CH1);
assign FP_Pos_CH2 = (~FP_Neg_CH2) & (~FP_Zero_CH2);

assign iFPUSH_CH1 = iFP & (iFSTK_CH1 & FP_WMem_CH1);
assign iFPUSH_CH2 = iFP & (iFSTK_CH2 & FP_WMem_CH2);
assign iFPOP_CH1 = iFP & (iFSTK_CH1 & FP_WReg_CH1);
assign iFPOP_CH2 = iFP & (iFSTK_CH2 & FP_WReg_CH2);
assign iPOP_iFPOP = iPOP | iFPOP_CH1 | iFPOP_CH2;

FPSubInstructionDecode FPSID_CH1(
	.FPSubInstruction(FPSubInstruction_CH1),
	.discard(FP_Discard),
	.WMem(FP_WMem_CH1),
	.INT_Wn(INT_Wn_CH1),
	.INT_WReg(INT_WReg_CH1),
	.INT_Rn(INT_Rn_CH1),
	.INT_RReg(INT_RReg_CH1),
	.FP_Wn(FP_Wn_CH1),
	.FP_WReg(FP_WReg_CH1),
	.FP_Rna(FP_Rna_CH1),
	.FP_Rnb(FP_Rnb_CH1),
	.FP_InPathSel(FP_InPathSel_CH1),
	.FP_OutPathSel(FP_OutPathSel_CH1),
	.FP_AddSub(FP_AddSub_CH1),
	.FP_AbsOpp(FP_AbsOpp_CH1),	
	.iFMOV(iFMOV_CH1),
	.iFADD_iFSUB(iFADD_iFSUB_CH1),
	.iTRNS(iTRNS_CH1),
	.iFSVFL(iFSVFL_CH1),
	.iFMEM_iFSTK(iFMEM_iFSTK_CH1),
	.iFSTK(iFSTK_CH1),	
	.LowWordSel(FP_LowWordSel_CH1)
	);
FPSubInstructionDecode FPSID_CH2(
	.FPSubInstruction(FPSubInstruction_CH2),
	.discard(FP_Discard),
	.WMem(FP_WMem_CH2),	
	.INT_Wn(INT_Wn_CH2),
	.INT_WReg(INT_WReg_CH2),
	.INT_Rn(INT_Rn_CH2),
	.INT_RReg(INT_RReg_CH2),
	.FP_Wn(FP_Wn_CH2),
	.FP_WReg(FP_WReg_CH2),
	.FP_Rna(FP_Rna_CH2),
	.FP_Rnb(FP_Rnb_CH2),
	.FP_InPathSel(FP_InPathSel_CH2),
	.FP_OutPathSel(FP_OutPathSel_CH2),
	.FP_AddSub(FP_AddSub_CH2),
	.FP_AbsOpp(FP_AbsOpp_CH2),
	.iFMOV(iFMOV_CH2),
	.iFADD_iFSUB(iFADD_iFSUB_CH2),
	.iTRNS(iTRNS_CH2),
	.iFSVFL(iFSVFL_CH2),
	.iFMEM_iFSTK(iFMEM_iFSTK_CH2),
	.iFSTK(iFSTK_CH2),
	.LowWordSel(FP_LowWordSel_CH2)
	);

always @(posedge clock or negedge nReset)
	if(!nReset)
		IDPC <= `UD 0;
	else
		IDPC <= `UD pc;

always @(posedge clock or negedge nReset)
	if(!nReset)
		IR <= `UD 0;
	else
		IR <= `UD instruction;			

always @(posedge clock or negedge nReset)
	if(!nReset)
		discard <= `UD 1;
	else
		discard <= `UD NextDiscard;

assign IFFreeze	= 0;

always @ ( * ) begin
	NPCSel = 0;
	NPC1 = IDPC + {imm, 2'b00};
	wreg1 = 0;
	wreg2 = 0;
	wmem = 0;
	ALUFun = 0;
	da = fqa;
	db = fqb;
	NextDiscard = 0;
	iLD = 0;
	iCALL = 0;
	iPUSH = 0;
	iPOP = 0;
	wra = 0;
	iFP = 0;
	DatRAMAddr = 0;
	casex (OpCode)
		6'b000000 : ;				//NOP
		6'b000001 : begin			//Process ALU Function with registers
			ALUFun = RegALUFun;
			wreg1 = 1;
			end
		6'b000010 : begin			//JMP, absolute jump
			NPCSel = 1;
			NPC1 = {imm, 2'b00};
			NextDiscard = 1;
			end
		6'b000011 : begin			//JZ, relative jump
			if(zero)	begin
				NPCSel = 1;
				NextDiscard = 1;
				end
			end
		6'b000100 : begin			//JNZ, relative jump
			if(!zero) begin
				NPCSel = 1;
				NextDiscard = 1;
				end
			end
		6'b000101 : begin			//JNEG, relative jump
			if(negtive) begin
				NPCSel = 1;
				NextDiscard = 1;
				end
			end
		6'b000110 : begin			//JPOS, relative jump
			if(positive) begin
				NPCSel = 1;
				NextDiscard = 1;
				end
			end
		6'b000111 : begin			//ADDI
			db = seimm;
			ALUFun = 3;
			wreg1 = 1;
			end
		6'b001000 : begin			//SUBI
			db = seimm;
			ALUFun = 4;
			wreg1 = 1;
			end
		6'b001001 : begin			//ANDI
			db = zeimm;
			ALUFun = 0;
			wreg1 = 1;
			end
		6'b001010 : begin			//ORI
			db = zeimm;
			ALUFun = 1;
			wreg1 = 1;
			end
		6'b001011 : begin			//XORI
			db = zeimm;
			ALUFun = 2;
			wreg1 = 1;
			end
		6'b001100 : begin			//CALL, save pc to R15 & call sub program
			da = IDPC + 4;
			wra = 1;
			wreg1 = 1;
			NPCSel = 1;
			NPC1 = {imm, 2'b00};
			NextDiscard = 1;
			iCALL = 1;
			end
		6'b001101 : begin			//LDPC, load pc from register
			NPCSel = 1;
			NextDiscard = 1;
			NPC1 = fqa;
			end
		6'b001110 : begin			//ST, save register to mem (mem[fqa] = fqb)
			wmem = 1;
			DatRAMAddr = fqa;
			end
		6'b001111 : begin			//LD, load register from mem (regfile[wn] = mem[fqa])
			wreg1 = 1;
			iLD = 1;
			DatRAMAddr = fqa;
			end
		6'b010000 : begin			//LUI
			wreg1 = 1;
			wra = 1;
			da = {luimm, 16'b0};
			end
		6'b010001 : begin			//SVFL, save flag state
			wreg1 = 1;
			wra = 1;
			da = {29'b0, INT_Zero, INT_Pos, INT_Neg};
			end
		6'b010010 : begin			//PUSH, push reg value to stack, update stack pointor (SP, R14)
			iPUSH = 1;
			end
		6'b010011 : begin			//POP, pop reg value from stack, update stack pointor (SP, R14)
			iPOP = 1;			
			wreg2 = 1;
			end
		6'b11xxxx: begin			//Float-point opcodes
			wreg1 = INT_WReg_CH1 | INT_WReg_CH2;
			wreg2 = iTRNS2INT ? wreg1 : 0;
			wmem = FP_WMem_CH1 | FP_WMem_CH2;
			DatRAMAddr = FP_LowWordSel ? fqa : fqa_p4;				// for iFMEM only. DatRAMAddr for iFSTK will be overwritten lator.
			iFP = 1;
			if(iFSVFL_CH1) begin
				wra = 1;
				da = {29'b0, FP_Zero_CH1, FP_Pos_CH1, FP_Neg_CH1};
				wreg2 = 0;
				end
			else if(iFSVFL_CH2) begin
				wra = 1;
				da = {29'b0, FP_Zero_CH2, FP_Pos_CH2, FP_Neg_CH2};		
				wreg2 = 0;
				end
			end
		default : ;
	endcase
	if(iPUSH | iFPUSH_CH1 | iFPUSH_CH2) begin
		wmem = 1;
		DatRAMAddr = fqa;
		wreg1 = 1;
		wra = 1;
		da = fqa_m4;			// (R14 - 4) -> R14		
		end
	if(iPOP_iFPOP) begin
		wreg1 = 1;
		DatRAMAddr = fqa_p4;					
		end
	if(discard) begin
		wreg1 = 0;
		wreg2 = 0;
		wmem = 0;
		NextDiscard = 0;
		NPCSel = 0;
		end
		
end

endmodule
