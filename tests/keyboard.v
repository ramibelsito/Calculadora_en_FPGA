module keyboard(
        input clk,
        output reg [3:0] cols, 
        input wire [3:0] rows,
        output reg is_num,
        output reg is_op,
        output reg is_eq,
        output wire btn_press,
        output reg [3:0] num_val,
        output reg [1:0] op_val);

    reg rst ;
    
    //Ring counter para seleccionar columnas
    always @(posedge clk) begin
        if (rst)
            cols <= 4'b0000;
        else begin
            if (cols == 4'b0000)
                cols <= 4'b0001;
            else
                cols <= cols << 1;
        end
    end

    //Armo el valor que recibo, combino col y fila
    wire [3:0] btn_id;

    assign btn_id[3] = cols[1];
    assign btn_id[2] = cols[0];
    assign btn_id[1] = rows[1];
    assign btn_id[0] = rows[0];
 
    //reg para 'guardar' el valor
    reg [3:0] btn_store;
    wire btn_active;
    reg [3:0] btn_count;
    reg first_press_seen;
    assign btn_active = (btn_count>0);

    initial begin
        rst = 1'b0;
        first_press_seen = 1'b0;
    end

    wire any_btn;
    //indica que se presiono un boton
    assign any_btn = rows[0] || rows [1] || rows [2] || rows[3];

    //guardo el valor que leo de fila y col
    always @(posedge clk) begin
        if (rst) begin
            btn_store <= 4'd0;
            //btn_active <= 0;
            btn_count <= 0;
            first_press_seen <= 1'b0;
        end
        else begin
            if (any_btn) begin
                btn_store <= btn_id;
                //btn_active <= 1;
                btn_count <= 5;
            end
            else if (btn_count > 0)
                btn_count <= btn_count - 1;

            if (btn_active && !first_press_seen)
                first_press_seen <= 1'b1;

        end
        
    end

    //decodifico los valores posibles
    parameter [3:0] BTN_0 =    4'b0111;    //0000 0000 0000 0100;
    parameter [3:0] BTN_1 =    4'b0000;    //1000 0000 0000 0000;
    parameter [3:0] BTN_2 =    4'b0100;    //0100 0000 0000 0000;
    parameter [3:0] BTN_3 =    4'b1000;    //0010 0000 0000 0000;
    parameter [3:0] BTN_4 =    4'b0001;    //0000 1000 0000 0000;
    parameter [3:0] BTN_5 =    4'b0101;    //0000 0100 0000 0000;
    parameter [3:0] BTN_6 =    4'b1001;    //0000 0010 0000 0000;
    parameter [3:0] BTN_7 =    4'b0010;    //0000 0000 1000 0000;
    parameter [3:0] BTN_8 =    4'b0110;    //0000 0000 0100 0000;
    parameter [3:0] BTN_9 =    4'b1010;    //0000 0000 0010 0000;
    parameter [3:0] BTN_PLUS = 4'b1100;    //0001 0000 0000 0000;
    parameter [3:0] BTN_MIN =  4'b1101;    //0000 0001 0000 0000;
    parameter [3:0] BTN_EQ =   4'b1111;    //0000 0000 0000 0001;

    assign btn_press = btn_active && !first_press_seen;

    //genero las salidas en base a los botones
    always @(*)
    begin
      if (!btn_active) begin
        is_num <= 0;
        is_eq <= 0;
        is_op <= 0;
        num_val <= 4'd0;
        op_val <= 2'd0;
      end
      else
        case (btn_store)
            BTN_0: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd0;
                op_val <= 2'd0;
            end
            BTN_1: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd1;
                op_val <= 2'd0;
            end
            BTN_2: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd2;
                op_val <= 2'd0;
            end
            BTN_3: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd3;
                op_val <= 2'd0;
            end
            BTN_4: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd4;
                op_val <= 2'd0;
            end
            BTN_5: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd5;
                op_val <= 2'd0;
            end
            BTN_6: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd6;
                op_val <= 2'd0;
            end
            BTN_7: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd7;
                op_val <= 2'd0;
            end
            BTN_8: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd8;
                op_val <= 2'd0;
            end
            BTN_9: begin 
                is_num <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd9;
                op_val <= 2'd0;
            end

            BTN_PLUS: begin 
                is_num <= 0;
                is_eq <= 0;
                is_op <= 1;
                num_val <= 4'd0;
                op_val <= 2'd1;
            end
            BTN_MIN: begin 
                is_num <= 0;
                is_eq <= 0;
                is_op <= 1;
                num_val <= 4'd0;
                op_val <= 2'd2;
            end


            BTN_EQ: begin 
                is_num <= 0;
                is_eq <= 1;
                is_op <= 0;
                num_val <= 4'd0;
                op_val <= 2'd0;
            end
            default: begin
                is_num <= 0;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd0;
                op_val <= 2'd0;
            end

        endcase
    end

endmodule
 
