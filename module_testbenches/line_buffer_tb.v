`timescale 1ns / 1ps

module line_buffer_tb;

    // Signal declarations
    reg clk;
    reg rst;
    reg [7:0] pixel_in;
    wire [7:0] p00, p01, p02;
    wire [7:0] p10, p11, p12;
    wire [7:0] p20, p21, p22;
    wire valid;

    // Instantiate line_buffer
    line_buffer #(.WIDTH(8), .HEIGHT(4)) dut (
        .clk(clk),
        .rst(rst),
        .pixel_in(pixel_in),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .valid(valid)
    );

    // Clock generation
    always #5 clk = ~clk;

    integer i;
    reg [7:0] pixels [0:31];

    initial begin
        // Row 0
        pixels[0]=10;  pixels[1]=20;  pixels[2]=30;  pixels[3]=40;
        pixels[4]=50;  pixels[5]=60;  pixels[6]=70;  pixels[7]=80;
        // Row 1
        pixels[8]=90;  pixels[9]=100; pixels[10]=110; pixels[11]=120;
        pixels[12]=130; pixels[13]=140; pixels[14]=150; pixels[15]=160;
        // Row 2
        pixels[16]=170; pixels[17]=180; pixels[18]=190; pixels[19]=200;
        pixels[20]=210; pixels[21]=220; pixels[22]=230; pixels[23]=240;
        // Row 3
        pixels[24]=10; pixels[25]=20; pixels[26]=30; pixels[27]=40;
        pixels[28]=50; pixels[29]=60; pixels[30]=70; pixels[31]=80;

        // Initialize and reset
        clk = 0; rst = 1; pixel_in = 0;
        #10;
        rst = 0;

        // Send all 32 pixels
        for (i = 0; i < 32; i = i + 1) begin
            pixel_in = pixels[i];
            #5;
            $display("i=%0d valid=%0d row=%0d col=%0d eor=%0d",
                     i, valid, dut.row_count, dut.col_count, dut.end_of_row);
            if (valid) begin
                $display("p00=%0d p01=%0d p02=%0d", p00, p01, p02);
                $display("p10=%0d p11=%0d p12=%0d", p10, p11, p12);
                $display("p20=%0d p21=%0d p22=%0d", p20, p21, p22);
                $display("---");
            end
            #5;
        end

        // Extra cycle to catch last neighborhood of final row
        pixel_in = 0;
        #5;
        $display("EXTRA valid=%0d row=%0d col=%0d eor=%0d",
                 valid, dut.row_count, dut.col_count, dut.end_of_row);
        if (valid) begin
            $display("p00=%0d p01=%0d p02=%0d", p00, p01, p02);
            $display("p10=%0d p11=%0d p12=%0d", p10, p11, p12);
            $display("p20=%0d p21=%0d p22=%0d", p20, p21, p22);
            $display("---");
        end
        #5;

        $finish;
    end

endmodule