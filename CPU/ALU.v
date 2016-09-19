module ALU (a, b, func, result);

input	[31:0] 	a, b;
input	[3:0] 	func;
output	[31:0] 	result;
reg		[31:0]	result;

always @ ( * )
	case (func)
		0:	result = a & b;
		1:	result = a | b;
		2:	result = a ^ b;
		3:	result = a + b;
		4:	result = a - b;
		default:	result = 0;
	endcase

endmodule
