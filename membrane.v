`timescale 1ns / 1ps

module membrane(
    input[31:0] v,
    input[31:0] u,
    input[31:0] I,
    input[31:0] h,
    output[31:0] post_v
);

    wire [31:0] rmul_vv, rmul_v004, rmul_v5, radd_v004v5, radd_v044v5u140I;
    wire [31:0] inverted_u, radd_u140,radd_v004v5u140, rmul_v044v5u140Ih, radd_v044v5u140Iv;
    wire [31:0] const_004 = 32'h3D23D70A; // 0.04 in IEEE 754
    wire [31:0] const_5   = 32'h40A00000; // 5 in IEEE 754
    wire [31:0] const_140 = 32'h430C0000; // 140 in IEEE 754

    // Module mul to calculate v * v
    mul mul_vv(
        .a(v),
        .b(v),
        .result(rmul_vv)
    );

    // Multiply v * 0.04
    mul mul_v004 (
        .a(rmul_vv),
        .b(const_004),
        .result(rmul_v004)
    );

    // Multiply v * 5
    mul mul_v5 (
        .a(v),
        .b(const_5),
        .result(rmul_v5)
    );

    // Adder to sum v*0.04 and v*5
    adder add_v004v5(
        .a(rmul_v004),
        .b(rmul_v5),
        .result(radd_v004v5)
    );

    // Invert u
    assign inverted_u = {~u[31], u[30:0]};

    // Add inverted u with 140
    adder add_u140 (
        .a(inverted_u),
        .b(const_140),
        .result(radd_u140)
    );

    // Add add_v004_v5 with add_u_140
    adder add_v044v5u140 (
        .a(radd_v004v5),
        .b(radd_u140),
        .result(radd_v004v5u140)
    );

    // Add v044v5_u140 with I
    adder add_v044v5u140I (
        .a(radd_v004v5u140),
        .b(I),
        .result(radd_v044v5u140I)
    );

    // Multiply radd_v044v5u140I * h
    mul mul_v044v5u140Ih (
        .a(radd_v044v5u140I),
        .b(h),
        .result(rmul_v044v5u140Ih)
    );

    // Add rmul_v044v5u140Ih with v
    adder add_v044v5u140Iv (
        .a(rmul_v044v5u140Ih),
        .b(v),
        .result(radd_v044v5u140Iv)
    );

    // Combine results for post_v
    assign post_v = radd_v044v5u140Iv;

endmodule


