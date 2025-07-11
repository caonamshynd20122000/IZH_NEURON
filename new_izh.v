`timescale 1ns / 1ps
module IZH_NEURON #(
	parameter			NUMBER = 1,
	parameter 			WIDTH = 16,
	parameter 			NEURON_ADR = 4,
	parameter 			WEIGHTS = 8,
	parameter			DIFF_SPIKES = 9
)(
	input						CLK,
	input						RST,
	input						EN,
	input						WE,
	input		[NEURON_ADR:0]	A,
	input		[5:0]			DPRA,
	input		[31:0]			DI,
	input 		[DIFF_SPIKES:0]	DIFF_SPIKE,

	output		reg		SPIKE
);
	
	wire		[31:0]	DPO, I;
	wire				spike;

	// Instance RAM

	RAM #(
		.NUMBER(NUMBER),
		.WIDTH(WIDTH),
		.NEURON_ADR(NEURON_ADR),
		.WEIGHTS(WEIGHTS)
	) uut_RAM (
        .clk(CLK),
        .we(WE),
        .a(A),
        .dpra(DPRA),
        .di(DI),
        .dpo(DPO)
    );

    // Instance Synaptic

    SYNAPTIC uut_SYNAPTIC(
    	.CLK(CLK),
    	.EN(EN),
    	.SYNAPTIC_IN(DPO),
    	.I(I)

    );

    NEURON_WTA #(
    	.DIFF_SPIKES(DIFF_SPIKES)
    )uut_NEURON_WTA(
    	.CLK(CLK),
    	.RST(RST),
    	.I(I),
    	.DIFF_SPIKE(DIFF_SPIKE),
    	.SPIKE(spike)
    );

    always @(posedge CLK) begin
    	SPIKE <= spike;  // Non-blocking assignment
    end

endmodule : IZH_NEURON