`include "parameters.v"

module solitaire(clk, rst) begin
    input clk, rst;

    // foundation registers
    reg [6:0] heart_foundation, club_foundation, diamond_foundation, spade_foundation;
    reg [6:0] foundation_cards [51:0];

    // side pile registers
    reg [6:0] stock_pile [0:2]; // can be 3 cards shown at once
    reg [6:0] talon_pile [0:23]; // will have 24 cards at beginning of game

    // card explanation
    // 4 bits: card rank; 2 bits: card suit; 1 bit: card visibility

    //tableau registers
    reg [6:0] tableau1 [0:12];
    reg [6:0] tableau2 [0:13];
    reg [6:0] tableau3 [0:14];
    reg [6:0] tableau4 [0:15];
    reg [6:0] tableau5 [0:16];
    reg [6:0] tableau6 [0:17];
    reg [6:0] tableau7 [0:18];

    // if this is zero, you've won the game
    reg [44:0] covered_cards;

    /* modules we need to write
       - randomizer to fill the tableaus
       - input/output to terminal (could be separate)
       - lets user look at talon pile
       - lets user move card from tableau to tableau
       - lets user move card to foundation
       - lets user move card from talon to tableau/foundation
       - reveals a card once tableau has no visible cards
       - checks if u won or not
    */

endmodule