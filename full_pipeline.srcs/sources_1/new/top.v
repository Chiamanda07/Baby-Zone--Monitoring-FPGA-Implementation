`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 04:31:44 PM
// Design Name: 
// Module Name: top
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


module top#(
    parameter EDGE_THRESH = 500  // tune this experimentally
)(
    input [7:0] R, G, B,  // from camera
    input clk,
    input rst,
    output alert
    );
    
    wire [7:0] gray_pixel;
    wire [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;
    wire [9:0] col, row;
    wire valid;
    wire [10:0] edge_strength;
    wire [7:0] Y;
    wire present;
    
    
    grayscale gray_inst (
        .R(R),
        .G(G),
        .B(B),
        .Y(gray_pixel)
    );
    
    line_buffer #(.WIDTH(640), .HEIGHT(480)) line_inst (
        .clk(clk),
        .rst(rst),
        .pixel_in(gray_pixel),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .valid(valid),
        .row_count_out(row), .col_count_out(col)
    );
    
    
    edge_simplified edge_inst(
        .p00(p00),.p01(p01), .p02(p02),   
        .p10(p10), .p11(p11),.p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .valid(valid),                 
        .G(edge_strength)
    );
    
    threshold thresh_inst(
        .A(edge_strength),
        .thresh(EDGE_THRESH),
        .Y(Y)
    );
    
    zone_detect #(
        .edge_thresh(100),
        .row_min(320),
        .row_max(400),
        .col_min(200),
        .col_max(420)
    ) zone_inst (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .pixel(Y),
        .col(col),
        .row(row),
        .present(present)
    );
    
    timer timer_inst (
        .clk(clk),
        .rst(rst),
        .present(present),
        .alert(alert)
    );
    
endmodule
