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
    always @(is_op, is_num, is_eq, curr_state)
        case (curr_state)
            // N1: ingreso del primer operando dígito a dígito hasta recibir una operación.
            N1: if (is_op)
                begin
                    num1_bcd <= num_val;  //mi salida depend de entrada y estado actual
                    aux <= N1;
                    next_state <= OP;
                end
               else if (is_num)
                begin
                    num1_bcd <= num1_bcd << 4; 
                    num1_bcd [3:0] <= num_val;
                    aux <= N1;
                    next_state <= N1;
                end
                else
                begin
                    num1_bcd <= 0; 
                    next_state <= N1;
                    aux <= N1;
                end
            // OP: espera que se confirme la operación y opcionalmente la cambia.
            OP: begin

            
                if (is_num && aux == OP)
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
            end
            // N2: ingreso del segundo operando; si llega otro operador se encadena cálculo.
            N2: if (is_eq)
                begin
                    num2_bcd <= num_val;
                    next_state <= EQ;
                    aux <= N2;
                end
               else if (is_num)
                begin
                    num2_bcd <= num2_bcd << 4; 
                    num2_bcd [3:0] <= num_val;
                    next_state <= N2;
                    aux <= N2;
                end
                else if (is_op)
                begin
                    // Evaluar num1_bcd y num2_bcd segun la operacion, guardar el resultado en num1_bcd 
                    num1_bcd <= out_ALU;
                    operation <= op_val;
                    next_state <= OP;
                    aux <= N2;
                end
                else 
                begin
                    num2_bcd <= 0;
                    next_state <= N1;
                    aux <= N2;
                end
            // EQ: muestra resultado, pero permite arrancar una nueva operación inmediatamente.
            EQ: if (is_num)
                begin
                    next_state <= N1;
                    num1_bcd = num_val;
                    aux <= EQ;
                end
                else if (is_op)
                begin
                    next_state <= OP;
                    operation <= op_val;
                    num1_bcd <= out_ALU;
                    aux <= EQ;
                end
                else 
                begin
                    next_state <= N1;
                    num1_bcd <= 0;
                    aux <= EQ;
                end
            default:
                begin
                    next_state <= N1;
                    num1_bcd <= 0;
                    num2_bcd <= 0;
                    operation <= 0;
                    aux <= N1;
                end
        endcase

    // Transición de estado sincronizada al clock (rst asíncrono activo en 0).
    always @(negedge rst, posedge clk)
        if (rst == 0) curr_state <= N1;
        else curr_state <= next_state;

endmodule
