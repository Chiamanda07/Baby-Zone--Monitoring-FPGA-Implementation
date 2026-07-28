`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2026 11:01:05 PM
// Design Name: 
// Module Name: thresh_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module thresh_tb();
reg [10:0]A;
reg [10:0]thresh;
wire [7:0]Y;
threshold dut(.A(A), .thresh(thresh), .Y(Y));

initial begin
    A = 155; thresh = 200; #10;
    $display ("With A = %0d and thresh = %0d | Y = %0d (expected = 0)", A, thresh, Y);
    A = 203; thresh = 200;  #10;
    $display ("With A = %0d and thresh = %0d | Y = %0d (expected = 255)", A, thresh, Y);
    A = 200; thresh = 200;  #10;
    $display ("With A = %0d and thresh = %0d | Y = %0d (expected = 255)", A, thresh, Y);
    $finish;
end
endmodule
