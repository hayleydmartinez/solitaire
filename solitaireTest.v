module solitaire(clk, rst);
    parameter HEARTS = 2'b00;
    parameter CLUBS = 2'b01;
    parameter DIAMONDS = 2'b10;
    parameter SPADES = 2'b11;

    input clk, rst;

    // foundation registers
    wire [4*7-1:0] foundation_cards;

    // side pile registers
    wire [24*7-1:0] stock_pile_input;  // can be 3 cards shown at once
    wire [24*7-1:0] talon_pile_input; // will have 24 cards at beginning of game

    //tableau registers
    wire [19*7-1:0] tableau1_input;
    wire [19*7-1:0] tableau2_input;
    wire [19*7-1:0] tableau3_input;
    wire [19*7-1:0] tableau4_input;
    wire [19*7-1:0] tableau5_input;
    wire [19*7-1:0] tableau6_input;
    wire [19*7-1:0] tableau7_input;

    // side pile registers
    wire [24*7-1:0] stock_pile;  // can be 3 cards shown at once
    wire [24*7-1:0] talon_pile; // will have 24 cards at beginning of game

    //tableau registers
    wire [19*7-1:0] tableau1;
    wire [19*7-1:0] tableau2;
    wire [19*7-1:0] tableau3;
    wire [19*7-1:0] tableau4;
    wire [19*7-1:0] tableau5;
    wire [19*7-1:0] tableau6;
    wire [19*7-1:0] tableau7;

    // card explanation
    // 4 bits: card rank; 2 bits: card suit; 1 bit: card visibility

    wire [3:0] source, destination, source_offset;
    wire input_ready, successful;

    // if this is zero, you've won the game
    wire [44:0] covered_cards;

    wire setup_ready;
    setup solitaire_setup(.clk(clk), 
                          .rst(rst),
                          .stock_pile(stock_pile_input),
                          .talon_pile(talon_pile_input),
                          .tableau1(tableau1_input),
                          .tableau2(tableau2_input), 
                          .tableau3(tableau3_input), 
                          .tableau4(tableau4_input), 
                          .tableau5(tableau5_input), 
                          .tableau6(tableau6_input), 
                          .tableau7(tableau7_input),
                          .ready(setup_ready));


    inputOutput         io(.clk(clk), 
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
                          .foundation_cards(foundation_cards),
                          .ready(setup_ready & move_ready),
                          .successful(successful),
                          .source(source),
                          .source_offset(source_offset),
                          .destination(destination),
                          .input_ready(input_ready));

    moveCard          move(.clk(clk), 
                          .rst(rst),
                          .stock_pile_input(stock_pile_input),
                          .talon_pile_input(talon_pile_input),
                          .tableau1_input(tableau1_input),
                          .tableau2_input(tableau2_input), 
                          .tableau3_input(tableau3_input), 
                          .tableau4_input(tableau4_input), 
                          .tableau5_input(tableau5_input), 
                          .tableau6_input(tableau6_input), 
                          .tableau7_input(tableau7_input), 
                          .source(source),
                          .source_offset(source_offset),
                          .destination(destination),
                          .successful(successful),
                          .ready(setup_ready & input_ready),
                          .stock_pile(stock_pile),
                          .talon_pile(talon_pile),
                          .tableau1(tableau1),
                          .tableau2(tableau2), 
                          .tableau3(tableau3), 
                          .tableau4(tableau4), 
                          .tableau5(tableau5), 
                          .tableau6(tableau6), 
                          .tableau7(tableau7), 
                          .foundation_cards(foundation_cards),
                          .move_ready(move_ready));


    /* modules we need to write
       - randomizer to fill the tableaus [x]
       - input/output to terminal (could be separate) []
       - lets user look at talon pile []
       - lets user move card from tableau to tableau []
       - lets user move card to foundation []
       - lets user move card from talon to tableau/foundation []
       - reveals a card once tableau has no visible cards []
       - checks if u won or not []
    */

endmodule