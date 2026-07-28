`timescale 1ns / 1ps

module line_buffer #(
    parameter WIDTH  = 640,
    parameter HEIGHT = 480
)(
    input clk,
    input rst,
    input [7:0] pixel_in,
    output [7:0] p00, p01, p02,
    output [7:0] p10, p11, p12,
    output [7:0] p20, p21, p22,
    output valid,
    output [9:0] col_count_out,    
    output [9:0] row_count_out     
);

    // Internal storage
    reg [7:0] line_buf1 [0:WIDTH-1];
    reg [7:0] line_buf2 [0:WIDTH-1];
    reg [7:0] line_buf3 [0:WIDTH-1];
    reg [7:0] pix_delay1;
    reg [7:0] pix_delay2;
    reg [7:0] pix_delay3;
    reg [9:0] col_count;
    reg [9:0] row_count;
    reg [1:0] buf_select;
    reg       end_of_row;



    // Sequential logic
    always @(posedge clk) begin
        if (rst) begin
            pix_delay1  <= 0;
            pix_delay2  <= 0;
            pix_delay3  <= 0;
            col_count   <= 0;
            row_count   <= 0;
            buf_select  <= 0;
            end_of_row  <= 0;
        end else begin
            // Pixel delay shift register
            pix_delay3 <= pix_delay2;
            pix_delay2 <= pix_delay1;
            pix_delay1 <= pixel_in;

            // Write incoming pixel into current write buffer
            if (buf_select == 0)
                line_buf1[col_count] <= pixel_in;
            else if (buf_select == 1)
                line_buf2[col_count] <= pixel_in;
            else
                line_buf3[col_count] <= pixel_in;

            // end_of_row registered signal
            end_of_row <= (col_count == WIDTH-1);

            // Row transition
            if (col_count == WIDTH-1) begin
                col_count  <= 0;
                buf_select <= (buf_select == 2) ? 0 : buf_select + 1;
                if (row_count < HEIGHT-1)
                    row_count <= row_count + 1;
            end else
                col_count <= col_count + 1;
        end
    end

    // Output assignments using col_out
    // p00-p02: oldest row (2 rows ago)
    wire [1:0] prev_buf;
    
    assign prev_buf = (buf_select == 0) ? 2 :
                      (buf_select == 1) ? 0 :
                                          1;
        // Previous buffer index (wrap around)
    // buf_select: 0 -> 2, 1 -> 0, 2 -> 1
    
    // p00-p02: row 2 ago
    assign p00 = (end_of_row == 0) ?
                 ((buf_select == 0) ? line_buf2[col_count-3] :
                  (buf_select == 1) ? line_buf3[col_count-3] :
                                      line_buf1[col_count-3]) :
                 ((prev_buf == 0) ? line_buf2[WIDTH-3] :
                  (prev_buf == 1) ? line_buf3[WIDTH-3] :
                                    line_buf1[WIDTH-3]);
    
    assign p01 = (end_of_row == 0) ?
                 ((buf_select == 0) ? line_buf2[col_count-2] :
                  (buf_select == 1) ? line_buf3[col_count-2] :
                                      line_buf1[col_count-2]) :
                 ((prev_buf == 0) ? line_buf2[WIDTH-2] :
                  (prev_buf == 1) ? line_buf3[WIDTH-2] :
                                    line_buf1[WIDTH-2]);
    
    assign p02 = (end_of_row == 0) ?
                 ((buf_select == 0) ? line_buf2[col_count-1] :
                  (buf_select == 1) ? line_buf3[col_count-1] :
                                      line_buf1[col_count-1]) :
                 ((prev_buf == 0) ? line_buf2[WIDTH-1] :
                  (prev_buf == 1) ? line_buf3[WIDTH-1] :
                                    line_buf1[WIDTH-1]);
    
    // p10-p12: previous row (1 row ago)
    assign p10 = (end_of_row == 0) ?
                 ((buf_select == 0) ? line_buf3[col_count-3] :
                  (buf_select == 1) ? line_buf1[col_count-3] :
                                      line_buf2[col_count-3]) :
                 ((prev_buf == 0) ? line_buf3[WIDTH-3] :
                  (prev_buf == 1) ? line_buf1[WIDTH-3] :
                                    line_buf2[WIDTH-3]);
    
    assign p11 = (end_of_row == 0) ?
                 ((buf_select == 0) ? line_buf3[col_count-2] :
                  (buf_select == 1) ? line_buf1[col_count-2] :
                                      line_buf2[col_count-2]) :
                 ((prev_buf == 0) ? line_buf3[WIDTH-2] :
                  (prev_buf == 1) ? line_buf1[WIDTH-2] :
                                    line_buf2[WIDTH-2]);
    
    assign p12 = (end_of_row == 0) ?
                 ((buf_select == 0) ? line_buf3[col_count-1] :
                  (buf_select == 1) ? line_buf1[col_count-1] :
                                      line_buf2[col_count-1]) :
                 ((prev_buf == 0) ? line_buf3[WIDTH-1] :
                  (prev_buf == 1) ? line_buf1[WIDTH-1] :
                                    line_buf2[WIDTH-1]);
    // p20-p22: current row (pixel delays)
    assign p20 = pix_delay3;
    assign p21 = pix_delay2;
    assign p22 = pix_delay1;
    
    //Getting rows and column
    assign col_count_out = col_count;
    assign row_count_out = row_count;

    // Valid signal
    assign valid = ((row_count >= 2) && (row_count <= HEIGHT-1) &&
               (col_count >= 3) && (col_count <= WIDTH-1))
               || (end_of_row && (row_count >= 3) && (row_count <= HEIGHT-1));

endmodule


// eor. needs its own thing