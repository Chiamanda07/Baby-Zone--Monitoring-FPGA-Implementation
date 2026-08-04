`timescale 1ns / 1ps

/*
=== BEFORE RUNNING THIS TESTBENCH ===
Change these parameters in top.v:

1. line_buffer instantiation:
   .WIDTH(8), .HEIGHT(4)          // was WIDTH(640), HEIGHT(480)

2. zone_detect instantiation:
   .edge_thresh(5),               // was 100
   .row_min(1),                   // was 320
   .row_max(2),                   // was 400
   .col_min(1),                   // was 200
   .col_max(6)                    // was 420

3. timer instantiation:
   .timer_thresh(5)              // was 600

4. EDGE_THRESH parameter in top.v:
   .EDGE_THRESH(20)               // was 500

=== CHANGE THEM BACK AFTER TESTING ===
*/

module top_tb;

    reg clk, rst;
    reg [7:0] R, G, B;
    wire alert;

    top #(
        .EDGE_THRESH(20)
    ) dut (
        .clk(clk),
        .rst(rst),
        .R(R), .G(G), .B(B),
        .alert(alert)
    );

    always #5 clk = ~clk;

    integer frame;

    // Task to send one complete 8x4 frame
    task send_frame;
        input baby_present;
        integer r, c;
        begin
            for (r = 0; r < 4; r = r + 1) begin
                for (c = 0; c < 8; c = c + 1) begin
                    if (baby_present && r == 1) begin
                        // Baby row - green
                        R = 0; G = 255; B = 0;
                    end else if (r == 2) begin
                        // Crib row - blue
                        R = 0; G = 0; B = 255;
                    end else begin
                        // Background - red
                        R = 255; G = 0; B = 0;
                    end
                    #5;
                    /*$display("r=%0d c=%0d | R=%0d G=%0d B=%0d | alert=%0d present=%0d | pipe_row=%0d pipe_col=%0d", 
                                 r, c, R, G, B, alert, dut.present, 
                                 dut.line_inst.row_count, dut.line_inst.col_count);*/
                    #5;
                end
            end
        end
    endtask

    initial begin
        clk = 0; rst = 1;
        R = 0; G = 0; B = 0;
        #10; rst = 0;

        // Test 1: baby present for 10 frames - alert should stay low
        $display("=== Test 1: Baby present - alert should stay low ===");
        for (frame = 0; frame < 10; frame = frame + 1) begin
            send_frame(1);
            $display("Frame %0d | baby_present=1 | alert=%0d (expected 0)", 
                     frame, alert);
        end

        // Test 2: baby absent for enough frames - alert should fire
        $display("=== Test 2: Baby absent - alert should fire ===");
        for (frame = 0; frame < 10; frame = frame + 1) begin
            send_frame(0);
            $display("Frame %0d | baby_present=0 | alert=%0d (expected 1 after frame 5)", 
                     frame, alert);
        end

        // Test 3: rst clears alert
        $display("=== Test 3: rst clears alert ===");
        rst = 1; #10; rst = 0;
        $display("alert=%0d (expected 0)", alert);

        // Test 4: baby leaves mid sequence then returns
        $display("=== Test 4: Baby leaves then returns ===");
        // Baby present for 3 frames
        for (frame = 0; frame < 3; frame = frame + 1) begin
            send_frame(1);
            $display("Frame %0d | baby_present=1 | alert=%0d (expected 0)", 
                     frame, alert);
        end
        // Baby absent for 3 frames - not enough to trigger alert
        for (frame = 0; frame < 3; frame = frame + 1) begin
            send_frame(0);
            $display("Frame %0d | baby_present=0 | alert=%0d (expected 0)", 
                     frame, alert);
        end
        // Baby returns - counter should reset
        for (frame = 0; frame < 3; frame = frame + 1) begin
            send_frame(1);
            $display("Frame %0d | baby_present=1 | alert=%0d (expected 0)", 
                     frame, alert);
        end
        // Baby leaves again for enough frames to trigger
        $display("=== Baby leaves again - alert should fire ===");
        for (frame = 0; frame < 10; frame = frame + 1) begin
            send_frame(0);
            $display("Frame %0d | baby_present=0 | alert=%0d (expected 1 after frame 5)", 
                     frame, alert);
        end

        $finish;
    end

endmodule