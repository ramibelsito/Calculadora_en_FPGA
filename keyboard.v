module keyboard(
        input clk,
        input rst,
        input wire [3:0] rows,
        output reg [3:0] cols,
        output reg is_num,
        output reg is_op,
        output reg is_eq,
        output wire btn_press,
        output reg [3:0] num_val,
        output reg [1:0] op_val,
        );
    reg [3:0] btn_store;
    reg [3:0] btn_id;
    //Ring counter para seleccionar columnas
    always @(posedge clk) begin
        if (rst)
        begin
            cols <= 4'b0000;
        end
        else begin
            if (cols == 4'b0000)
                cols <= 4'b0001;
            else
                cols <= cols << 1;
        end
    end
    
    // Decodeor de filas y columnas a ID de boton
    always @(*) begin
        case (cols)
            4'b1000: btn_id[3:2] = 2'b11;
            4'b0100: btn_id[3:2] = 2'b10;
            4'b0010: btn_id[3:2] = 2'b01;
            4'b0001: btn_id[3:2] = 2'b00; 
            default: btn_id[3:2] = 2'b00;
        endcase
        case (rows)
            4'b0001: btn_id[1:0] = 2'b00;
            4'b0010: btn_id[1:0] = 2'b01;
            4'b0100: btn_id[1:0] = 2'b10;
            4'b1000: btn_id[1:0] = 2'b11;
            default: btn_id[1:0] = 2'b00;
        endcase
    end

    
    wire btn_active;
    reg [3:0] btn_count;
    assign btn_active = (btn_count>0);

    wire any_btn;
    //indica que se presiono un boton
    assign any_btn = (rows[0] || rows [1] || rows [2] || rows[3]);

    //guardo el valor que leo de fila y col
    
    always @(posedge clk) begin
        if (rst) begin
            btn_store <= 4'd0;
            //btn_active <= 0;
            btn_count <= 0;
            
        end
        else begin
            if (any_btn) begin
                btn_store <= btn_id;
                //btn_active <= 1;
                btn_count <= 5;
            end
            else if (btn_count > 0)
                btn_count <= btn_count - 1;
        end
        
    end

parameter BTN_1 = 4'b0000; // 1000 0000 0000 0000
parameter BTN_2 = 4'b0100; // 0100 0000 0000 0000
parameter BTN_3 = 4'b1000; // 0010 0000 0000 0000
parameter BTN_ADD = 4'b1100; // 0001 0000 0000 0000

parameter BTN_4 = 4'b0001; // 0000 1000 0000 0000
parameter BTN_5 = 4'b0101; // 0000 0100 0000 0000
parameter BTN_6 = 4'b1001; // 0000 0010 0000 0000
parameter BTN_SUB = 4'b1101; // 0000 0001 0000 0000

parameter BTN_7 = 4'b0010; // 0000 0000 1000 0000
parameter BTN_8 = 4'b0110; // 0000 0000 0100 0000
parameter BTN_9 = 4'b1010; // 0000 0000 0010 0000
parameter BTN_MUL = 4'b1110; // 0000 0000 0001 0000

parameter BTN_0 = 4'b0111; // 0000 0000 0000 0100
parameter BTN_EQ = 4'b1111; // 0000 0000 0000 0001
assign btn_press = btn_active;

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
            BTN_ADD: begin 
                is_num <= 0;
                is_eq <= 0;
                is_op <= 1;
                num_val <= 4'd0;
                op_val <= 2'd1;
            end
            BTN_SUB: begin 
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
        endcase
    end

endmodule
 