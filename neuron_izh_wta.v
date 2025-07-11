
module NEURON_WTA #(
	parameter			DIFF_SPIKES = 9

)(
	input 				CLK,
	input 				RST,
	input	[DIFF_SPIKES:0]		DIFF_SPIKE,
	input [31:0]	I,
	
	output reg 		SPIKE
);

	wire [31:0]		v_next, u_next, u_next_d;
	wire [31:0]		u, v;
	wire			spike, spike_compare, spike_temp;
	wire			or_spike, fb_spike;
	wire			result_compare;

  wire [31:0]	ge = 32'h41f00000; // ge = 30 mV;
  wire [31:0]	c  = 32'hc2820000; // c  = -65 mV;
  wire [31:0]	d  = 32'h41000000; // d  = 8;
  wire [31:0]	ui = 32'hc1500000; // 
  wire [31:0]	vi = 32'hc2ae0000; //
  wire [31:0]	h = 32'h3e4ccccd; //
  wire [31:0]	a = 32'h3ca3d70a; //
  wire [31:0]	b = 32'h3e800000; //


	reg [31:0]		u_reg, v_reg;
	reg [31:0]		v_out, u_out;


	assign spike_compare = (result_compare) ? 1'b1&(~v_next[31]) : 1'b0 & (~v_next[31]);
	assign spike_temp = spike_compare ? 1'b1 : 1'b0;
	assign or_spike = |DIFF_SPIKE;
	assign spike = or_spike ? 1'b0 : spike_temp;
	assign fb_spike = spike_compare | or_spike;
	assign u = u_reg;
	assign v = v_reg;

	assign SPIKE = spike;

  // Instance compare v_next & ge
  compare_ieee754 uut_compare(
	.num1(v_next),
	.num2(ge),
	.result(result_compare)
);

  // Instance membrane module
 
  membrane uut_mem (
	.v(v),
	.u(u),
	.I(I),
	.h(h),
	.post_v(v_next)
);

  // Instance restoration module
  
  restoration uut_res (
	.v(v),
	.u(u),
	.a(a),
	.b(b),
	.h(h),
	.post_u(u_next)
);

  // Instance u_next add d
  adder add_unextd(
	.a(u_next),
	.b(d),
	.result(u_next_d)
);

  always @(*) begin
  	if(fb_spike == 1) begin
  		v_out = c;
  		u_out = u_next_d;
  	end
  	else begin
  		v_out = v_next;
  		u_out = u_next;
  	end
  end

  always@(posedge CLK or posedge RST) begin
  	if(RST) begin
      u_reg <= ui;
      v_reg <= vi;
    end
    
    else begin
      v_reg <= v_out;
      u_reg <= u_out;
    end
  end

endmodule : NEURON_WTA