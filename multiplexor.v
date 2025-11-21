// Multiplexor / Display Clock
// ---------------------------
// Genera un clock más lento (`clk_logica`) y un pulso `next_data` para habilitar
// el envío de nuevos datos al display, además de seleccionar qué dato de la
// calculadora debe mostrarse según el estado actual de la FSM.

module multiplexor(
    input clk,
    input rst,
    input [1:0] curr_state,
    input wire [15:0] num1_bcd,
    input wire [15:0] num2_bcd,
    input wire [15:0] out_ALU,
    input wire [1:0] operation,
    output reg [15:0] data_shown);
    // Asignacion de estados
    parameter [2:1] N1 = 2'b00;
    parameter [2:1] OP = 2'b01;
    parameter [2:1] N2 = 2'b10;
    parameter [2:1] EQ = 2'b11;
    
    // Multiplexa qué dato se expone en el display siguiendo el estado actual.
    always @(*) begin
        // creo que falta algo aca

        case(curr_state)
            N1: data_shown <= num1_bcd;
            N2: data_shown <= num2_bcd;
            //OP: data_shown <= operation;
            EQ: data_shown <= out_ALU;
            default: data_shown <= 16'b0;
        endcase

    end
endmodule
