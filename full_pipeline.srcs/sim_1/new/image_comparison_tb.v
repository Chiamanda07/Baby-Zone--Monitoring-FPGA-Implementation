`timescale 1ns / 1ps
/*
=== BEFORE RUNNING THIS TESTBENCH ===
Change these parameters in top.v:

1. line_buffer instantiation:
   .WIDTH(320), .HEIGHT(240)          // was WIDTH(640), HEIGHT(480)

2. zone_detect instantiation:
   .edge_thresh(500),               // was 100
   .row_min(50),                   // was 320
   .row_max(220),                   // was 400
   .col_min(60),                   // was 200
   .col_max(280)                    // was 420


=== CHANGE THEM BACK AFTER TESTING ===
*/

module image_comparison_tb();

    // Signal declarations
    reg clk, rst;
    reg [7:0] R, G, B;
    wire alert;
    wire [7:0] thresh_out;

    // Instantiate top with real image parameters
    top #(
        .EDGE_THRESH(500)
    ) dut (
        .clk(clk),
        .rst(rst),
        .R(R), .G(G), .B(B),
        .alert(alert),
        .thresh_out(thresh_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Image dimensions
    parameter WIDTH  = 320;
    parameter HEIGHT = 240;
    parameter PIXELS = WIDTH * HEIGHT;

    // Memory for input image
    reg [7:0] R_mem [0:PIXELS-1];
    reg [7:0] G_mem [0:PIXELS-1];
    reg [7:0] B_mem [0:PIXELS-1];

    // Memory for output image
    reg [7:0] thresh_mem [0:PIXELS-1];

    integer i;
    integer out_idx;

    initial begin
        // Load hex files
        $readmemh("R.hex", R_mem);
        $readmemh("G.hex", G_mem);
        $readmemh("B.hex", B_mem);
        $display("Image loaded successfully");

        // Initialize
        clk = 0; rst = 1;
        R = 0; G = 0; B = 0;
        out_idx = 0;
        #10; rst = 0;

        // Stream all pixels through pipeline
        $display("Streaming %0d pixels through pipeline...", PIXELS);
        for (i = 0; i < PIXELS; i = i + 1) begin
            R = R_mem[i];
            G = G_mem[i];
            B = B_mem[i];
            #5;
            // Capture thresholded output
            // Output is delayed by pipeline latency so we skip first few pixels
            if (i >= WIDTH * 2 + 3) begin
                thresh_mem[out_idx] = thresh_out;
                out_idx = out_idx + 1;
            end
            #5;
        end

        // Extra cycles to flush pipeline
        R = 0; G = 0; B = 0;
        repeat(WIDTH * 2 + 10) begin
            #5;
            if (out_idx < PIXELS) begin
                thresh_mem[out_idx] = thresh_out;
                out_idx = out_idx + 1;
            end
            #5;
        end

        // Write thresholded output to hex file
        $writememh("thresh_out.hex", thresh_mem);
        $display("Thresholded output saved to thresh_out.hex");
        $display("Alert = %0d", alert);
        $display("Pixels captured = %0d", out_idx);

        $finish;
    end

endmodule
