module FPSubInstructionDecode(
	FPSubInstruction,
	discard,
	WMem,
	INT_Wn,
	INT_WReg,
	INT_Rn,
	INT_RReg,
	FP_Wn,
	FP_WReg,
	FP_Rna,
	FP_Rnb,
	FP_InPathSel,
	FP_OutPathSel,
	FP_AddSub,
	FP_AbsOpp,
	iFMOV,
	iFADD_iFSUB,
	iTRNS,
	iFSVFL,
	iFMEM_iFSTK,
	iFSTK,
	LowWordSel
	);
	
`include "..//SRC//CPU//FPDef.v"
	
input	[14:0]			FPSubInstruction;
input					discard;
output					WMem;
output	[3:0]			INT_Wn;
output					INT_WReg;
output	[3:0]			INT_Rn;
output					INT_RReg;
output	[3:0]			FP_Wn;
output					FP_WReg;
output	[3:0]			FP_Rna, FP_Rnb;
output	[2:0]			FP_InPathSel;
output	[2:0]			FP_OutPathSel;
output					FP_AddSub;
output					FP_AbsOpp;
output					iFMOV;
output					iFADD_iFSUB;
output					iTRNS;
output					iFSVFL;
output					iFMEM_iFSTK;
output					iFSTK;
output					LowWordSel;

reg						FP_WReg;
reg		[2:0]			FP_InPathSel;
reg		[2:0]			FP_OutPathSel;
reg		[2:0]			FP_Fun;
reg						iTRNS;
reg						iFMOV;
reg						iFADD_iFSUB;
reg						iNOP;
reg						iFSVFL;
reg						iFMEM;
reg						iFSTK;
reg						FP_AddSub;		//Add when 1, subtract when 0
reg						FP_AbsOpp;		//Abosulte number when 1, opposite number when 0

wire 	[3:0]			FPOpCode;
wire					FP_IsSend;
wire					LowWordSel;
wire					INT_WReg;
wire					iFMEM_iFSTK;
wire					WMem;
wire					RMem;

assign iFMEM_iFSTK = iFMEM | iFSTK;
assign FP_IsSend = FPSubInstruction[2];												//Send when 1, get when 0.
assign LowWordSel = FPSubInstruction[1];											//Select low word when 1, select high word when 0.
assign FPOpCode = FPSubInstruction[14:11];
assign INT_Wn = iFSTK ? 14 : FPSubInstruction[10:7];								//for FP_REG transfer, INT_Wn must be an even number.
assign INT_Rn = iFSTK ? 14 : FPSubInstruction[6:3];									//for FP_REG transfer, INT_Rn must be an even number.
assign FP_Wn = FPSubInstruction[10:7];
assign FP_Rna = (WMem | RMem) ? FPSubInstruction[10:7] : FPSubInstruction[6:3];
assign FP_Rnb = FPSubInstruction[10:7];
assign INT_RReg = (iTRNS && (!FP_IsSend)) || iFMEM_iFSTK;							//Read from INT-Regs.
assign INT_WReg = ((iTRNS && FP_IsSend) || iFSVFL || iFSTK) && (!discard);			//Write to INT-Regs.
assign WMem = (iFMEM_iFSTK && FP_IsSend) && (!discard);								//Write to memory.
assign RMem = (iFMEM_iFSTK && !FP_IsSend);											//Read from memory.

always @ ( * ) begin
	FP_WReg = 0;
	FP_InPathSel = F_Null;
	FP_OutPathSel = F_Null;
	FP_Fun = F_Null;
	iTRNS = 0;
	iFMOV = 0;
	iFADD_iFSUB = 0;
	iNOP = 0;
	iFSVFL = 0;
	iFMEM = 0;
	iFSTK = 0;
	FP_AddSub = 0;
	FP_AbsOpp = 0;
	case (FPOpCode)
		4'b0000 : begin			//FNOP, No opreration
			iNOP = 1;
			end
		4'b0001 : begin			//TRNS, Move between an INT-Reg and a FP-Reg
			FP_Fun = F_Trns;
			iTRNS = 1;
			end
		4'b0010 : begin			//FMOV, Move between two FP-Regs
			FP_WReg = 1;
			iFMOV = 1;
			end
		4'b0011 : begin			//FADD, Add
			FP_Fun = F_AddSub;
			iFADD_iFSUB = 1;
			FP_AddSub = 1;
			end
		4'b0100 : begin			//FSUB, Subtract
			FP_Fun = F_AddSub;
			iFADD_iFSUB = 1;
			FP_AddSub = 0;
			end
		4'b0101 : begin			//FMUL, Multiply
			FP_Fun = F_Mul;
			end
		4'b0110 : begin			//FDIV, Divide
			FP_Fun = F_Div;
			end
		4'b0111 : begin			//FSQRT, Square root
			FP_Fun = F_Sqrt;
			end
		4'b1000 : begin			//FABS, Absolute value
			FP_Fun = F_AbsOpp;
			FP_AbsOpp = 1;
			FP_OutPathSel = F_AbsOpp;
			FP_WReg = 1;
			end
		4'b1001 : begin			//FOPP, Opposite value
			FP_Fun = F_AbsOpp;
			FP_AbsOpp = 0;
			FP_OutPathSel = F_AbsOpp;
			FP_WReg = 1;
			end
		4'b1010 : begin			//FSVFL, Save flag
			iFSVFL = 1;
			end
		4'b1011 : begin			//FMEM, Stoage or load
			FP_Fun = F_Trns;
			iFMEM = 1;
			end
		4'b1100 : begin			//FSTK, Push or pop
			FP_Fun = F_Trns;
			iFSTK = 1;
			end
		default : ;
	endcase
	if(FP_IsSend)	begin
		FP_InPathSel = FP_Fun;
		end
	else begin
		FP_OutPathSel = FP_Fun;
		FP_WReg = 1;
		end
	if(discard || iNOP)	begin
		FP_InPathSel = F_Null;
		FP_OutPathSel = F_Null;		
		FP_WReg = 0;
		end
end

endmodule
