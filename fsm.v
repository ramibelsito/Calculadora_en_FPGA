//Implementacion de una maquina de estados de Mealy en Verilog
module fsm_mealy (clk, reset, is_op, is_num, is_eq, num1, num2, operation, num_val, op_val, out_ALU);
    input clk, reset, is_op, is_num, is_eq, [3:0] num_val, [1:0] op_va, [15:0] out_ALU;
    output reg [15:0] num1, num2, operation;
    

    // Podria tener el curr_state como salida para debug
    //output [2:1] curr_state;

    reg [2:1] curr_state, next_state;

    // Asignacion de estados
    parameter [2:1] N1 = 2'b00;
    parameter [2:1] OP = 2'b01;
    parameter [2:1] N2 = 2'b10;
    parameter [2:1] EQ = 2'b11;
    // Logica de proximo estado y salida (combinacional)
    // Recordar SIEMPRE definir el proximo estado Y TODAS las salidas 
    // para TODAS las combinaciones posibles de Entradas y Estado Actual
    // Recomendacion: usar if/else de tal manera que el else capture
    // todas las combinaciones que no son explicitas
    reg [2:1] aux;
    always @(is_op, is_num, is_eq, curr_state)
        case (curr_state)
            N1: if (is_op)
                begin
                    num1 <= num_val;  //mi salida depend de entrada y estado actual
                    aux <= N1;
                    next_state <= OP;
                end
               else if (is_num)
                begin
                    num1 << 4; 
                    num1 [3:0] <= num_val;
                    aux <= N1;
                    next_state <= N1;
                end
                else
                begin
                    num1 <= 0; //Salida en todos las combinaciones posibles!!
                    next_state <= N1;
                    aux <= N1;
                end
            OP: if (is_num && aux == OP)
                begin
                    operation <= op_val;
                    next_state <= N2;
                    aux <= OP;
                end
               else if (is_op && aux == OP)
                begin
                    operation <= op_val;
                    next_state <= OP;
                    aux <= OP;
                end
                else
                begin
                    operation <= 0;
                    next_state <= N1;
                    aux <= OP;
                end
            N2: if (is_eq)
                begin
                    num2 <= num_val;
                    next_state <= EQ;
                    aux <= N2;
                end
               else if (is_num)
                begin
                    num2 << 4; 
                    num2 [3:0] <= num_val;
                    next_state <= N2;
                    aux <= N2;
                end
                else if (is_op)
                begin
                    // Evaluar num1 y num2 segun la operacion, guardar el resultado en num1 
                    
                    next_state <= OP;
                    aux <= N2;
                end
                else 
                begin
                    num2 <= 0;
                    next_state <= N1;
                    aux <= N2;
                end
            EQ: if (is_num)
                begin
                    next_state <= N1;
                    num1 = num_val;
                    aux <= EQ;
                end
                else if (is_op)
                begin
                    next_state <= OP;
                    operation <= op_val;
                    num1 <= out_ALU;
                    aux <= EQ;
                end
        endcase

    // Transicion de estado
    always @(negedge reset, posedge clk)
        if (reset == 0) curr_state <= N1;
        else curr_state <= next_state;

endmodule
