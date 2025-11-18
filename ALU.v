// ALU_BCD
// ----------
// Suma/resta saturada directamente en BCD (4 dígitos) sin convertir a binario.
// operation: 2'b10 => resta; cualquier otro valor => suma.

module ALU (
    input  wire [15:0] num1_bcd,   // D3 D2 D1 D0 (cada nibble 0..9)
    input  wire [15:0] num2_bcd,   // D3 D2 D1 D0 (cada nibble 0..9)
    input  wire [1:0]  operation,  // 2'b01 => + , 2'b10 => -
    output reg  [15:0] out_ALU,    // resultado en BCD (4 dígitos)
);
    // ------------------------------------------------------------
    // Funciones auxiliares (combinacionales)
    // ------------------------------------------------------------
    // Suma BCD dígito a dígito (LSB primero). Devuelve carry en [16].
    function automatic [16:0] bcd_add4 (input [15:0] a, input [15:0] b);
        integer i;
        reg [4:0] tmp;
        reg       carry;
        reg [16:0] res;
        begin
            carry = 1'b0;
            res   = 17'd0;
            for (i = 0; i < 4; i = i + 1) begin
                tmp = {1'b0, a[i*4 +: 4]} + {1'b0, b[i*4 +: 4]} + carry;
                if (tmp > 5'd9) tmp = tmp + 5'd6; // corrección BCD
                carry = tmp[4];
                res[i*4 +: 4] = tmp[3:0];
            end
            res[16] = carry;
            bcd_add4 = res;
        end
    endfunction

    // Resta BCD dígito a dígito (LSB primero). Devuelve borrow final en [16].
    function automatic [16:0] bcd_sub4 (input [15:0] a, input [15:0] b);
        integer i;
        reg signed [4:0] tmp;
        reg borrow;
        reg [16:0] res;
        begin
            borrow = 1'b0;
            res    = 17'd0;
            for (i = 0; i < 4; i = i + 1) begin
                tmp = {1'b0, a[i*4 +: 4]} - {1'b0, b[i*4 +: 4]} - borrow;
                if (tmp < 0) begin
                    tmp    = tmp + 5'd10;
                    borrow = 1'b1;
                end else begin
                    borrow = 1'b0;
                end
                res[i*4 +: 4] = tmp[3:0];
            end
            res[16] = borrow;
            bcd_sub4 = res;
        end
    endfunction

    // Comparación BCD para detectar underflow antes de restar.
    function automatic bcd_lt (input [15:0] a, input [15:0] b);
        begin
            if      (a[15:12] < b[15:12]) bcd_lt = 1'b1;
            else if (a[15:12] > b[15:12]) bcd_lt = 1'b0;
            else if (a[11:8]  < b[11:8])  bcd_lt = 1'b1;
            else if (a[11:8]  > b[11:8])  bcd_lt = 1'b0;
            else if (a[7:4]   < b[7:4])   bcd_lt = 1'b1;
            else if (a[7:4]   > b[7:4])   bcd_lt = 1'b0;
            else if (a[3:0]   < b[3:0])   bcd_lt = 1'b1;
            else                           bcd_lt = 1'b0;
        end
    endfunction

    // ------------------------------------------------------------
    // ALU combinacional
    // ------------------------------------------------------------
    wire is_sub = (operation == 2'd2);

    wire [16:0] add_raw   = bcd_add4(num1_bcd, num2_bcd);
    wire        add_ov    = add_raw[16];
    wire [15:0] add_sat   = add_ov ? 16'h9999 : add_raw[15:0];

    wire [16:0] sub_raw   = bcd_sub4(num1_bcd, num2_bcd);
    wire        sub_uf    = sub_raw[16] | bcd_lt(num1_bcd, num2_bcd);
    wire [15:0] sub_sat   = sub_uf ? 16'h0000 : sub_raw[15:0];

    always @* begin
        if (is_sub) out_ALU = sub_sat;      // resta saturada a 0
        else        out_ALU = add_sat;      // suma saturada a 9999
    end

endmodule
