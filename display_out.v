module display_out
(    input wire clk,
    input wire rst,
    input wire enable,
    input wire [15:0] bcd_in,
    input wire [31:0] segment_data,
    output wire data_out,
    output wire sending_data
);

//assign clk = HF_int_osc;


// Conversor BSD a 32 bits en segment_data


// Paralelo a Serie de 32 bits

parameter [31:0] send_interval = 31'd32;
reg [31:0] interval_counter;
reg [31:0] segment_data_out;

always @(negedge clk)
    if (rst) begin
        interval_counter <= 0;
        segment_data_out <= 0; 
    end else if (enable) begin
        if (interval_counter == 0)
            segment_data_out <= segment_data;
        else 
            segment_data_out <= segment_data_out >> 1;

        if (interval_counter <= send_interval)
            interval_counter <= interval_counter + 1;
        else   
            interval_counter <= 0;
        
    end

assign sending_data = (interval_counter == 31);
assign data_out = segment_data_out[0];

endmodule