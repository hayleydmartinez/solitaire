module setup(clk, rst, stock_pile, talon_pile, tableau1, tableau2, tableau3, tableau4, tableau5, tableau6, tableau7, ready);
    parameter HEARTS = 2'b00;
    parameter CLUBS = 2'b01;
    parameter DIAMONDS = 2'b10;
    parameter SPADES = 2'b11;

    input clk, rst;

    output ready;

    output reg [24*7-1:0] stock_pile = 0; 
    output reg [24*7-1:0] talon_pile = 0;

    output reg [19*7-1:0] tableau1 = 0;
    output reg [19*7-1:0] tableau2 = 0;
    output reg [19*7-1:0] tableau3 = 0;
    output reg [19*7-1:0] tableau4 = 0;
    output reg [19*7-1:0] tableau5 = 0;
    output reg [19*7-1:0] tableau6 = 0;
    output reg [19*7-1:0] tableau7 = 0;

    wire [52*7-1:0] madeDeck;
    reg [52*7-1:0] deck = 0;
    wire deck_created;
    reg piles_created = 0;

    // create deck
    make_deck get_deck(.clk(clk), .rst(rst), .deck(madeDeck), .finished(deck_created));

    // pseudo-random number generator
    reg [10:0] seed_num = 32;
    reg [10:0] data_next = 0;
    
    reg [6:0] tempCard = 0;
    reg [10:0] deckCount = 0, i = 0, j = 0;

    // modelled from stackoverflow
    function [10:0] random_number(input [10:0] data);
        begin
            random_number = (data_next*5 + 17)/6 + 7;
            random_number = {random_number[4:0], random_number[10:5]};
        end
    endfunction

    always @(posedge clk, rst) begin
        if (rst || !deck_created) begin
            // initialize tableaus to 0
            for (i = 0; i < 19; i = i+1) tableau1[i*7+6 -: 7] = 7'b0000000;
            for (i = 0; i < 19; i = i+1) tableau2[i*7+6 -: 7] = 7'b0000000;
            for (i = 0; i < 19; i = i+1) tableau3[i*7+6 -: 7] = 7'b0000000;
            for (i = 0; i < 19; i = i+1) tableau4[i*7+6 -: 7] = 7'b0000000;
            for (i = 0; i < 19; i = i+1) tableau5[i*7+6 -: 7] = 7'b0000000;
            for (i = 0; i < 19; i = i+1) tableau6[i*7+6 -: 7] = 7'b0000000;
            for (i = 0; i < 19; i = i+1) tableau7[i*7+6 -: 7] = 7'b0000000;
        end
        else if(!piles_created) begin
            deck = madeDeck;
            for(i = 51; i != 0; i = i-1) begin
                data_next = random_number(seed_num);
                //$fwrite('h8000_0001, "%d,%d\n", seed_num, i);
                seed_num = data_next;
                j = seed_num % 52;
                tempCard = deck[i*7+6 -: 7];
                deck[i*7+6 -: 7] = deck[j*7+6 -: 7];
                deck[j*7+6 -: 7] = tempCard;
            end

            deckCount = 0;
            for (i = 0; i < 1; i = i+1) begin
                tableau1[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                if(i == 0)
                    tableau1[i*7] = 1;
                deckCount = deckCount + 1;
            end
            for (i = 0; i < 2; i = i+1) begin
                tableau2[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                if(i == 1)
                    tableau2[i*7] = 1;
                deckCount = deckCount + 1;
            end
            for (i = 0; i < 3; i = i+1) begin
                tableau3[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                if(i == 2)
                    tableau3[i*7] = 1;
                deckCount = deckCount + 1;
            end
            for (i = 0; i < 4; i = i+1) begin
                tableau4[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                if(i == 3)
                    tableau4[i*7] = 1;
                deckCount = deckCount + 1;
            end
            for (i = 0; i < 5; i = i+1) begin
                tableau5[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                if(i == 4)
                    tableau5[i*7] = 1;
                deckCount = deckCount + 1;
            end
            for (i = 0; i < 6; i = i+1) begin
                tableau6[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                if(i == 5)
                    tableau6[i*7] = 1;
                deckCount = deckCount + 1;
            end
            for (i = 0; i < 7; i = i+1) begin
                tableau7[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                if(i == 6)
                    tableau7[i*7] = 1;
                deckCount = deckCount + 1;
            end

            for (i = 0; i < 24; i = i+1) begin
                stock_pile[i*7+6 -: 7] = deck[deckCount*7+6 -: 7];
                stock_pile[i*7] = 1;
                deckCount = deckCount + 1;
            end

            piles_created = 1;
        end
    end

    assign ready = deck_created & piles_created;

endmodule

module make_deck(clk, rst, deck, finished);
    parameter HEARTS = 2'b00;
    parameter CLUBS = 2'b01;
    parameter DIAMONDS = 2'b10;
    parameter SPADES = 2'b11;

    input clk, rst;
    output reg [52*7-1:0] deck = 0;

    reg [6:0] current_card = 0;
    reg [10:0] deck_count = 0;
    reg [3:0] rank_count = 1;

    output reg finished = 0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_card = 0;
            deck_count = 0;
            finished = 0;
            deck = 0;
            rank_count = 1;
        end
        else if (deck_count == 52) begin
            finished = 1;
        end
        else if (!finished) begin
            current_card[6:3] = rank_count;
            current_card[2:1] = HEARTS;
            current_card[0]   = 0;
            deck[deck_count*7+6 -: 7] = current_card;
            deck_count = deck_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = SPADES;
            current_card[0]   = 0;
            deck[deck_count*7+6 -: 7] = current_card;
            deck_count = deck_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = DIAMONDS;
            current_card[0]   = 0;
            deck[deck_count*7+6 -: 7] = current_card;
            deck_count = deck_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = CLUBS;
            current_card[0]   = 0;
            deck[deck_count*7+6 -: 7] = current_card;
            deck_count = deck_count + 1;

            rank_count = rank_count + 1;
        end
    end
endmodule
