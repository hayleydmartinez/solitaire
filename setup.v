`include "parameters.v"

module setup(clk, rst, deck, stock_pile, talon_pile, tableau1, tableau2, tableau3, tableau4, tableau5, tableau6, tableau7, ready)
    input clk, rst;
    input [6:0] deck [0:51];

    output ready;

    output [6:0] stock_pile [0:2]; 
    output [6:0] talon_pile [0:23];

    output [6:0] tableau1 [0:12];
    output [6:0] tableau2 [0:13];
    output [6:0] tableau3 [0:14];
    output [6:0] tableau4 [0:15];
    output [6:0] tableau5 [0:16];
    output [6:0] tableau6 [0:17];
    output [6:0] tableau7 [0:18];

    // read in deck file
    initial
    begin
        deck.shuffle;
    end

    $random() % 7;


endmodule

module make_deck(clk, rst, deck, finished) begin
    input clk, rst;
    output [6:0] deck [0:51];

    reg [6:0] unshuffled_deck [0:51];
    reg [6:0] current_card;

    reg [5:0] deck_count = 0;
    reg [3:0] rank_count = 1;

    reg finished;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_card = 0;
            deck_count = 0;
            finished = 0;
        end

        if (deck_count != 52) begin
            unshuffled_deck.shuffle()
            finished = 1;
        end
        else if (!finished) begin
            current_card[6:3] = rank_count;
            current_card[2:1] = HEARTS;
            current_card[0]   = 0;
            unshuffled_deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = SPADES;
            current_card[0]   = 0;
            unshuffled_deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = DIAMONDS;
            current_card[0]   = 0;
            unshuffled_deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = CLUBS;
            current_card[0]   = 0;
            unshuffled_deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            deck_count = deck_count + 4;
        end
    end
end