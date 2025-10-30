module display_out(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [15:0] bcd_in,
    output wire data_out,
    output wire sending_data
);


// Conversor BCD a 32 bits en segment_data
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

// Calculamos internamente los 32 bits de segmentos a partir de los 4 nibbles BCD
wire [31:0] segment_data_calc;
// LSB primero
assign segment_data_calc = { bcd2seg(bcd_in[15:12]), 
                             bcd2seg(bcd_in[11:8]), 
                             bcd2seg(bcd_in[7:4]), 
                             bcd2seg(bcd_in[3:0]) }; 

// Paralelo a Serie de 32 bits

parameter [31:0] send_interval = 31'd33;
reg [31:0] interval_counter;
reg [31:0] segment_data_out;

always @(negedge clk)
    if (rst) begin
        interval_counter <= 0;
        segment_data_out <= 0; 
    end else if (enable) begin
        if (interval_counter == 0)
            segment_data_out <= segment_data_calc;
        else 
            segment_data_out <= segment_data_out >> 1;

        if (interval_counter <= send_interval)
            interval_counter <= interval_counter + 1;
        else   
            interval_counter <= 0;
        
    end

assign sending_data = (interval_counter == 33);
assign data_out = segment_data_out[0];

endmodule