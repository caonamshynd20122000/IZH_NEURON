`timescale 1ns / 1ps
module neuron_izh(
  input 	clk,
  input		rst,
  input [31:0]	vi,
  input [31:0]	ui,
  input [31:0]  I,
  input [31:0]	h,
  input [31:0]  a,
  input [31:0]	b
);
  wire [31:0] 	v_next, u_next, u_next_d;
  wire [31:0]	u,v;
  wire		spike;
  wire		result_compare;
  wire [31:0]	ge = 32'h41f00000; // ge = 30 mV;
  wire [31:0]	c  = 32'hc2820000; // c  = -65 mV;
  wire [31:0]	d  = 32'h40000000; // c  = 2;

  reg [31:0]    u_reg, v_reg;  // Registers to store u and v
  reg [31:0]    v_out, u_out;
  assign spike = (result_compare) ? 1'b1 & (~v_next[31]) : 1'b0 & (~v_next[31]);
  assign u = u_reg;
  assign v = v_reg;

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
  
  always@(*) begin
    if(spike == 1) begin
      v_out = c;
      u_out = u_next_d;
    end
    else begin
      v_out = v_next;
      u_out = u_next;
    end
  end

  always@(posedge clk or posedge rst) begin
    if(rst) begin
      u_reg <= ui;
      v_reg <= vi;
    end
    
    else begin
      v_reg <= v_out;
      u_reg <= u_out;
    end
  end

endmodule
