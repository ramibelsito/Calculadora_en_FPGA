// Multiplexor / Display Clock
// ---------------------------
// Genera un clock más lento (`clk_logica`) y un pulso `next_data` para habilitar
// el envío de nuevos datos al display, además de seleccionar qué dato de la
// calculadora debe mostrarse según el estado actual de la FSM.

module 
    input clk,
    input reset
    input [2:1] curr_state,
    input reg [15:0] num1, num2, out_ALU,
    input reg [1:0] operation,
    output clk_logica,
    output next_data, // enable para el bloque de display
    output reg [2:1] available_state
    // Asignacion de estados
    parameter [2:1] N1 = 2'b00;
    parameter [2:1] OP = 2'b01;
    parameter [2:1] N2 = 2'b10;
    parameter [2:1] EQ = 2'b11;

    // Divisor de frecuencia sencillo que también produce un pulso de enable
    // cuando el clock derivado cae a 0 para avanzar el display.
    always  @ posedge(clk) begin
        
        cnt <= cnt + 1;
        next_data <= 0;
        if (cnt == MAX_COUNT) begin
            cnt <= 0;
            clk_logica <= ~clk_logica;
            if (clk_logica == 0) begin
                next_data <= 1;
            end
        end
    end

    // Multiplexa qué dato se expone en el display siguiendo el estado actual.
    always @(*) begin
        ..
        case(curr_state)
            N1: available_state <= num1;
            N2: available_state <= num2;
            //OP: available_state <= operation;
            EQ: available_state <= out_ALU;
            default: available_state <= 16'b0;
        endcase

    end
endmodule
