

module dispout_tb();
    reg clk;
    reg reset;
    reg [15:0] bcd_in;
    wire data_out;
    wire sending_data;

    // Instanciación por nombre para evitar errores si cambian puertos
    display_out disp1(
        .clk(clk),
        .rst(reset),
        .enable(1'b1),
        .bcd_in(bcd_in),
        .data_out(data_out),
        .sending_data(sending_data)
    );

    initial begin
        clk <= 0;
        reset <= 1;
        bcd_in <= 16'b0010010101110001; // ejemplo de 4 nibbles
    end


    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("1.vcd");
        $dumpvars(3);
        #10 reset <= 0;

        #9000 $finish;
    end


endmodule