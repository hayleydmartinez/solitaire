module inputOutput(clk, rst, stock_pile, talon_pile, tableau1, tableau2, tableau3, tableau4, tableau5, tableau6, tableau7, foundation_cards, ready, successful, source, source_offset, destination, input_ready);
	parameter HEARTS = 2'b00;
	parameter CLUBS = 2'b01;
	parameter DIAMONDS = 2'b10;
	parameter SPADES = 2'b11;

    input clk, rst;

    input ready, successful;

    input [24*7-1:0] stock_pile; 
    input [24*7-1:0] talon_pile;

    input [19*7-1:0] tableau1;
    input [19*7-1:0] tableau2;
    input [19*7-1:0] tableau3;
    input [19*7-1:0] tableau4;
    input [19*7-1:0] tableau5;
    input [19*7-1:0] tableau6;
    input [19*7-1:0] tableau7;
    input [4*7-1:0] foundation_cards;

    output reg [3:0] source = 0, destination = 0, source_offset = 0;
    output reg input_ready = 1;

    reg [7:0] userInput = 0;

    reg [19*7-1:0] currTableau = 0;

    function [1:0] writeCard (input [6:0] card);
	    begin
	    	if(card[0] == 1) begin
	    		$fwrite('h8000_0001, "[");

	    		if(card[6:3] == 13)
					$fwrite('h8000_0001, "K");
	    		else if(card[6:3] == 12)
					$fwrite('h8000_0001, "Q");
	    		else if(card[6:3] == 11)
					$fwrite('h8000_0001, "J");
	    		else if(card[6:3] == 1)
					$fwrite('h8000_0001, "A");
	    		else if(card[6:3] > 1 && card[6:3] < 11)
					$fwrite('h8000_0001, "%d", card[6:3]);

	    		if(card[2:1] == HEARTS)
					$fwrite('h8000_0001, "H");
	    		else if(card[2:1] == DIAMONDS)
					$fwrite('h8000_0001, "D");
	    		else if(card[2:1] == SPADES)
					$fwrite('h8000_0001, "S");
	    		else if(card[2:1] == CLUBS)
					$fwrite('h8000_0001, "C");

	    		$fwrite('h8000_0001, "]");
	    	end 
	    	else begin
				$fwrite('h8000_0001, "[X]");
	    	end

	    	writeCard = 1;
	    end
	endfunction


    function [3:0] tableauNum (input [7:0] character);
	    begin
	    	case (character)
	    		48: tableauNum = 0;
	    		49: tableauNum = 1;
	    		50: tableauNum = 2;
	    		51: tableauNum = 3;
	    		52: tableauNum = 4;
	    		53: tableauNum = 5;
	    		54: tableauNum = 6;
	    		55: tableauNum = 7;
	    		default: tableauNum = 8;
	    	endcase
	    end
	endfunction

	reg tableauStarted = 0, tableauComplete = 0;
	reg [6:0] i = 0, fges, talon_count = 0; 
	reg [1:0] writeCardOutput;

	always @(clk) begin
		if(clk & ready) begin
			input_ready = 0;

			if(foundation_cards == 28'b1101111110110111010111101001) begin
				$fwrite('h8000_0001, "YOU WIN! CONGRATS!!!\n\n");

				$fwrite('h8000_0001, "FOUNDATION PILES\n-----------\n");
		        for (i = 0; i < 4; i = i+1) begin
		        	if(foundation_cards[i*7+6 -: 7] != 0) begin
		        		writeCardOutput = writeCard(foundation_cards[i*7+6 -: 7]);
		        	end
		        	else
		        		$fwrite('h8000_0001, "[X]");
		        end
				$fwrite('h8000_0001, "\n\n");
			end
			else begin
				if(!successful)
					$fwrite('h8000_0001, "Invalid move, try again\n");

				$fwrite('h8000_0001, "TALON PILE\n-----------\n");
				talon_count = 0;
				if(talon_pile != 0) begin
			        for (i = 24; i != 0; i = i-1) begin
			        	if(talon_count < 3 && talon_pile[(i-1)*7] == 1) begin
			        		writeCardOutput = writeCard(talon_pile[(i-1)*7+6 -: 7]);
			        		talon_count = talon_count + 1;
			        	end
			        end
		        end
		        else
					$fwrite('h8000_0001, "No cards in talon pile yet");
				$fwrite('h8000_0001, "\n\n");

				$fwrite('h8000_0001, "TABLEAUS\n-----------\n");
				tableauStarted = 0;
				tableauComplete = 0;
				currTableau = tableau1;
				$fwrite('h8000_0001, "T1: ");
				if(currTableau != 0) begin
			        for (i = 0; i < 19; i = i+1) begin
			        	if(currTableau[i*7] == 1)
			        		tableauStarted = 1;
			        	else if(tableauStarted)
			        		tableauComplete = 1;

			        	if(!tableauComplete)
			        		writeCardOutput = writeCard(currTableau[i*7+6 -: 7]);
			        end
		        end

				$fwrite('h8000_0001, "\n");
				tableauStarted = 0;
				tableauComplete = 0;
				currTableau = tableau2;
				$fwrite('h8000_0001, "T2: ");
				if(currTableau != 0) begin
			        for (i = 0; i < 19; i = i+1) begin
			        	if(currTableau[i*7] == 1)
			        		tableauStarted = 1;
			        	else if(tableauStarted)
			        		tableauComplete = 1;

			        	if(!tableauComplete)
			        		writeCardOutput = writeCard(currTableau[i*7+6 -: 7]);
			        end
		        end

				$fwrite('h8000_0001, "\n");
				tableauStarted = 0;
				tableauComplete = 0;
				currTableau = tableau3;
				$fwrite('h8000_0001, "T3: ");
				if(currTableau != 0) begin
			        for (i = 0; i < 19; i = i+1) begin
			        	if(currTableau[i*7] == 1)
			        		tableauStarted = 1;
			        	else if(tableauStarted)
			        		tableauComplete = 1;

			        	if(!tableauComplete)
			        		writeCardOutput = writeCard(currTableau[i*7+6 -: 7]);
			        end
		        end

				$fwrite('h8000_0001, "\n");
				tableauStarted = 0;
				tableauComplete = 0;
				currTableau = tableau4;
				$fwrite('h8000_0001, "T4: ");
				if(currTableau != 0) begin
			        for (i = 0; i < 19; i = i+1) begin
			        	if(currTableau[i*7] == 1)
			        		tableauStarted = 1;
			        	else if(tableauStarted)
			        		tableauComplete = 1;

			        	if(!tableauComplete)
			        		writeCardOutput = writeCard(currTableau[i*7+6 -: 7]);
			        end
		        end

				$fwrite('h8000_0001, "\n");
				tableauStarted = 0;
				tableauComplete = 0;
				currTableau = tableau5;
				$fwrite('h8000_0001, "T5: ");
				if(currTableau != 0) begin
			        for (i = 0; i < 19; i = i+1) begin
			        	if(currTableau[i*7] == 1)
			        		tableauStarted = 1;
			        	else if(tableauStarted)
			        		tableauComplete = 1;

			        	if(!tableauComplete)
			        		writeCardOutput = writeCard(currTableau[i*7+6 -: 7]);
			        end
		        end

				$fwrite('h8000_0001, "\n");
				tableauStarted = 0;
				tableauComplete = 0;
				currTableau = tableau6;
				$fwrite('h8000_0001, "T6: ");
				if(currTableau != 0) begin
			        for (i = 0; i < 19; i = i+1) begin
			        	if(currTableau[i*7] == 1)
			        		tableauStarted = 1;
			        	else if(tableauStarted)
			        		tableauComplete = 1;

			        	if(!tableauComplete)
			        		writeCardOutput = writeCard(currTableau[i*7+6 -: 7]);
			        end
		        end

				$fwrite('h8000_0001, "\n");
				tableauStarted = 0;
				tableauComplete = 0;
				currTableau = tableau7;
				$fwrite('h8000_0001, "T7: ");
				if(currTableau != 0) begin
			        for (i = 0; i < 19; i = i+1) begin
			        	if(currTableau[i*7] == 1)
			        		tableauStarted = 1;
			        	else if(tableauStarted)
			        		tableauComplete = 1;

			        	if(!tableauComplete)
			        		writeCardOutput = writeCard(currTableau[i*7+6 -: 7]);
			        end
		        end
				$fwrite('h8000_0001, "\n\n");

				$fwrite('h8000_0001, "FOUNDATION PILES\n-----------\n");
		        for (i = 0; i < 4; i = i+1) begin
		        	if(foundation_cards[i*7+6 -: 7] != 0) begin
		        		writeCardOutput = writeCard(foundation_cards[i*7+6 -: 7]);
		        	end
		        	else
		        		$fwrite('h8000_0001, "[X]");
		        end
				$fwrite('h8000_0001, "\n\n");

				$fwrite('h8000_0001, "Which pile would you like to move from?\nInput numbers 1-7 to move from tableaus 1-7 respectively, 0 to move from talon pile, 8 to draw a card from the stock pile, or 9 to let the computer find a move.\n");
				userInput = $fgetc('h8000_0000);
				$fgetc('h8000_0000);
				source = tableauNum(userInput);

				if(0 < source && source < 8) begin
					$fwrite('h8000_0001, "How many cards would you like to move from the source tableau?\n");
					userInput = $fgetc('h8000_0000);
					$fgetc('h8000_0000);
					source_offset = tableauNum(userInput);
					source_offset = source_offset - 1;
				end

				if(source < 8) begin
					$fwrite('h8000_0001, "Which pile would you like to move to?\nInput numbers 1-7 to move to tableaus 1-7 respectively, or 0 to move to foundation pile.\n");
					userInput = $fgetc('h8000_0000);
					$fgetc('h8000_0000);
					destination = tableauNum(userInput);
				end
			end

	        input_ready = 1;
	    end
	end
endmodule