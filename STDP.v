module STDP #(

	parameter														NEURON_ADR			= 8,
	parameter														WEIGHTS				= 8,
	parameter														INPUT_NEURON_NUM	= 32,
	parameter														TRAINING_NEURON_NUM	= 23,
	parameter														PRE_REG				= 15,
	parameter														POST_REG			= 5
)(

	input 															CLK,
	input 															RST,
	input 															EN,
	input 															EN_ADDR,
	input 			[INPUT_NEURON_NUM - TRAINING_NEURON_NUM : 0]	PRE_SPIKES,
	input 															POST_SPIKE,
	output	reg 													WE,
	output 	reg 	[NEURON_ADR : 0]								ADDR,
	output	reg 	[WEIGHTS : 0]									WEIGHT
);

	// Internal signals
	reg 	[PRE_REG:0]													PRE_SHIFT_REG;
	reg 	[POST_REG:0]													POST_SHIFT_REG;
	reg 															PRE_SPIKE, DECR_SEL, INCR_SEL;
	wire															PRE_GATE, POST_GATE, DECR, INCR;
	reg 	[NEURON_ADR : 0]										SYN_ADDR = {NEURON_ADR + 1{1'b1}};

	localparam MEM_SIZE = INPUT_NEURON_NUM - TRAINING_NEURON_NUM + 1;

	reg 	[WEIGHTS : 0 ] SYN_WEIGHT [0 : MEM_SIZE - 1];


	wire															result_compare_10, result_compare_30;
	wire	[WEIGHTS : 0]											add_syn_1, add_syn_n_1;

	// Synaptic Address Counter
	always @(posedge CLK) begin
		if(EN) begin
			if(EN_ADDR) begin
				if(SYN_ADDR == MEM_SIZE - 1) begin
					SYN_ADDR <= 0;
				end
				else begin
					SYN_ADDR <= SYN_ADDR + 1;
				end
			end
		end
		// else begin
		// 	SYN_ADDR <= 0;
		// end
	end

    always @(*) begin
        PRE_SPIKE = PRE_SPIKES[SYN_ADDR];
        ADDR = SYN_ADDR;
    end

	// always @(posedge CLK) begin
    // 	if (RST) 
    //     	PRE_SPIKE <= 0;
    // 	else if (EN_ADDR) 
    //     	PRE_SPIKE <= PRE_SPIKES[SYN_ADDR];  // Capture giá trị
    // 	else 
    //     	PRE_SPIKE <= 0;  // Reset về 0 ngay sau đó
	// end


	// Pre - Spike Shift Register
    integer i;
	always @(posedge CLK) begin
		if(RST) begin
			PRE_SHIFT_REG	<= 0;

		end

		else if(EN) begin
			PRE_SHIFT_REG[PRE_REG] <= PRE_SPIKE;
			for(i = PRE_REG - 1; i>=0; i = i - 1)
				PRE_SHIFT_REG[i] <= PRE_SHIFT_REG[i+1];
		end
	end
	assign PRE_GATE = |PRE_SHIFT_REG;

	// Post - Spike Shift Register

	always @(posedge CLK) begin
		if(RST) begin
			POST_SHIFT_REG	<= 0;
		end

		else if (EN) begin
			POST_SHIFT_REG[POST_REG] <= POST_SPIKE;
			for(i = POST_REG - 1; i >= 0; i = i - 1)
				POST_SHIFT_REG[i] <= POST_SHIFT_REG[i+1];
		end
	end
	assign POST_GATE = |POST_SHIFT_REG;

	// I/D Select Logic

	always @(posedge CLK) begin
		if(RST) begin
			INCR_SEL <= 0;
			DECR_SEL <= 0;
		end

		else if (EN) begin
			if(PRE_SPIKE) begin
				DECR_SEL <= 1;
				INCR_SEL <= 0;
			end
				
			else if (POST_SPIKE) begin
				INCR_SEL <= 1;
				DECR_SEL <= 0;
			end
		end
	end

	assign DECR = PRE_GATE & DECR_SEL & POST_GATE;
	assign INCR = PRE_GATE & INCR_SEL & POST_GATE;

	
	// Instance compare SYN_ADDR & -10
  	compare_ieee754 uut_compare_10(
		.num1(SYN_WEIGHT[SYN_ADDR]),
		.num2(32'hC1200000),
		.result(result_compare_10)
	);

	// Instance compare SYN_ADDR & 30
  	compare_ieee754 uut_compare_30(
		.num1(32'h41F00000),
		.num2(SYN_WEIGHT[SYN_ADDR]),
		.result(result_compare_30)
	);

	// Instance syn add 1
  	adder add_syn_one(
		.a(SYN_WEIGHT[SYN_ADDR]),
		.b(32'h3F800000),
		.result(add_syn_1)
	);

	// Instance syn add -1
  	adder add_syn_n_one(
		.a(SYN_WEIGHT[SYN_ADDR]),
		.b(32'hBF800000),
		.result(add_syn_n_1)
	);
  

	// Synaptic Weight Counter
	always @(posedge CLK) begin
		if(RST) begin
			for (i = 0; i < $size(SYN_WEIGHT); i = i + 1) begin
            	SYN_WEIGHT[i] <= 0;
        	end
			WE <= 1;
		end 

		else if (EN) begin
			if(DECR) begin
				if(result_compare_10) begin
					SYN_WEIGHT[SYN_ADDR] <= add_syn_n_1;
					WE <= 1;
				end
			end

			else if(INCR) begin
				if(result_compare_30) begin
					SYN_WEIGHT[SYN_ADDR] <= add_syn_1;
					WE <= 1;
				end
			end
			else begin
				WE <= 0;
			end
		end
	end

	always @(*) begin
		WEIGHT = SYN_WEIGHT[SYN_ADDR];
	end

endmodule:STDP