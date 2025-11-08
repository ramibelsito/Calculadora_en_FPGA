// ALU_BCD
// ----------
// Convierte dos operandos BCD de 4 dígitos a binario para operar con suma/resta saturada
// (0..9999) y finalmente vuelve al formato BCD. Se reutiliza el mismo código de operación
// de 2 bits que generan el teclado/FSM (2'b10 => resta).

module ALU_BCD (
    input  wire [15:0] num1_bcd,   // D3 D2 D1 D0 (cada nibble 0..9)
    input  wire [15:0] num2_bcd,   // D3 D2 D1 D0 (cada nibble 0..9)
    input  wire [1:0]  operacion,  // 2'b01 => + , 2'b10 => -
    output reg  [15:0] out_ALU      // resultado en BCD (4 dígitos)
);

    // ------------------------------------------------------------
    // Funciones auxiliares (combinacionales)
    // ------------------------------------------------------------

    // BCD (4 dígitos) -> binario (0..9999)
    function automatic [13:0] bcd_to_bin (input [15:0] bcd);
        integer th, h, t, u;
        begin
            th = bcd[15:12]; // millares
            h  = bcd[11:8];  // centenas
            t  = bcd[7:4];   // decenas
            u  = bcd[3:0];   // unidades
            bcd_to_bin = th*1000 + h*100 + t*10 + u; // 14 bits alcanzan (9999)
        end
    endfunction

    // binario (0..9999) -> BCD (4 dígitos)
    function automatic [15:0] bin_to_bcd (input [13:0] bin);
        integer n, th, h, t, u, rem;
        begin
            n   = (bin > 9999) ? 9999 : bin; // seguridad
            th  = n / 1000;                  // 0..9
            rem = n % 1000;
            h   = rem / 100;                 // 0..9
            rem = rem % 100;
            t   = rem / 10;                  // 0..9
            u   = rem % 10;                  // 0..9
            bin_to_bcd = {th[3:0], h[3:0], t[3:0], u[3:0]};
        end
    endfunction

    // ------------------------------------------------------------
    // ALU combinacional
    // ------------------------------------------------------------
    // Operandos convertidos a binario para simplificar las operaciones aritméticas.
    wire [13:0] a_bin = bcd_to_bin(num1_bcd);
    wire [13:0] b_bin = bcd_to_bin(num2_bcd);

    // Decodificación simple de operación desde dos bits
    // 2'b10 => resta; cualquier otro => suma.
    wire is_sub = (operacion == 2'd2);

    reg [13:0] res_bin;

    // Hace la operación solicitada y convierte el resultado de vuelta a BCD.
    always @* begin
        if (is_sub) begin
            // Resta saturada a 0 en caso de underflow
            if (a_bin >= b_bin) res_bin = a_bin - b_bin;
            else                res_bin = 14'd0;
        end else begin
            // Suma saturada a 9999 en caso de overflow
            if (a_bin + b_bin > 14'd9999) res_bin = 14'd9999;
            else                          res_bin = a_bin + b_bin;
        end

        out_ALU = bin_to_bcd(res_bin);
    end

endmodule
