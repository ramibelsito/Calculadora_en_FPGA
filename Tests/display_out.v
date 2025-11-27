// display_out
// -----------
// Convierte 4 dígitos en BCD a su representación de 7 segmentos (más DP) y
// envía los 32 bits resultantes en serie cada `send_interval` ciclos. Sirve como
// interfaz simple entre la lógica de la calculadora y un shift-register/driver
// externo del display.
module display_out(
    input wire clk,
    input wire rst,
    input wire [15:0] bcd_in,
    output wire data_out,
    output wire data_ready,
    output reg clk_logica,
);


// Conversor BCD a 32 bits en segment_data (cada nibble se mapea a 8 segmentos).
localparam [7:0] Disp_0 = 8'b11111100; // 0
localparam [7:0] Disp_1 = 8'b01100000; // 1
localparam [7:0] Disp_2 = 8'b11011010; // 2
localparam [7:0] Disp_3 = 8'b11110010; // 3
localparam [7:0] Disp_4 = 8'b01100110; // 4
localparam [7:0] Disp_5 = 8'b10110110; // 5
localparam [7:0] Disp_6 = 8'b10111110; // 6
localparam [7:0] Disp_7 = 8'b11100000; // 7
localparam [7:0] Disp_8 = 8'b11111110; // 8
localparam [7:0] Disp_9 = 8'b11110110; // 9
localparam [7:0] Error_Disp = 8'b00000010; // -

function [7:0] bcd2seg;
  input [3:0] b;
  begin
    case (b)
      4'd0: bcd2seg = Disp_0;
      4'd1: bcd2seg = Disp_1;
      4'd2: bcd2seg = Disp_2;
      4'd3: bcd2seg = Disp_3;
      4'd4: bcd2seg = Disp_4;
      4'd5: bcd2seg = Disp_5;
      4'd6: bcd2seg = Disp_6;
      4'd7: bcd2seg = Disp_7;
      4'd8: bcd2seg = Disp_8;
      4'd9: bcd2seg = Disp_9;
      default: bcd2seg = Error_Disp;
    endcase
  end
endfunction

// Calculamos internamente los 32 bits de segmentos a partir de los 4 nibbles BCD.
wire [31:0] segment_data_calc;
// LSB primero
assign segment_data_calc = { bcd2seg(bcd_in[15:12]), 
                             bcd2seg(bcd_in[11:8]), 
                             bcd2seg(bcd_in[7:4]), 
                             bcd2seg(bcd_in[3:0]) }; 

// Paralelo a serie de 32 bits: toma `segment_data_calc` y lo desplaza cada next_data.
reg next_data;
parameter [31:0] send_interval = 31'd33; // controla la cadencia de envío en bits.
reg [31:0] interval_counter;
reg [31:0] segment_data_out;
reg [20:0] cnt ;


parameter integer MAX_COUNT = 20'd50; // Ajusta este valor para cambiar la frecuencia

// Divisor de frecuencia sencillo que también produce un pulso de next_data
// cuando el clock derivado cae a 0 para avanzar el display.
always  @ (posedge(clk)) begin
    if (rst) begin
        clk_logica <= clk;
        cnt <= 0;
        next_data <= 0;
    end
    else 
    begin
    if (cnt == MAX_COUNT) begin
        cnt <= 0;
        clk_logica <= ~clk_logica;
        if (clk_logica == 0) begin
            next_data <= 1;
        end
    end
    else begin
        cnt <= cnt + 1;
        next_data <= 0;
    end
    end
end

// Gestiona el registro de desplazamiento y el contador que determina cuándo
// recargar el paquete completo de 32 bits.
always @(posedge clk)
    if (rst) begin
        interval_counter <= 0;
        segment_data_out <= 0; 
    end else  begin
    if ((cnt == MAX_COUNT) && clk_logica)
    begin
        if (interval_counter == 0)
            segment_data_out <= segment_data_calc;
        else 
            segment_data_out <= (segment_data_out >> 1);

        if (interval_counter <= send_interval)
            interval_counter <= (interval_counter + 1);
        else interval_counter <= 0;
    end 
    end
assign data_ready = (interval_counter == 33);
assign data_out = segment_data_out[0];

endmodule
