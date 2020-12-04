`include "parameters.v"
`include "setup.v"

module solitaire(clk, rst) begin
    input clk, rst;

    // foundation registers
    reg [6:0] heart_foundation, club_foundation, diamond_foundation, spade_foundation;
    reg [6:0] foundation_cards [51:0];

    // side pile registers
    reg [3 * CARD_SIZE - 1:0] stock_pile = 0; // can be 3 cards shown at once
    reg [24 * CARD_SIZE - 1:0] talon_pile = 0; // will have 24 cards at beginning of game

    // card explanation
    // 4 bits: card rank; 2 bits: card suit; 1 bit: card visibility

    //tableau registers
    reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau1 = 0;
    reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau2 = 0;
    reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau3 = 0;
    reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau4 = 0;
    reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau5 = 0;
    reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau6 = 0;
    reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau7 = 0;

    // if this is zero, you've won the game
    reg [44:0] covered_cards;

    reg setup_ready;
    solitaire_setup setup(.clk(clk), 
                          .rst(rst),
                          .stock_pile(stock_pile),
                          .talon_pile(talon_pile),
                          .tableau1(tableau1),
                          .tableau2(tableau2), 
                          .tableau3(tableau3), 
                          .tableau4(tableau4), 
                          .tableau5(tableau5), 
                          .tableau6(tableau6), 
                          .tableau7(tableau7), 
                          .ready(setup_ready));

endmodule