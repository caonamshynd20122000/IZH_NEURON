// 32-bit Floating-Point Adder (IEEE 754) in Verilog
`timescale 1ns / 1ps
module adder (
    input [31:0] a, // First 32-bit floating-point number
    input [31:0] b, // Second 32-bit floating-point number
    output reg [31:0] result // 32-bit floating-point result
);
    // Extract components of IEEE 754 format
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mantissa_a = (a[30:23] == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]}; // Handle denormals
    wire [23:0] mantissa_b = (b[30:23] == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]}; // Handle denormals

    // Step 1: Align exponents
    wire [7:0] exp_diff;
    wire [23:0] aligned_mantissa_a, aligned_mantissa_b;
    wire [7:0] larger_exp;

    assign exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    assign larger_exp = (exp_a > exp_b) ? exp_a : exp_b;
    assign aligned_mantissa_a = (exp_a > exp_b) ? mantissa_a : (mantissa_a >> exp_diff);
    assign aligned_mantissa_b = (exp_b > exp_a) ? mantissa_b : (mantissa_b >> exp_diff);

    // Step 2: Perform addition or subtraction based on signs
    wire [24:0] mantissa_sum;
    reg [24:0] abs_mantissa_a, abs_mantissa_b;
    reg operation_sign;

    always @(*) begin
        if (aligned_mantissa_a >= aligned_mantissa_b) begin
            abs_mantissa_a = {1'b0, aligned_mantissa_a};
            abs_mantissa_b = {1'b0, aligned_mantissa_b};
            operation_sign = sign_a;
        end else begin
            abs_mantissa_a = {1'b0, aligned_mantissa_b};
            abs_mantissa_b = {1'b0, aligned_mantissa_a};
            operation_sign = sign_b;
        end
    end

    assign mantissa_sum = (sign_a == sign_b) ?
        (aligned_mantissa_a + aligned_mantissa_b) :
        (abs_mantissa_a - abs_mantissa_b);

    // Step 3: Normalize the result (sửa while thành for)
    reg [7:0] result_exp;
    reg [23:0] result_mantissa;
    reg result_sign;

    integer shift_count;

    always @(*) begin
        if (mantissa_sum[24]) begin
            // Shift right if there's a carry-out
            result_mantissa = mantissa_sum[24:1];
            result_exp = larger_exp + 1;
        end else begin
            // Normalize by shifting left using fixed iteration
            result_mantissa = mantissa_sum[23:0];
            result_exp = larger_exp;

            for (shift_count = 0; shift_count < 24; shift_count = shift_count + 1) begin
                if (result_mantissa[23] == 1'b0 && result_exp > 0) begin
                    result_mantissa = result_mantissa << 1;
                    result_exp = result_exp - 1;
                end
            end
        end
        result_sign = (mantissa_sum == 0) ? 0 : operation_sign;
    end

    // Step 4: Handle special cases (zero cases)
    always @(*) begin
        if (a[30:0] == 0)
            result = b;
        else if (b[30:0] == 0)
            result = a;
        else
            result = {result_sign, result_exp, result_mantissa[22:0]};
    end

endmodule
