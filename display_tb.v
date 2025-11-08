
// dispout_tb
// ----------
// Testbench mínimo para `display_out`: genera un clock, libera reset y entrega
// un valor BCD fijo para observar los pulsos de `data_out` y `sending_data` en
// la simulación (volcado a 1.vcd).
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

    // Clock libre de 100 MHz (periodo 10) aproximado.
    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk <= 0;
        reset <= 1;
        bcd_in <= 16'b0010010101110001; // ejemplo de 4 nibbles
    end


    initial begin
        $dumpfile("1.vcd");
        $dumpvars(3);
        #10 reset <= 0;

        #9000 $finish;
    end


endmodule
