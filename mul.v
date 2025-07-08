`timescale 1ns / 1ps
module mul (
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] result
);
    reg [7:0] exp_a, exp_b, exp_result;
    reg [23:0] mant_a, mant_b;
    reg sign_a, sign_b, sign_result;
    reg [47:0] mant_mult;
    reg [8:0] exp_mult;
    reg [22:0] mant_result_final;

    always @(*) begin
        result = 32'b0;
        mant_mult = 0;
        exp_mult = 0;
        sign_result = 0;
        mant_result_final = 0;
        exp_result = 0;
        
        // Giải mã a
        sign_a = a[31];
        exp_a = a[30:23];
        mant_a = {1'b1, a[22:0]};

        // Giải mã b
        sign_b = b[31];
        exp_b = b[30:23];
        mant_b = {1'b1, b[22:0]};

        // Kiểm tra NaN
        if ((exp_a == 8'd255 && mant_a != 24'b0) || (exp_b == 8'd255 && mant_b != 24'b0)) begin
            result = 32'h7fc00000; // NaN
        end else if (a == 32'b0 || b == 32'b0) begin
            result = 32'b0;  // Kết quả là 0 nếu một trong hai số là 0
        end else if ((exp_a == 8'd255 && mant_a == 24'b0) || (exp_b == 8'd255 && mant_b == 24'b0)) begin
            // Trường hợp INF
            if (exp_a == 8'd255 && mant_a == 24'b0) begin
                if (exp_b == 8'd255 && mant_b == 24'b0) begin
                    result = 32'h7f800000; // +INF * +INF = +INF
                end else if (exp_b != 8'd255) begin
                    result = (sign_a ^ sign_b) ? 32'hff800000 : 32'h7f800000; // INF * số dương/âm
                end
            end else if (exp_b == 8'd255 && mant_b == 24'b0) begin
                if (exp_a != 8'd255) begin
                    result = (sign_a ^ sign_b) ? 32'hff800000 : 32'h7f800000; // số dương/âm * INF
                end
            end
        end else begin
            // Nhân mantissa
            mant_mult = mant_a * mant_b;

            // Tính toán mũ
            exp_mult = exp_a + exp_b - 8'd127;

            // Tính toán dấu của kết quả
            sign_result = sign_a ^ sign_b;

            // Xử lý trường hợp tràn mantissa
            if (mant_mult[47] == 1) begin
                mant_result_final = mant_mult[46:24];
                exp_mult = exp_mult + 1;
                exp_result = exp_mult[7:0];
            end else begin
                mant_result_final = mant_mult[45:23];
                exp_result = exp_mult[7:0];
            end

            // Xử lý tràn phần mũ (overflow)
            if (exp_result >= 8'd255) begin
                exp_result = 8'd255;
                mant_result_final = 23'b0;
            end

            // Xử lý trường hợp mũ dưới 0 (underflow)
            if (exp_result <= 8'd0) begin
                exp_result = 8'd0;
                mant_result_final = 23'b0;
            end

            // Ghép kết quả lại
            result = {sign_result, exp_result, mant_result_final};
        end
    end
endmodule
