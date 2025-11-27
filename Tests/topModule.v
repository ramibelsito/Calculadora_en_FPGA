module topModule
(
        // GPIOs Dispaly Conecctions
    output wire gpio_2,
    output wire gpio_46,
    output wire gpio_47,
    output wire gpio_45,

    input wire gpio_38,
    // GPIOs Keyboard Conecctions
    input wire gpio_23,
    input wire gpio_25,
    input wire gpio_26,
    input wire gpio_27,
    output wire gpio_32,
    output wire gpio_35,
    output wire gpio_31,
    output wire gpio_37,

    output wire gpio_28,
    
);

wire HF_int_osc;
wire LF_int_osc;
// Wires displays
wire btn_press = gpio_28;
wire rst = gpio_38;
wire data_out = gpio_2;
wire data_ready = gpio_46;
wire dataClk = gpio_47;
wire dispClk = gpio_45;
assign dataClk = clk_logica;
assign dispClk = LF_int_osc;
wire clk_logica;
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
wire btn_press;
// Wires keyboard -> PassThrough
wire is_num;
wire is_op;
wire is_eq;
wire [3:0] num_val;
wire [1:0] op_val;
// Wires PassThrough -> Display
wire [15:0] data_out_bcd;
wire [3:0] btn_store;
/*
assign btn_store[0] = gpio_2;
assign btn_store[1] = gpio_46;
assign btn_store[2] = gpio_47;
assign btn_store[3] = gpio_45; 

assign num_val[0] = gpio_2;
assign num_val[1] = gpio_46;
assign num_val[2] = gpio_47;
assign num_val[3] = gpio_45;

assign data_out_bcd[0] = gpio_2;
assign data_out_bcd[1] = gpio_46;
assign data_out_bcd[2] = gpio_47;
assign data_out_bcd[3] = gpio_45;
*/


display_out u_display_out (
    .clk(LF_int_osc),
    .rst(rst),
    .bcd_in(data_out_bcd),
    .data_out(data_out),
    .data_ready(data_ready),
    .clk_logica(clk_logica)
);

keyboard u_keyboard (
    .clk(LF_int_osc),
    .rst(rst),
    .cols(cols), 
    .rows(rows), 
    .is_num(is_num),
    .is_op(is_op),
    .is_eq(is_eq),
    .btn_press(btn_press),
    .num_val(num_val),
    .op_val(op_val),
    .btn_store(btn_store),
);

PassThrough u_PassThrough (
    .clk(clk_logica),
    .rst(rst),
    .num_val(num_val),
    .op_val(op_val),
    .is_num(is_num),
    .is_op(is_op),
    .is_eq(is_eq),
    .data_out_bcd(data_out_bcd)
);

//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillator                                --
//                                                                          --
//----------------------------------------------------------------------------
    SB_HFOSC  u_SB_HFOSC(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(HF_int_osc));
    defparam u_SB_HFOSC.CLKHF_DIV = "0b11";  // 6MHz
    SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(LF_int_osc));

endmodule