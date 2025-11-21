// fsm_mealy
// ---------
// Controla la secuencia de ingreso de la calculadora:
//   N1 -> OP -> N2 -> EQ, almacenando operandos, operación seleccionada y
//   solicitando el resultado a la ALU cuando corresponde. Implementa una
//   máquina de estados de Mealy porque algunas salidas dependen directamente
//   de las entradas actuales.
// Implementacion de una maquina de estados de Mealy en Verilog
module fsm (
    input clk, rst, is_op, is_num, is_eq,
    input wire [3:0] num_val,
    input wire [1:0] op_val,
    input wire [15:0] out_ALU,
    output reg [15:0] num1_bcd, 
    output reg [15:0] num2_bcd,
    output reg [1:0] operation,
    output reg [1:0] curr_state,
    );
  // Podria tener el curr_state como salida para debug
    //output [2:1] curr_state;

    reg [1:0] next_state;

    // Asignacion de estados
    parameter [1:0] N1 = 2'b00;
    parameter [1:0] OP = 2'b01;
    parameter [1:0] N2 = 2'b10;
    parameter [1:0] EQ = 2'b11;
    // Lógica de próximo estado y salidas (combinacional).
    // Cada estado modela la captura de operandos u operaciones y
    // actualiza `num1_bcd`, `num2_bcd` y `operation` según las entradas.
    reg [1:0] aux;
    always @(*)
        case (curr_state)
            // N1: ingreso del primer operando dígito a dígito hasta recibir una operación.
            N1: begin
                if (is_op)
                begin
                    //num1_bcd <= num_val; 
                    aux <= N1;
                    next_state <= OP;
                end
                else
                begin
                    //num1_bcd <= 0; 
                    next_state <= N1;
                    aux <= N1;
                end
            end
            // OP: espera que se confirme la operación y opcionalmente la cambia.
            OP: begin
                if (is_num && aux == OP)
                begin
                    next_state <= N2;
                    aux <= OP;
                end
               else if (is_op && aux == OP)
                begin
                    next_state <= OP;
                    aux <= OP;
                end
                else
                begin
                    next_state <= N1;
                    aux <= OP;
                end
            end
            // N2: ingreso del segundo operando; si llega otro operador se encadena cálculo.
            N2: begin
                if (is_eq)
                begin
                    next_state <= EQ;
                    aux <= N2;
                end
               else if (is_num)
                begin
                    next_state <= N2;
                    aux <= N2;
                end
                else if (is_op)
                begin
                    next_state <= OP;
                    aux <= N2;
                end
                else 
                begin
                    next_state <= N1;
                    aux <= N2;
                end
            end
            // EQ: muestra resultado, pero permite arrancar una nueva operación inmediatamente.
            EQ: begin
                if (is_num)
                begin
                    next_state <= N1;
                    aux <= EQ;
                end
                else if (is_op)
                begin
                    next_state <= OP;
                    aux <= EQ;
                end
                else 
                begin
                    next_state <= N1;
                    aux <= EQ;
                end
            end
            default:
                begin
                    next_state <= N1;
                    aux <= N1;
                end
        endcase

    // Transición de estado sincronizada al clock (rst asíncrono activo en 0).
    always @(posedge clk)
    begin
        if (curr_state == N1)
        begin
            if (next_state == OP)
            begin 
                num1_bcd <= num_val; 
            end
            else if (next_state == N1)
            begin
                if (is_num)
                begin
                num1_bcd <= num1_bcd << 4; 
                num1_bcd [3:0] <= num_val;
                end
                else
                begin
                num1_bcd <= 0;
                end
            end
        end
        else if (curr_state == OP)
        begin
            if (next_state == N2)
            begin 
                num2_bcd <= num_val; 
            end
            else if (next_state == OP)
            begin
                operation <= op_val;
            end
            else if (next_state == N1)
            begin
                operation <= 0;
            end
        end
        else if (curr_state == N2)
        begin
            if (next_state == EQ)
            begin 
                num2_bcd <= num_val;
            end
            else if (next_state == N2)
            begin
                num2_bcd <= num2_bcd << 4; 
                num2_bcd [3:0] <= num_val;
            end
            else if (next_state == OP)
            begin
                // Evaluar num1_bcd y num2_bcd segun la operacion, guardar el resultado en num1_bcd 
                num1_bcd <= out_ALU;
                operation <= op_val;
            end
            else if (next_state == N1)
            begin
                num2_bcd <= 0;
                operation <= 0;
            end
        end
        else if (curr_state == EQ)
        begin
            if (next_state == N1)
            begin
                if (is_num) num1_bcd <= num_val;
                else num1_bcd <= 0;
            end
            else if (next_state == OP)
            begin
                operation <= op_val;
                num1_bcd <= out_ALU;
            end
        end
        if (rst == 0) curr_state <= N1;
        else curr_state <= next_state;
    end

endmodule
