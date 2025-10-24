

module dispout_tb();
    reg clk;
    reg reset;
    reg [15:0] bcd_in;
    reg [31:0] segment_data;
    wire ser_clk, ser_data, data_ready, disp_clk;
    display_out disp1(clk, reset, 1'd1, bcd_in, segment_data, data_out, sending_data);

    initial begin
        clk <= 0;
        reset <= 1;
        bcd_in <= 16'b0010010101110001; 
        segment_data <= 32'b11000000111110000011111100001111;
    end


    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("1.vcd");
        $dumpvars(2);
        #10 reset <= 0;

        #9000 $finish;
    end


endmodule