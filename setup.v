`include "parameters.v"

module setup(clk, rst, deck, stock_pile, talon_pile, tableau1, tableau2, tableau3, tableau4, tableau5, tableau6, tableau7, ready)
    input clk, rst;
    input [6:0] deck [0:51];

    output ready;

    output reg [6:0] stock_pile [0:2]; 
    output reg [6:0] talon_pile [0:23];

    output reg [6:0] tableau1 [0:12];
    output reg [6:0] tableau2 [0:13];
    output reg [6:0] tableau3 [0:14];
    output reg [6:0] tableau4 [0:15];
    output reg [6:0] tableau5 [0:16];
    output reg [6:0] tableau6 [0:17];
    output reg [6:0] tableau7 [0:18];

    reg [6:0] finished_deck [0:51];
    reg deck_created;

    // create deck
    make_deck get_deck(.clk(clk), .rst(rst), .deck(finished_deck), .finished(deck_created));

    // pseudo-random number generator
    reg [5:0] seed_num;
    random_number tableau_num(.clk(clk), .rst(rst), .data(seed_num));

    // populate tableaus
    integer i;
    reg [2:0] curr_count [0:6];
    reg [2:0] max_count [0:6];
    reg [5:0] deck_count;

    wire [2:0] random_tableau;
    assign random_tableau = (seed_num % 7);
    assign random_card = (seed_num % 52);

    reg [2:0] tableau_index;

    always @(posedge clk, posedge rst) begin
        if (rst || !deck_created) begin
            // initialize tableaus to 0
            for (i = 0; i < 13; i = i+1) tableau1[i] = 6'b000000;
            for (i = 0; i < 14; i = i+1) tableau2[i] = 6'b000000;
            for (i = 0; i < 15; i = i+1) tableau3[i] = 6'b000000;
            for (i = 0; i < 16; i = i+1) tableau4[i] = 6'b000000;
            for (i = 0; i < 17; i = i+1) tableau5[i] = 6'b000000;
            for (i = 0; i < 18; i = i+1) tableau6[i] = 6'b000000;
            for (i = 0; i < 19; i = i+1) tableau7[i] = 6'b000000;
            
            // initialize tableau counts to 0
            for (i = 0; i < 7; i = i+1) curr_count[i] = 3'b000;

            // initialize tableau maximums
            for (i = 0; i < 7; i = i+1) max_count[i] = i + 1;

            ready = 0;
        end

        if (curr_count[random_tableau] != max_count[random_tableau]) begin
            tableau_index = curr_count[random_tableau];
            case(random_tableau)
                3'b000: begin
                    tableau1[]
                end
            endcase
        end

    end


endmodule

module make_deck(clk, rst, deck, finished) begin
    input clk, rst;
    output reg [6:0] deck [0:51];

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
            deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = SPADES;
            current_card[0]   = 0;
            deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = DIAMONDS;
            current_card[0]   = 0;
            deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            current_card[6:3] = rank_count;
            current_card[2:1] = CLUBS;
            current_card[0]   = 0;
            deck[deck_count] = current_card;
            rank_count = rank_count + 1;

            deck_count = deck_count + 4;
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