`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 05:31:10 PM
// Design Name: 
// Module Name: grayscale
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


module grayscale(
    input  [7:0] R,
    input  [7:0] G,
    input  [7:0] B,
    output [7:0] Y
);

    wire [9:0] r1 = (R >> 2) + (R >> 5) + (R >> 6);
    wire [9:0] g1 = (G >> 1) + (G >> 4) + (G >> 6) + (G >> 7);
    wire [9:0] b1 = (B >> 4) + (B >> 5) + (B >> 6) + (B >> 8);

    assign Y = r1 + g1 + b1;

endmodule
