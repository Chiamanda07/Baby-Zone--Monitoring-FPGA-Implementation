`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2026 12:38:27 AM
// Design Name: 
// Module Name: zone_detect_tb
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


`timescale 1ns / 1ps

module zone_detect_tb;

    reg clk, rst, valid;
    reg [7:0] pixel;
    reg [9:0] col, row;
    wire present;

    // Use small zone for testing
    zone_detect #(
        .edge_thresh(3),
        .row_min(1),
        .row_max(3),
        .col_min(1),
        .col_max(3)
    ) dut (
        .clk(clk), .rst(rst), .valid(valid),
        .pixel(pixel), .col(col), .row(row),
        .present(present)
    );

    always #5 clk = ~clk;

    integer r, c;

    initial begin
        clk = 0; rst = 1; valid = 0;
        pixel = 0; col = 0; row = 0;
        #10; rst = 0;

        // Test 1: enough edge pixels in zone - present should go high
        $display("Test 1: edges in zone");
        for (r = 0; r < 5; r = r + 1) begin
            for (c = 0; c < 5; c = c + 1) begin
                row = r; col = c;
                // put edge pixels inside zone
                if (r >= 1 && r <= 3 && c >= 1 && c <= 3)
                    pixel = 255;
                else
                    pixel = 0;
                valid = 1;
                #10;
            end
        end
        // one extra cycle after col_max+1
        #10;
        $display("present=%0d (expected 1)", present);

        // Reset between tests
        rst = 1; #10; rst = 0;

        // Test 2: no edge pixels in zone - present should stay low
        $display("Test 2: no edges in zone");
        for (r = 0; r < 5; r = r + 1) begin
            for (c = 0; c < 5; c = c + 1) begin
                row = r; col = c;
                pixel = 0; // no edges anywhere
                valid = 1;
                #10;
            end
        end
        #10;
        $display("present=%0d (expected 0)", present);

        // Reset between tests
        rst = 1; #10; rst = 0;

        // Test 3: edges outside zone only - present should stay low
        $display("Test 3: edges outside zone only");
        for (r = 0; r < 5; r = r + 1) begin
            for (c = 0; c < 5; c = c + 1) begin
                row = r; col = c;
                // edges only outside zone
                if (r >= 1 && r <= 3 && c >= 1 && c <= 3)
                    pixel = 0;
                else
                    pixel = 255;
                valid = 1;
                #10;
            end
        end
        #10;
        $display("present=%0d (expected 0)", present);

        $finish;
    end

endmodule