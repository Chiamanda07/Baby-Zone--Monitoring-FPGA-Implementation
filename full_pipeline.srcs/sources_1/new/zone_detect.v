`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2026 12:05:10 AM
// Design Name: 
// Module Name: zone_detect
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


module zone_detect #(
    parameter edge_thresh = 100,
    parameter row_min = 320,
    parameter row_max = 400,
    parameter col_min = 200,
    parameter col_max = 420
)(
    input clk, valid, rst,
    input [7:0] pixel,
    input [9:0] col, row,
    output reg present,
    output reg end_of_frame
);

    reg [15:0] edge_count;

    always @(posedge clk) begin
        if (rst) begin
            edge_count   <= 0;
            present      <= 0;
            end_of_frame <= 0;
        end else begin
            if (valid && row >= row_min && row <= row_max &&
                col >= col_min && col <= col_max) begin
                if (pixel == 255)
                    edge_count <= edge_count + 1;
            end

            if (row == row_max && col == col_max + 1) begin
                present      <= (edge_count >= edge_thresh);
                edge_count   <= 0;
                end_of_frame <= 1;
            end else begin
                end_of_frame <= 0;
            end
        end
    end

endmodule