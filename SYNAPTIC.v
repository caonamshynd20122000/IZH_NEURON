`timescale 1ns / 1ps
module SYNAPTIC (
	input				CLK,
	input				EN,
	input 		[31:0]	SYNAPTIC_IN,
	output	reg [31:0]	I

);

	reg 		[31:0]	I_STORE	[1:0];
	wire				result_compare;
	wire		[31:0]	add_synap;
	// Instance compare module I_STORE[0] with -14 
	compare_ieee754 uut_compare(
	.num1(I_STORE[0]),
	.num2(32'hc1600000),
	.result(result_compare)
	);

	  adder add_unextd(
	.a(I_STORE[0]),
	.b(SYNAPTIC_IN),
	.result(add_synap)
);

	always @(posedge CLK) begin
		if(EN) begin
			I_STORE[0] <= SYNAPTIC_IN;
			I <= I_STORE[1];

			if(result_compare) begin
				I_STORE[1] <= I_STORE[0];
			end

			else begin
				I_STORE[1] <= 32'hc1600000;
			end			
		end 

		else begin
			I_STORE[0] <= add_synap;	
		end

	end

endmodule
