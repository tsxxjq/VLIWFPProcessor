module CPU_tb;

`include "..//SRC//CPU//FPDef.v"

reg							clock;
reg							nReset;
wire	[31:0]				iMemOut;
wire	[31:0]				dMemOut;
wire	[19:0]				iAddr;
wire	[19:0]				dAddr;
wire						dWr;
wire	[31:0]				dMemIn;

reg		[31:0]				iMem			[0:127];
reg		[31:0]				dMem			[0:127];
integer 					i;
integer						ClockCount;
reg		[31:0]				ExpectRegVals	[0:15];
reg		[FPRegWidth - 1:0]	ExpectFPRegVals	[0:15];

CPU I_CPU(
	.clock(clock),
	.nReset(nReset),
	.iMemOut(iMemOut),
	.dMemOut(dMemOut),
	.iAddr(iAddr),
	.dAddr(dAddr),
	.dWr(dWr),
	.dMemIn(dMemIn)
	);

assign iMemOut = iMem[iAddr[8:2]];
assign dMemOut = dMem[dAddr[8:2]];

//Clock
always #10 clock = ~ clock;

always @ (posedge clock)
	if(dWr)
		dMem[dAddr[8:2]] <= dMemIn;

initial
	begin
	ClockCount = 0;
	end
	
always @ (posedge clock) begin
	if(nReset)
		ClockCount = ClockCount + 1;
	end

task CheckReg_Task;
	input	[80 * 8 : 1] msg;
	integer	i, ErrCounts;
	begin
		ErrCounts = 0;
		for(i = 0; i < 16; i = i + 1) begin
			if(I_CPU.i_RegFile.registers[i] !== ExpectRegVals[i]) begin
				$write("Error : Unexpect reg value !\n Reg %d expected = %h, actual = %h.\n",
					i, ExpectRegVals[i], I_CPU.i_RegFile.registers[i]);
				ErrCounts = ErrCounts + 1;
				end
			if(I_CPU.i_FPRegFile.registers[i] !== ExpectFPRegVals[i]) begin
				$write("Error : Unexpect FP-reg value !\n FPReg %d expected = %h, actual = %h.\n",
					i, ExpectFPRegVals[i], I_CPU.i_FPRegFile.registers[i]);
				ErrCounts = ErrCounts + 1;
				end
		end
		if(ErrCounts == 0)
			$write("%s passed!\n", msg);
		else begin
			$write("%s failed!\n", msg);
			$stop;
			end
	end
endtask

task CheckMem_Task;
	input	[8:0]	addr;
	input	[31:0]	data;
	input	[80 * 8 : 1] msg;	
	begin
		if(dMem[addr >> 2] == data) begin
			$write("%s passed!\n", msg);
			end
		else begin
			$write("Error : Unexpect data memory value !\n addr = %h expected = %h, actual = %h.\n",
					addr, data, dMem[addr]);			
			$write("%s failed!\n", msg);
			$stop;
			end
	end
endtask

//Initial
initial
	begin
	#0
	for(i = 0; i < 128; i = i + 1)
		dMem[i] = 0;
	for(i = 0; i < 128; i = i + 1)
		iMem[i] = 0;
	iMem[0] = 32'b010000_0000_000000_1010101010101010;			//LUI R0, #AAAAh
	iMem[1] = 32'b001010_0000_0000_001010101010101010;			//ORI R0, R0, #AAAAh
	iMem[2] = 32'b000001_0010_0000_0001_0000000000_0010;		//XOR R2, R0, R1
	iMem[3] = 32'b000011_00_000000_000000000000000010;			//JZ 2
	iMem[4] = 32'b010000_0011_000000_1111111100000000;			//LUI R3, #FF00h
	iMem[5] = 32'b000001_0100_0011_0000_0000000000_0000;		//AND R4, R3, R0
	iMem[6] = 32'b000100_00_000000_000000000000000100;			//JNZ 10h			;JNZ iMem[+4]
	iMem[7] = 32'b00000000000000000000000000000000;				//NOP
	iMem[8] = 32'b010000_0101_000000_0001001000110100;			//LUI R5, #1234h
	iMem[9] = 32'b000010_00000000_000000000000001011;			//JMP 2Ch			;JMP iMem[11]
	iMem[10] = 32'b000010_00000000_000000000000001000;			//JMP 20h			;JMP iMem[08]	
	iMem[11] = 32'b000111_0110_0101_000101011001111000;			//ADDI R6, R5, #5678h
	iMem[12] = 32'b000001_0111_0110_0011_0000000000_0001;		//OR R7, R6, R3
	iMem[13] = 32'b000101_00_000000_000000000000000011;			//JNEG 0Ch			;JNEG iMem[+3]
	iMem[14] = 32'b010000_0101_000000_1111111111111111;			//LUI R5, #FFFFh
	iMem[15] = 32'b010000_0110_000000_0000000000000000;			//LUI R6, #0000h
	iMem[16] = 32'b000001_0110_0110_0101_0000000000_0100;		//SUB R6, R6, R5
	iMem[17] = 32'b000110_00_000000_111111111111111111;			//JPOS -04h			;JPOS iMem[16]
	iMem[18] = 32'b000001_0110_0110_0101_0000000000_0011;		//ADD R6, R6, R5
	iMem[19] = 32'b001000_0111_0111_000000011001111000;			//SUBI R7, R7, #678h
	iMem[20] = 32'b001100_00000000_000000000001100100;			//CALL 190h			;CALL iMem[100]
	iMem[21] = 32'b010000_1010_000000_0000000000000000;			//LUI R10, #00h
	iMem[22] = 32'b001010_1010_1010_000000000001100100;			//ORI R10, R10, #0064h
	iMem[23] = 32'b001110_0000_1010_0000_00000000000000;		//ST [R10], R0
	iMem[24] = 32'b001111_1011_1010_0000_00000000000000;		//LD R11, [R10]
	iMem[25] = 32'b11_0001_0000_0110_000_0000_00000000000;		//TRNS.GET FR0, {R7,R6} || FNOP
	iMem[26] = 32'b11_0001_1100_0000_100_0001_0001_1110_000;	//TRNS.SEND {R13, R12}, FR0 || TRNS.GET FR1, {R15, R14}
	iMem[27] = 32'b11_0010_1010_0001_000_0010_1100_0000_000;	//FMOV FR10, FR1 || FMOV FR12, FR0
	iMem[28] = 32'b11_0011_1100_0001_100_0011_0010_0000_000;	//FADD.SEND FR1, FR12 || FADD.GET FR2
	iMem[29] = 32'b11_0100_0011_0000_000_0100_1100_0001_100;	//FSUB.GET FR3 || FSUB.SEND FR1, FR12
	iMem[30] = 32'b11_0101_0100_0000_000_0110_0101_0000_000;	//FMUL.GET FR4 || FDIV.GET FR5
	iMem[31] = 32'b11_0111_0110_0000_000_1000_0111_0101_000;	//FSQRT.GET FR6 || FABS FR7, FR5
	iMem[32] = 32'b11_1000_1000_0111_000_1001_1001_0110_000;	//FABS FR8, FR7 || FOPP FR9, FR6
	iMem[33] = 32'b010000_0000_000000_1010101010101010;			//LUI R0, #AAAAh
	iMem[34] = 32'b010001_0001_0000000000000000000000;			//SVFL R1
	iMem[35] = 32'b010000_0000_000000_0000000000000000;			//LUI R0, #0000h
	iMem[36] = 32'b010001_0010_0000000000000000000000;			//SVFL R2
	iMem[37] = 32'b001010_0000_0000_001010101010101010;			//ORI R0, R0, #AAAAh
	iMem[38] = 32'b010001_0011_0000000000000000000000;			//SVFL R3
	iMem[39] = 32'b010000_0001_000000_0000000000000000;			//LUI R1, #0000h
	iMem[40] = 32'b001010_0001_0001_000000010010101010;			//ORI R1, R1, #04AAh
	iMem[41] = 32'b11_0001_0000_0000_000_0000_00000000000;		//TRNS.GET FR0, {R1,R0} || FNOP
	iMem[42] = 32'b11_1010_0010_0000_100_0000_00000000000;		//FSVFL R2 || FNOP
	iMem[43] = 32'b001001_0001_0001_000000001111111111;			//ANDI R1, R1, #03FFh
	iMem[44] = 32'b11_0001_0000_0000_000_0000_00000000000;		//TRNS.GET FR0, {R1,R0} || FNOP
	iMem[45] = 32'b11_1010_0011_0000_100_0000_00000000000;		//FSVFL R3 || FNOP
	iMem[46] = 32'b010000_0001_000000_0000000000000000;			//LUI R1, #0000h
	iMem[47] = 32'b010000_0000_000000_0000000000000000;			//LUI R0, #0000h
	iMem[48] = 32'b11_0000_00000000000_0001_0000_0000_000;		//FNOP || TRNS.GET FR0, {R1,R0}
	iMem[49] = 32'b11_0000_00000000000_1010_0100_0000_100;		//FNOP || FSVFL R4
	iMem[50] = 32'b010000_1110_000000_0000000000000000;			//LUI R14, #0000h
	iMem[51] = 32'b001010_1110_1110_000000000111111100;			//ORI R14, R14, #01FCh (#508, dMem[127])
	iMem[52] = 32'b010000_0001_000000_1010101010101010;			//LUI R1, #AAAAh
	iMem[53] = 32'b010000_0010_000000_0000000000000000;			//LUI R2, #0000h	
	iMem[54] = 32'b010010_0000_0000_0001_00000000000000;		//PUSH R1
	iMem[55] = 32'b010011_0010_0000000000000000000000;			//POP R2
	iMem[56] = 32'b010000_0001_000000_0000000000000000;			//LUI R1, #0000h
	iMem[57] = 32'b001010_0001_0001_000000000000001010;			//ORI R1, R1, #000Ah	
	iMem[58] = 32'b010000_0000_000000_0101101010100101;			//LUI R0, #5AA5h
	iMem[59] = 32'b001010_0000_0000_000010001101000101;			//ORI R0, R0, #2345h	
	iMem[60] = 32'b11_0000_00000000000_0001_0001_0000_000;		//FNOP || TRNS.GET FR1, {R1,R0}
	iMem[61] = 32'b11_0000_00000000000_0010_0010_0000_000;		//FNOP || FMOV FR2,FR0	
	iMem[62] = 32'b010000_1010_000000_0000000000000000;			//LUI R10, #0000h
	iMem[63] = 32'b001010_1010_1010_000000000001100100;			//ORI R10, R10, #0064h
	iMem[64] = 32'b001010_1011_1010_000000000000000000;			//ORI R11, R10, #0000h
	iMem[65] = 32'b11_1011_0001_1010_110_0000_00000000000;		//FMEM.SEND.L [R10], FR1
	iMem[66] = 32'b11_1011_0001_1010_100_0000_00000000000;		//FMEM.SEND.H [R10], FR1
	iMem[67] = 32'b11_1011_0010_1011_010_0000_00000000000;		//FMEM.GET.L FR2, [R11]
	iMem[68] = 32'b11_1011_0010_1011_000_0000_00000000000;		//FMEM.GET.H FR2, [R11]
	iMem[69] = 32'b11_1100_0010_0000_110_0000_00000000000;		//FSTK.SEND.L FR2
	iMem[70] = 32'b11_1100_0010_0000_100_0000_00000000000;		//FSTK.SEND.H FR2	
	iMem[71] = 32'b010010_0000_0000_0110_00000000000000;		//PUSH R6
	iMem[72] = 32'b11_0000_00000000000_1100_0011_0000_010;		//FNOP || FSTK.GET.L FR3
	iMem[73] = 32'b11_0000_00000000000_1100_0011_0000_000;		//FNOP || FSTK.GET.H FR3
	iMem[74] = 32'b000010_00000000_000000000001001010;			//JMP 128h			;JMP iMem[74]
	
	iMem[100] = 32'b001001_1000_0111_001111111100000000;		//ANDI R8, R7, #FF00h
	iMem[101] = 32'b001101_0000_1111_0000_00000000000000;		//LDPC R15
	clock = 0;
	nReset = 0;

	#30
	nReset = 1;
	end

initial begin
	for(i = 0; i < 16; i = i + 1) begin
		ExpectRegVals[i] = 0;
		ExpectFPRegVals[i] = 0;
		end
	end

always @(negedge clock) begin
	case (ClockCount)
		3:	begin
			ExpectRegVals[0] = 32'hAAAA0000;
			CheckReg_Task("LUI R0, #AAAAh");
			end
		4:	begin
			ExpectRegVals[0] = 32'hAAAAAAAA;
			CheckReg_Task("ORI R0, R0, #AAAAh");
			end
		5:	begin
			ExpectRegVals[2] = 32'hAAAAAAAA;
			CheckReg_Task("XOR R2, R0, R1");
			end
		6:	begin
			CheckReg_Task("JZ 2");
			end	
		7:	begin
			ExpectRegVals[3] = 32'hFF000000;			
			CheckReg_Task("LUI R3, #FF00h");
			end
		8:	begin
			ExpectRegVals[4] = 32'hAA000000;			
			CheckReg_Task("AND R4, R3, R0");
			end
		9:	begin
			CheckReg_Task("JNZ 10h");
			end
		11:	begin
			CheckReg_Task("JMP 20h");
			end
		13: begin
			ExpectRegVals[5] = 32'h12340000;			
			CheckReg_Task("LUI R5, #1234h");
			end
		14: begin
			CheckReg_Task("JMP 2Ch");
			end			
		16: begin
			ExpectRegVals[6] = 32'h12345678;			
			CheckReg_Task("ADDI R6, R5, #5678h");
			end
		17: begin
			ExpectRegVals[7] = 32'hFF345678;			
			CheckReg_Task("OR R7, R6, R3");
			end
		18: begin
			CheckReg_Task("JNEG 0Ch");
			end
		20: begin
			ExpectRegVals[6] = 32'h00005678;			
			CheckReg_Task("SUB R6, R6, R5");
			end
		21: begin
			CheckReg_Task("JPOS -04h");
			end
		23: begin
			ExpectRegVals[6] = 32'hEDCC5678;			
			CheckReg_Task("SUB R6, R6, R5");			
			end
		24: begin
			CheckReg_Task("JPOS -04h");
			end
		25: begin
			ExpectRegVals[6] = 32'h00005678;			
			CheckReg_Task("ADD R6, R6, R5");			
			end
		26: begin
			ExpectRegVals[7] = 32'hFF345000;			
			CheckReg_Task("SUBI R7, R7, #678h");			
			end
		27: begin
			ExpectRegVals[15] = 32'h00000054;			
			CheckReg_Task("CALL 190h");			
			end
		29: begin
			ExpectRegVals[8] = 32'h00005000;
			CheckReg_Task("ANDI R8, R7, #FF00h");				
			end
		30: begin
			CheckReg_Task("LDPC R15");			
			end
		32: begin
			ExpectRegVals[10] = 32'h00000000;
			CheckReg_Task("LUI R10, #00h");			
			end
		33: begin
			ExpectRegVals[10] = 32'h00000064;
			CheckReg_Task("ORI R10, R10, #0064h");				
			end
		34: begin
			CheckMem_Task(9'h64, 32'hAAAAAAAA, "ST [R10], R0");
			end
		35: begin
			ExpectRegVals[11] = 32'hAAAAAAAA;
			CheckReg_Task("LD R11, [R10]");			
			end
		36: begin
			ExpectFPRegVals[0] = 43'h000_00005678;
			CheckReg_Task("TRNS.GET FR0, {R7,R6} | NOP");
			end
		37: begin
			ExpectRegVals[12] = 32'h00005678;
			ExpectRegVals[13] = 32'h00000000;
			ExpectFPRegVals[1] = 43'h054_00000000;
			CheckReg_Task("TRNS.SEND {R13, R12}, FR0 | TRNS.GET FR1, {R15, R14}");
			end
		38: begin
			ExpectFPRegVals[10] = 43'h054_00000000;
			ExpectFPRegVals[12] = 43'h000_00005678;
			CheckReg_Task("FMOV FR10, FR1 | FMOV FR12, FR0");
			end	
		39: begin
			ExpectFPRegVals[2] = 43'h2AA_AAAA_AAAA;
			
			ExpectFPRegVals[2] = 43'h000_0000_0000;
			
			CheckReg_Task("FADD.SEND FR1, FR12 | FADD.GET FR2");
			end							
		40: begin
			ExpectFPRegVals[3] = 43'h1BB_BBBB_BBBB;
			
			ExpectFPRegVals[3] = 43'h000_0000_0000;	
				
			CheckReg_Task("FSUB.GET FR3 | FSUB.SEND FR1, FR12");
			end
		41: begin
			ExpectFPRegVals[4] = 43'h255_5555_5555;
			ExpectFPRegVals[5] = 43'h7AA_5555_BBBB;
			
			ExpectFPRegVals[4] = 43'h00000000000;
			ExpectFPRegVals[5] = 43'h3ffc0000000;			
			ExpectFPRegVals[5] = 43'h00000000000;
						
			CheckReg_Task("FMUL.GET FR4 | FDIV.GET FR5");
			end
		42: begin
			ExpectFPRegVals[6] = 43'h1AC_A32A_A5FA;
			ExpectFPRegVals[7] = 43'h3AA_5555_BBBB;
			
			ExpectFPRegVals[6] = 43'h00000000000;
			ExpectFPRegVals[7] = 43'h3ffc0000000;
			ExpectFPRegVals[7] = 43'h00000000000;

			CheckReg_Task("FSQRT.GET FR6 | FABS.GET FR7, FR5");
			end
		43: begin
			ExpectFPRegVals[8] = 43'h3AA_5555_BBBB;
			ExpectFPRegVals[9] = 43'h5AC_A32A_A5FA;
			
			ExpectFPRegVals[8] = 43'h3ffc0000000;
			ExpectFPRegVals[9] = 43'h40000000000;
			ExpectFPRegVals[8] = 43'h00000000000;
									
			CheckReg_Task("FABS.GET FR8, FR7 | FOPP.GET FR9, FR6");
			end
		44: begin
			ExpectRegVals[0] = 32'hAAAA0000;
			CheckReg_Task("LUI R0, #AAAAh");
			end
		45: begin
			ExpectRegVals[1] = 32'h00000001;
			CheckReg_Task("SVFL R1");			
			end
		46: begin
			ExpectRegVals[0] = 32'h00000000;
			CheckReg_Task("LUI R0, #0000h");
			end
		47: begin
			ExpectRegVals[2] = 32'h00000004;
			CheckReg_Task("SVFL R2");			
			end
		48: begin
			ExpectRegVals[0] = 32'h0000AAAA;
			CheckReg_Task("ORI R0, R0, #AAAAh");
			end
		49: begin
			ExpectRegVals[3] = 32'h00000002;
			CheckReg_Task("SVFL R3");			
			end
		50: begin
			ExpectRegVals[1] = 32'h00000000;
			CheckReg_Task("LUI R1, #0000h");			
			end
		51: begin
			ExpectRegVals[1] = 32'h000004AA;
			CheckReg_Task("ORI R1, R1, #04AAh");			
			end
		52: begin
			ExpectFPRegVals[0] = 43'h4AA0000AAAA;
			CheckReg_Task("TRNS.GET FR0, {R1,R0} || FNOP");			
			end			
		53: begin
			ExpectRegVals[2] = 32'h00000001;
			CheckReg_Task("FSVFL R2 || FNOP");			
			end
		54: begin
			ExpectRegVals[1] = 32'h000000AA;
			CheckReg_Task("ANDI R1, R1, #03FFh");			
			end
		55: begin
			ExpectFPRegVals[0] = 43'h0AA0000AAAA;
			CheckReg_Task("TRNS.GET FR0, {R1,R0} || FNOP");			
			end				
		56: begin
			ExpectRegVals[3] = 32'h00000002;
			CheckReg_Task("FSVFL R3 || FNOP");			
			end
		57: begin
			ExpectRegVals[1] = 32'h00000000;
			CheckReg_Task("LUI R1, #0000h");			
			end	
		58: begin
			ExpectRegVals[0] = 32'h00000000;
			CheckReg_Task("LUI R0, #0000h");			
			end	
		59: begin
			ExpectFPRegVals[0] = 43'h00000000000;
			CheckReg_Task("FNOP || TRNS.GET FR0, {R1,R0}");			
			end
		60: begin
			ExpectRegVals[4] = 32'h00000004;
			CheckReg_Task("FNOP || FSVFL R4");			
			end
		61: begin
			ExpectRegVals[14] = 32'h00000000;
			CheckReg_Task("LUI R14, #0000h");			
			end
		62: begin
			ExpectRegVals[14] = 32'h000001FC;
			CheckReg_Task("ORI R14, R14, #01FCh (#508, dMem[127])");			
			end
		63: begin
			ExpectRegVals[1] = 32'hAAAA0000;
			CheckReg_Task("LUI R1, #AAAAh");			
			end			
		64: begin
			ExpectRegVals[2] = 32'h00000000;
			CheckReg_Task("LUI R2, #0000h");			
			end	
		65: begin
			ExpectRegVals[14] = 32'h000001F8;
			CheckReg_Task("PUSH R1 (1/2)");
			CheckMem_Task(9'h1FC, 32'hAAAA0000, "PUSH R1 (2/2)");
			end				
		66: begin
			ExpectRegVals[14] = 32'h000001FC;
			ExpectRegVals[2] = 32'hAAAA0000;
			CheckReg_Task("POP R2");
			end
		67: begin
			ExpectRegVals[1] = 32'h00000000;
			CheckReg_Task("LUI R1, #0000h");			
			end
		68: begin
			ExpectRegVals[1] = 32'h0000000A;
			CheckReg_Task("ORI R1, R1, #000Ah");			
			end
		69: begin
			ExpectRegVals[0] = 32'h5aa50000;
			CheckReg_Task("LUI R0, #5AA5h");			
			end
		70: begin
			ExpectRegVals[0] = 32'h5aa52345;
			CheckReg_Task("ORI R0, R0, #2345h");			
			end
		71: begin
			ExpectFPRegVals[1] = 43'h00a5aa52345;
			CheckReg_Task("FNOP || TRNS.GET FR1, {R1,R0}");			
			end
		72: begin
			ExpectFPRegVals[2] = 43'h00000000000;
			CheckReg_Task("FNOP || FMOV FR2,FR0");			
			end				
		73: begin
			ExpectRegVals[10] = 32'h00000000;
			CheckReg_Task("LUI R10, #0000h");			
			end
		74: begin
			ExpectRegVals[10] = 32'h00000064;
			CheckReg_Task("ORI R10, R10, #0064h");			
			end
		75: begin
			ExpectRegVals[11] = 32'h00000064;
			CheckReg_Task("ORI R11, R10, #0000h");			
			end
		76: begin
			CheckMem_Task(9'h64, 32'h5aa52345, "FMEM.SEND.L [R10], FR1");			
			end			
		77: begin
			CheckMem_Task(9'h68, 32'h0000000A, "FMEM.SEND.H [R10], FR1");
			end
		78: begin
			ExpectFPRegVals[2] = 43'h0005aa52345;
			CheckReg_Task("FMEM.GET.L FR2, [R11]");			
			end			
		79: begin
			ExpectFPRegVals[2] = 43'h00a5aa52345;
			CheckReg_Task("FMEM.GET.H FR2, [R11]");			
			end
		80: begin
			ExpectRegVals[14] = 32'h000001F8;
			CheckReg_Task("FSTK.SEND.L FR2 (1/2)");
			CheckMem_Task(9'h1FC, 32'h5AA52345, "FSTK.SEND.L FR2 (2/2)");
			end
		81: begin
			ExpectRegVals[14] = 32'h000001F4;
			CheckReg_Task("FSTK.SEND.H FR2 (1/2)");
			CheckMem_Task(9'h1F8, 32'h0000000A, "FSTK.SEND.H FR2 (2/2)");
			end
		82: begin
			ExpectRegVals[14] = 32'h000001F0;
			CheckReg_Task("PUSH R6 (1/2)");
			CheckMem_Task(9'h1F4, 32'h00005678, "PUSH R6 (2/2)");
			end			
		83: begin
			ExpectRegVals[14] = 32'h000001F4;
			ExpectFPRegVals[3] = 43'h00000005678;
			CheckReg_Task("FNOP || FSTK.GET.L FR3");
			end
		84: begin
			ExpectRegVals[14] = 32'h000001F8;
			ExpectFPRegVals[3] = 43'h00A00005678;
			CheckReg_Task("FNOP || FSTK.GET.H FR3");
			end
		85: begin
			CheckReg_Task("JMP 128h");
			end				
		default: ;
		endcase
	end

endmodule
