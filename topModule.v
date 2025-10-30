module topModule
(
    input wire gpio_11,
    output wire gpio_46,
    output wire gpio_28,
    output wire gpio_2,
    output wire gpio_42,
    
);
wire rst = gpio_11;
wire data_out = gpio_46;
wire sending_data = gpio_28;
wire dataClk = gpio_42;
wire dispClk = gpio_2;

display_out u_display_out (
    .clk(LF_int_osc),
    .rst(rst),
    .enable(1'b1),
    .bcd_in(16'h8888),
    .data_out(data_out),
    .sending_data(sending_data)
);
assign dataClk = LF_int_osc;
assign dispClk = LF_int_osc;
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