`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2026 04:00:00 PM
// Design Name: 
// Module Name: grayscale_tb
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


module grayscale_tb;

    reg [7:0] R, G, B;
    wire [7:0] Y;

    grayscale uut (
        .R(R), .G(G), .B(B), .Y(Y)
    );

    initial begin
        $display("R=%0d G=%0d B=%0d | Y=%0d", R, G, B, Y);
        
        R=255; G=0;   B=0;   #10;
        $display("R=%0d G=%0d B=%0d | Y=%0d (expected 73)", R, G, B, Y);
        
        R=0;   G=255; B=0;   #10;
        $display("R=%0d G=%0d B=%0d | Y=%0d (expected 146)", R, G, B, Y);
        
        R=0;   G=0;   B=255; #10;
        $display("R=%0d G=%0d B=%0d | Y=%0d (expected 25)", R, G, B, Y);
        
        R=0;   G=0;   B=0;   #10;
        $display("R=%0d G=%0d B=%0d | Y=%0d (expected 0)", R, G, B, Y);
        
        R=255; G=255; B=255; #10;
        $display("R=%0d G=%0d B=%0d | Y=%0d (expected 244)", R, G, B, Y);
        
        $finish;
    end

endmodule