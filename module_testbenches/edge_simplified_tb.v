`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2026 03:54:28 PM
// Design Name: 
// Module Name: edge_simplified_tb
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


module edge_simplified_tb;

    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;
    reg valid;
    wire [10:0] G;

    edge_simplified dut (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .valid(valid),
        .G(G)
    );

    initial begin
     
        // Test 1: flat region - all pixels same value, expect G = 0
        valid = 1;
        p00=100; p01=100; p02=100;
        p10=100; p11=100; p12=100;
        p20=100; p21=100; p22=100; #10;
        $display("Flat region | G=%0d (expected 0)", G);
        
        // Test 2: vertical edge 
        p00=50; p01=100; p02=100;
        p10=50; p11=100; p12=100;
        p20=50; p21=100; p22=100; #10;
        $display("Vertical edge | G=%0d (expected 200)", G);
        
        // Test 2: sharp vertical edge 
        p00=00; p01=0; p02=255;
        p10=00; p11=0; p12=255;
        p20=00; p21=0; p22=255; #10;
        $display("Vertical edge | G=%0d (expected 1020)", G);
        
        // Test 3: sharp horizontal edge
        p00=0; p01=0; p02=0;
        p10=0; p11=0; p12=0;
        p20=255; p21=255; p22=255; #10;
        $display("Flat region | G=%0d (expected 1020)", G);
        $finish;
    end

endmodule