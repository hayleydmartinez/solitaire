`include "parameters.v"

module talon_stock_functionality(
    input clk,
    input rst, 
    input check_pile, 
    input setup_ready,
    input [24 * CARD_SIZE - 1:0] talon_pile_init, 
    input [24 * CARD_SIZE - 1:0] stock_pile_init, 
    input [4:0] talon_size_init, 
    input [4:0] stock_size_init,
    output reg [24 * CARD_SIZE - 1:0] talon_pile, 
    output reg [24 * CARD_SIZE - 1:0] stock_pile, 
    output reg [4:0] talon_size, 
    output reg [4:0] stock_size);

    always @(posedge clk, posedge rst, posedge check_pile) begin
        if (rst || !setup_ready) begin
            talon_size <= 24;
            stock_size <= 0;
        end

        if (check_pile) begin
            if (talon_size_init == 0) begin
                talon_pile <= stock_pile_init;
                stock_pile <= 0;
                talon_size <= stock_size_init;
                stock_size <= 0;
            end
            else begin
                stock_pile[stock_size * CARD_SIZE +: CARD_SIZE - 1] = talon_pile_init[(24 - talon_size_init) * CARD_SIZE +: CARD_SIZE - 1];
                talon_pile[(24 - talon_size_init) * CARD_SIZE +: CARD_SIZE - 1] = 0;
                stock_size = stock_size_init + 1;
                talon_size = talon-size_init - 1;
            end
        end
    end
    
endmodule