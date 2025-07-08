`timescale 1ns / 1ps
module restoration(
    input[31:0] v,
    input[31:0] u,
    input[31:0] a,
    input[31:0] b,
    input[31:0] h,
    output[31:0] post_u
);
  
    wire [31:0] rmul_vb, radd_vbu, rmul_vbua, rmul_vbuah,radd_vbuahu;
    wire [31:0] inverted_u;

    // Module mul to calculate v * b
    mul mul_vb(
        .a(v),
        .b(b),
        .result(rmul_vb)
    );

    // Invert u
    assign inverted_u = {~u[31], u[30:0]};

    // Add rmul_vb with ~u
    adder add_vbu (
        .a(rmul_vb),
        .b(inverted_u),
        .result(radd_vbu)
    );

    // Module mul to calculate vbu * a
    mul mul_vbua(
        .a(radd_vbu),
        .b(a),
        .result(rmul_vbua)
    );

    // Module mul to calculate vbua * h
    mul mul_vbuah(
        .a(rmul_vbua),
        .b(h),
        .result(rmul_vbuah)
    );

    // Add vbuah with u
    adder add_vbuah (
        .a(rmul_vbuah),
        .b(u),
        .result(radd_vbuahu)
    );

    assign post_u = radd_vbuahu;
endmodule
