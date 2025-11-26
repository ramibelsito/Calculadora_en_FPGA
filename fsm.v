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
    /*
    always@(*) begin
        case (curr_state)
            N1: begin
            
            end
            OP: begin
            
            end
            N2: begin
            
            end
            EQ: begin
            
            end
            default: ;
        endcase
    
    end
    */
    // Lógica de próximo estado y salidas (combinacional).
    // Cada estado modela la captura de operandos u operaciones y
    // actualiza `num1_bcd`, `num2_bcd` y `operation` según las entradas.
    always @(*)
        case (curr_state)
            // N1: ingreso del primer operando dígito a dígito hasta recibir una operación.
            N1: begin
                if (is_op)
                begin
                    //num1_bcd <= num_val; 
                    next_state <= OP;
                end
                else
                begin
                    //num1_bcd <= 0; 
                    next_state <= N1;
                end
            end
            // OP: espera que se confirme la operación y opcionalmente la cambia.
            OP: begin
                if (is_num)
                begin
                    next_state <= N2;
                end
               else if (is_op)
                begin
                    next_state <= OP;
                end
                else
                begin
                    next_state <= N1;
                end
            end
            // N2: ingreso del segundo operando; si llega otro operador se encadena cálculo.
            N2: begin
                if (is_eq)
                begin
                    next_state <= EQ;
                end
               else if (is_num)
                begin
                    next_state <= N2;
                end
                else if (is_op)
                begin
                    next_state <= OP;
                end
                else 
                begin
                    next_state <= N1;
                end
            end
            // EQ: muestra resultado, pero permite arrancar una nueva operación inmediatamente.
            EQ: begin
                if (is_num)
                begin
                    next_state <= N1;
                end
                else if (is_op)
                begin
                    next_state <= OP;
                end
                else 
                begin
                    next_state <= N1;
                end
            end
            default:
                begin
                    next_state <= N1;
                end
        endcase

    // Transición de estado sincronizada al clock (rst asíncrono activo en 0).
    always @(posedge clk)
    begin
        if (rst == 0) 
        begin 
            curr_state <= N1;
        end
        else 
        begin
            curr_state <= next_state;
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
        end
    end

endmodule
