module topModule
(
    // GPIOs Dispaly Conecctions
    output wire gpio_2,
    output wire gpio_46,
    output wire gpio_47,
    output wire gpio_45,

    input wire gpio_38,
    
);
// Wires displays

wire rst = gpio_38;
wire data_out = gpio_2;
wire data_ready = gpio_46;
wire dataClk = gpio_47;
wire dispClk = gpio_45;
assign dataClk = clk_logica;
assign dispClk = LF_int_osc;
wire clk_logica;
display_out u_display_out (
    .clk(LF_int_osc),
    .rst(rst),
    .bcd_in(16'h1111),
    .data_out(data_out),
    .data_ready(data_ready),
    .clk_logica(clk_logica)
);
wire HF_int_osc;
wire LF_int_osc;

//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillator                                --
//                                                                          --
//----------------------------------------------------------------------------
    SB_HFOSC  u_SB_HFOSC(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(HF_int_osc));
    defparam u_SB_HFOSC.CLKHF_DIV = "0b11";  // 6MHz
    SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(LF_int_osc));

endmodule