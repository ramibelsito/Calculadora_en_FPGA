// CuasiCLK del Display y Multiplexor

module 
    input clk,
    input reset
    output clk_logica,
    output next_data // enable para el bloque de display


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

    always @(*) begin
        ..
        case(current_state)