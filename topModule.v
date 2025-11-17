module topModule
(
    // GPIOs Dispaly Conecctions
    input wire gpio_11,
    output wire gpio_46,
    output wire gpio_28,
    output wire gpio_2,
    output wire gpio_42,
    // GPIOs Keyboard Conecctions
    input wire gpio_23,
    input wire gpio_25,
    input wire gpio_26,
    input wire gpio_27,
    output wire gpio_32,
    output wire gpio_35,
    output wire gpio_31,
    output wire gpio_37,
    
);

// Wires displays
wire rst = gpio_11;
wire data_out = gpio_46;
wire sending_data = gpio_28;
wire dataClk = gpio_42;
wire dispClk = gpio_2;
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
// Wires keyboard -> FSM
wire is_num;
wire is_op;
wire is_eq;
wire [3:0] num_val;
wire [1:0] op_val;

// Wires FSM -> Multiplexor
wire [15:0] num1_bcd;
wire [15:0] num2_bcd;
wire [1:0] operation;
wire [15:0] out_ALU;
wire [2:1] curr_state;
// Wires Multiplexor -> Display
wire clk_logica;
wire next_data;
wire [15:0] data_shown;

display_out u_display_out (
    .clk(LF_int_osc),
    .rst(rst),
    .enable(next_data),
    .bcd_in(data_shown),
    .data_out(data_out),
    .sending_data(sending_data)
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
    .op_val(op_val)
);
/*
fsm u_fsm (
    .clk(LF_int_osc),
    .rst(rst),
    .is_num(is_num),
    .is_op(is_op),
    .is_eq(is_eq),
    .num_val(num_val),
    .op_val(op_val),
    .num1_bcd(num1_bcd),
    .num2_bcd(num2_bcd),
    .operation(operation),
    .out_ALU(out_ALU),
    .curr_state(curr_state)
);
*/
multiplexor u_multiplexor (
    .clk(LF_int_osc),
    .rst(rst),
    .curr_state(curr_state),
    .num1_bcd(num1_bcd),
    .num2_bcd(num2_bcd),
    .out_ALU(out_ALU),
    .operation(operation),
    .clk_logica(clk_logica),
    .next_data(next_data),
    .data_shown(data_shown)
);

ALU u_ALU (
    .num1_bcd(num1_bcd),
    .num2_bcd(num2_bcd),
    .operation(operation),
    .out_ALU(out_ALU)
);

assign dataClk = LF_int_osc;
assign dispClk = clk_logica;
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