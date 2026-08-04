`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2026 11:47:02 PM
// Design Name: 
// Module Name: timer
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


module timer #(parameter timer_thresh = 600)(
    input clk,
    input rst,
    input end_of_frame,
    input present,
    output reg alert
);

    reg [11:0] count;

    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            alert <= 0;
        end else begin
            if (end_of_frame) begin
                if (present == 0)
                    count <= count + 1;
                else
                    count <= 0;
            end
    
            if (count >= timer_thresh)
                alert <= 1;
        end
    end

endmodule