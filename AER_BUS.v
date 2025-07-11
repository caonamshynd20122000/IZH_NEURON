module AER_BUS #(parameter NEURON_ADR = 8, NEURON_NUM = 8)(

	input	wire						CLK,
	input	wire	[NEURON_NUM:0]		SPIKES,
	output	reg							EN_NEURON,
	output	reg		[NEURON_ADR:0]		ADDR
	);

	reg				[NEURON_NUM:0]		MEMORY	[0:7];
	reg				[NEURON_NUM:0]		FIFO_IN, FIFO_OUT;
	reg				[2:0]				FIFO_PTR = 3'b000;
	reg				[NEURON_NUM:0]		ENC_IN, ENC_SPIKES = {NEURON_NUM + 1{1'b0}};
	reg				[NEURON_ADR:0]		ENC_OUT = {NEURON_ADR + 1{1'b0}};
	reg									FIFO_EN = 1'b0;

	// FIFO

	always @(posedge CLK) begin
		FIFO_IN <= SPIKES;
		if(FIFO_EN) begin
			if(FIFO_PTR > 3'b000) begin
				FIFO_OUT <= MEMORY[0];
				for(integer i = 0; i < 7; i = i + 1) begin
					
					MEMORY[i] <= MEMORY[i + 1];
				end

				if(FIFO_IN > 0) begin
					
					MEMORY[FIFO_PTR] <= FIFO_IN;
				end
				else begin
					
					FIFO_PTR <= FIFO_PTR - 1;
				end
			end

			else begin
				FIFO_OUT <= FIFO_IN;
			end

		end

		else if (FIFO_PTR != 3'b110 && FIFO_IN > 0) begin
			FIFO_PTR <= FIFO_PTR + 1;
			MEMORY[FIFO_PTR] <= FIFO_IN;
		end
	end

	// Demux of Spikers

	always @(*) begin
		if(FIFO_EN)
			ENC_IN = FIFO_OUT;
		else
			ENC_IN = ENC_SPIKES;
	end

	// Encoder
reg found;
always @(posedge CLK) begin
	integer i;
	found = 0;
	for(i = 0; i <= NEURON_NUM; i = i + 1) begin
		if (!found && ENC_IN[i] == 1'b1) begin
			ENC_OUT <= i[NEURON_ADR:0];
			ENC_SPIKES <= ENC_IN;
			ENC_SPIKES[i] <= 1'b0;
			found = 1;
		end
	end

	// If no spike found
	if (!found) begin
		ENC_OUT <= {NEURON_ADR + 1{1'b1}};
	end
end


	assign ADDR = ENC_OUT;
	assign FIFO_EN = (ENC_SPIKES == {NEURON_NUM+1{1'b0}}) ? 1'b1: 1'b0;

	// Neuron's Enable
	always @(posedge CLK) begin
		if(FIFO_EN)
			EN_NEURON <= 1'b1;
		else
			EN_NEURON <= 1'b0;
	end

endmodule : AER_BUS