module PassThrough(
    input wire clk,
    input wire rst,
    input wire [3:0] num_val,
    input wire [1:0] op_val,
    input wire is_num,
    input wire is_op,
    input wire is_eq,
    output reg [15:0] data_out_bcd,
);

always@(*) begin
    if (rst) begin 
        data_out_bcd <= 16'h1111;
    end else if (is_num) begin
        data_out_bcd <= {12'd0, num_val}; // Extiende num_val a 16 bits
    end else if (is_op) begin
        data_out_bcd <= 16'h1111; // Representación ficticia para operación
    end else if (is_eq) begin
        data_out_bcd <= 16'h2222; // Representación ficticia para igual
    end else begin
        data_out_bcd <= 16'h0000;
    end
end

endmodule