`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2026 11:48:08 PM
// Design Name: 
// Module Name: timer_tb
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

module timer_tb;

    reg clk, rst, present;
    wire alert;

    timer dut (
        .clk(clk),
        .rst(rst),
        .present(present),
        .alert(alert)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0; rst = 1; present = 1;
        #10; rst = 0;

        // Test 1: present==0 for more than 600 cycles → alert should go high
        $display("Test 1: alert after 600 cycles");
        present = 0;
        for (i = 0; i < 650; i = i + 1) begin
            #10;
        end
        $display("alert=%0d (expected 1)", alert);

        // Test 2: rst turns alert off
        $display("Test 2: rst turns alert off");
        rst = 1; #10; rst = 0;
        $display("alert=%0d (expected 0)", alert);

        // Test 3: present==0 for less than 600 cycles then present==1
        $display("Test 3: baby returns before 600 cycles");
        present = 0;
        for (i = 0; i < 300; i = i + 1) begin
            #10;
        end
        present = 1; #10;
        $display("alert=%0d (expected 0)", alert);

        // Test 4: alert stays on even if present goes back to 1
        $display("Test 4: alert stays on after 600 cycles");
        present = 0;
        for (i = 0; i < 650; i = i + 1) begin
            #10;
        end
        present = 1; #20;
        $display("alert=%0d (expected 1)", alert);

        // manual rst to clear
        rst = 1; #10; rst = 0;
        $display("alert after rst=%0d (expected 0)", alert);

        $finish;
    end

endmodule
