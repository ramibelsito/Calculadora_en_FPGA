module topModule
(
    // GPIOs Keyboard Conecctions
    input wire gpio_23,
    input wire gpio_25,
    input wire gpio_26,
    input wire gpio_27,
    output wire gpio_32,
    output wire gpio_35,
    output wire gpio_31,
    output wire gpio_37,
    output wire gpio_2,
    output wire gpio_46,

    output wire gpio_45,
    output wire gpio_44,
    output wire gpio_43,
    output wire gpio_42
);


// Wires keyboard
wire [3:0] rows;
wire [3:0] cols;
assign rows[0] = gpio_23;
assign rows[1] = gpio_25;
assign rows[2] = gpio_26;
assign rows[3] = gpio_27;
assign cols[0] = gpio_32;
assign cols[1] = gpio_35;
assign cols[2] = gpio_31;
assign cols[3] = gpio_37;
wire btn_press= gpio_46;
wire [3:0] btn_id;
assign btn_id[0] = gpio_45;
assign btn_id[1] = gpio_44;
assign btn_id[2] = gpio_43;
assign btn_id[3] = gpio_42;

wire is_num;
wire is_op=gpio_2;
wire is_eq;
wire [3:0] num_val;
wire [1:0] op_val;



keyboard u_keyboard (
    .clk(LF_int_osc),
    .cols(cols), 
    .rows(rows), 
    .is_num(is_num),
    .is_op(is_op),
    .is_eq(is_eq),
    .btn_press(btn_press),
    .num_val(num_val),
    .op_val(op_val),
    .btn_id(btn_id)
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