`include "parameters.v"

module setup(clk, rst, stock_pile, talon_pile, tableau1, tableau2, tableau3, tableau4, tableau5, tableau6, tableau7, ready)
    input clk, rst;

    output ready;

    output reg [2 * CARD_SIZE - 1:0] stock_pile = 0; 
    output reg [24 * CARD_SIZE - 1:0] talon_pile = 0;

    output reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau1 = 0;
    output reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau2 = 0;
    output reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau3 = 0;
    output reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau4 = 0;
    output reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau5 = 0;
    output reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau6 = 0;
    output reg [MAX_TABLEAU_SIZE * CARD_SIZE - 1:0] tableau7 = 0;

    reg [DECK_SIZE * CARD_SIZE - 1:0] deck = 0;
    reg deck_created;

    // create deck
    make_deck get_deck(.clk(clk), .rst(rst), .deck(deck), .finished(deck_created));

    // pseudo-random number generator
    reg [5:0] seed_num;
    random_number tableau_num(.clk(clk), .rst(rst), .data(seed_num));

    // populate tableaus
    integer i;
    reg [2:0] curr_count [0:6];
    reg [2:0] max_count [0:6];
    reg [6:0] full_count;

    wire [2:0] random_tableau;
    wire [5:0] random_card;
    reg [5:0] card;
    assign random_tableau = (seed_num % 7);
    assign random_card = (seed_num % 52);

    reg [2:0] tableau_index;
    reg [2:0] tableau_max;
    
    wire tableaus_created = (full_count == 7);

    always @(posedge clk, posedge rst) begin
        if (rst || !deck_created) begin
            // initialize tableaus to 0
            tableau1 = 0;
            tableau2 = 0;
            tableau3 = 0;
            tableau4 = 0;
            tableau5 = 0;
            tableau6 = 0;
            tableau7 = 0;
            
            // initialize tableau counts to 0
            for (i = 0; i < 7; i = i+1) curr_count[i] = 3'b000;

            // initialize tableau maximums
            for (i = 0; i < 7; i = i+1) max_count[i] = i + 1;

            // initialize count of full tableaus
            full_count = 0;
        end

        card = random_card;

        // if the tableau isn't full and that card is present, and there are still cards in the deck
        if ((!tableaus_created) && (curr_count[random_tableau] != max_count[random_tableau]) && deck[card * CARD_SIZE +: CARD_SIZE - 1] != 6'b000000) begin
            tableau_index = curr_count[random_tableau];
            tableau_max = max_count[random_tableau];
            case(random_tableau)
                3'b000: begin
                    if (tableau_index == tableau_max - 1)
                        tableau1[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = (deck[card * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001);
                    else
                        tableau1[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = deck[card * CARD_SIZE +: CARD_SIZE - 1];
                end
                3'b001: begin
                    if (tableau_index == tableau_max - 1)
                        tableau2[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = (deck[card * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001);
                    else
                        tableau2[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = deck[card * CARD_SIZE +: CARD_SIZE - 1];
                end
                3'b010: begin
                    if (tableau_index == tableau_max - 1)
                        tableau3[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = (deck[card * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001);
                    else
                        tableau3[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = deck[card * CARD_SIZE +: CARD_SIZE - 1];
                end
                3'b011: begin
                    if (tableau_index == tableau_max - 1)
                        tableau4[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = (deck[card * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001);
                    else
                        tableau4[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = deck[card * CARD_SIZE +: CARD_SIZE - 1];
                end
                3'b100: begin
                    if (tableau_index == tableau_max - 1)
                        tableau5[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = (deck[card * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001);
                    else
                        tableau5[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = deck[card * CARD_SIZE +: CARD_SIZE - 1];
                end
                3'b101: begin
                    if (tableau_index == tableau_max - 1)
                        tableau6[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = (deck[card * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001);
                    else
                        tableau6[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = deck[card * CARD_SIZE +: CARD_SIZE - 1];
                end
                3'b110: begin
                    if (tableau_index == tableau_max - 1)
                        tableau7[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = (deck[card * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001);
                    else
                        tableau7[tableau_index * CARD_SIZE +: CARD_SIZE - 1] = deck[card * CARD_SIZE +: CARD_SIZE - 1];
                end
                default: 
            endcase
            deck[card * CARD_SIZE +: CARD_SIZE - 1] = 6'b000000;
            curr_count[random_tableau] = curr_count[random_tableau] + 1;
            full_count = (tableau_index == tableau_max - 1) ? full_count + 1 : full_count;
        end
    end

    // populate stock pile and talon pile
    reg [1:0] stock_count;
    reg [4:0] talon_count;
    reg [5:0] deck_index;
    wire stock_talon_created = (stock_count == 3) & (talon_count == 24);

    always @(posedge clk, posedge rst) begin
        if (rst || !tableaus_created) begin
            stock_pile = 0;
            talon_pile = 0;

            stock_count = 0;
            talon_count = 0;
            deck_index = 0;
        end

        // fill stock pile first
        if (stock_count != 3) begin
            if (deck[deck_index * CARD_SIZE +: CARD_SIZE - 1] != 0) begin
                // remember: all of the cards in the stock pile are visible
                stock_pile[stock_count * CARD_SIZE +: CARD_SIZE - 1] = deck[deck_index * CARD_SIZE +: CARD_SIZE - 1] | 6'b000001;
                stock_count = stock_count + 1;
            end
            deck_index = deck_index + 1;
        end
        // file talon pile second
        else if (talon_count != 24) begin
            if (deck[deck_index * CARD_SIZE +: CARD_SIZE - 1] != 0) begin
                talon_pile[talon_count * CARD_SIZE +: CARD_SIZE - 1] = deck[deck_index  * CARD_SIZE +: CARD_SIZE - 1];
                talon_count = talon_count + 1;
            end
            deck_index = deck_index + 1;
        end
    end

    assign ready = deck_created & tableaus_created & stock_talon_created;

endmodule

module make_deck(clk, rst, deck, finished) begin
    input clk, rst;
    output reg [DECK_SIZE * CARD_SIZE - 1:0] deck = 0;

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
            finished = 1;
        end
        else if (!finished) begin
            current_card[6:3] = rank_count;
            current_card[2:1] = HEARTS;
            current_card[0]   = 0;
            deck[deck_count * CARD_SIZE +: CARD_SIZE - 1] = current_card;
            rank_count = rank_count + 1;
            deck_count = deck_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = SPADES;
            current_card[0]   = 0;
            deck[deck_count * CARD_SIZE +: CARD_SIZE - 1] = current_card;
            rank_count = rank_count + 1;
            deck_count = deck_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = DIAMONDS;
            current_card[0]   = 0;
            deck[deck_count * CARD_SIZE +: CARD_SIZE - 1] = current_card;
            rank_count = rank_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = CLUBS;
            current_card[0]   = 0;
            deck[deck_count * CARD_SIZE +: CARD_SIZE - 1] = current_card;
            rank_count = rank_count + 1;
            deck_count = deck_count + 1;
        end
    end
end

// modelled from stackoverflow
module random_number(clk, rst, data) begin
    input clk, rst;
    output reg [5:0] data_next;

    always @(*) begin
        data_next[5] = data[5]^data[2];
        data_next[4] = data[4]^data[1];
        data_next[3] = data[3]^data[0];
        data_next[2] = data[2]^data_next[5];
        data_next[1] = data[1]^data_next[4];
        data_next[0] = data[0]^data_next[3];
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            data <= 5'h3f;
        else
            data <= data_next;
    end

endmodule