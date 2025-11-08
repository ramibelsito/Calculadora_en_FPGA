// fsm_mealy
// ---------
// Controla la secuencia de ingreso de la calculadora:
//   N1 -> OP -> N2 -> EQ, almacenando operandos, operación seleccionada y
//   solicitando el resultado a la ALU cuando corresponde. Implementa una
//   máquina de estados de Mealy porque algunas salidas dependen directamente
//   de las entradas actuales.
// Implementacion de una maquina de estados de Mealy en Verilog
module fsm_mealy (clk, reset, is_op, is_num, is_eq, num1, num2, operation, num_val, op_val, out_ALU);
    input clk, reset, is_op, is_num, is_eq, [3:0] num_val, [1:0] op_val, [15:0] out_ALU;
    output reg [15:0] num1, num2;
    output reg [1:0] operation;
    output reg [2:1] curr_state;
    

    // Podria tener el curr_state como salida para debug
    //output [2:1] curr_state;

    reg [2:1] curr_state, next_state;

    // Asignacion de estados
    parameter [2:1] N1 = 2'b00;
    parameter [2:1] OP = 2'b01;
    parameter [2:1] N2 = 2'b10;
    parameter [2:1] EQ = 2'b11;
    // Lógica de próximo estado y salidas (combinacional).
    // Cada estado modela la captura de operandos u operaciones y
    // actualiza `num1`, `num2` y `operation` según las entradas.
    reg [2:1] aux;
    always @(is_op, is_num, is_eq, curr_state)
        case (curr_state)
            // N1: ingreso del primer operando dígito a dígito hasta recibir una operación.
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
            // OP: espera que se confirme la operación y opcionalmente la cambia.
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
            // N2: ingreso del segundo operando; si llega otro operador se encadena cálculo.
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
                    num1 <= out_ALU;
                    operation <= op_val;
                    next_state <= OP;
                    aux <= N2;
                end
                else 
                begin
                    num2 <= 0;
                    next_state <= N1;
                    aux <= N2;
                end
            // EQ: muestra resultado, pero permite arrancar una nueva operación inmediatamente.
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
                else 
                begin
                    next_state <= N1;
                    num1 <= 0;
                    aux <= EQ;
                end
            default:
                begin
                    next_state <= N1;
                    num1 <= 0;
                    num2 <= 0;
                    operation <= 0;
                    aux <= N1;
                end
        endcase

    // Transición de estado sincronizada al clock (reset asíncrono activo en 0).
    always @(negedge reset, posedge clk)
        if (reset == 0) curr_state <= N1;
        else curr_state <= next_state;

endmodule
