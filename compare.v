`timescale 1ns / 1ps
module compare_ieee754 (
  input [31:0] num1, // Số thứ nhất (IEEE 754 single precision)
  input [31:0] num2, // Số thứ hai (IEEE 754 single precision)
  output reg result  // Kết quả so sánh
);

  // Kiểm tra NaN (Not a Number)
  wire num1_is_nan = (num1[30:23] == 8'b11111111) && (num1[22:0] != 23'b0);
  wire num2_is_nan = (num2[30:23] == 8'b11111111) && (num2[22:0] != 23'b0);

  // Kiểm tra dấu (sign bit)
  wire num1_is_negative = num1[31];
  wire num2_is_negative = num2[31];

assign result = 
    (num1_is_nan || num2_is_nan) ? 0 :  // Nếu một trong hai là NaN
    (num1 == num2) ? 1 :                // Nếu hai số bằng nhau
    (num1_is_negative && !num2_is_negative) ? 0 :  // Nếu num1 âm và num2 dương
    (!num1_is_negative && num2_is_negative) ? 1 :  // Nếu num1 dương và num2 âm
    (num1_is_negative && num2_is_negative) ? 
        (num1 > num2 ? 0 : 1) :  // Nếu cả hai đều âm
    (num1 > num2) ? 1 : 0;         // So sánh bình thường khi cả hai đều dương


endmodule
