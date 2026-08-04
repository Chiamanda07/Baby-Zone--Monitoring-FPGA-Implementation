`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2026 03:40:31 PM
// Design Name: 
// Module Name: edge_simplified
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

//Sobel's kernel was used for the edge detection
module edge_simplified(
    input  [7:0] p00, p01, p02,   //[7:0] because they are all 8 bits
    input  [7:0] p10, p11, p12,
    input  [7:0] p20, p21, p22,
    input valid,                 // could be 1 or 0 signifying the inputs are neighbors
    output [10:0] G                 //The output is going to be 11 bits
);

    wire signed [10:0] Gx;  // the output is going to be 10 bits, but since its signed we're using 11 bits
    wire signed [10:0] Gy;

    assign Gx = (p02 + 2*p12 + p22) - (p00 + 2*p10 + p20);
    assign Gy = (p20 + 2*p21 + p22) - (p00 + 2*p01 + p02);

    assign G = valid ?((Gx[10] ? -Gx : Gx) + (Gy[10] ? -Gy : Gy)) : 0; // G = |Gx| + |Gy|, i.e if the MSB is 1 then we do the negative, if 0 it remains the same

endmodule