module moveCard(clk, rst, stock_pile_input, talon_pile_input, tableau1_input, tableau2_input, tableau3_input, tableau4_input, tableau5_input, tableau6_input, tableau7_input, ready, 
				source, source_offset, destination, successful, stock_pile, talon_pile, tableau1, tableau2, tableau3, tableau4, tableau5, tableau6, tableau7, foundation_cards, move_ready);	
	parameter HEARTS = 2'b00;
	parameter CLUBS = 2'b01;
	parameter DIAMONDS = 2'b10;
	parameter SPADES = 2'b11;


    input clk, rst;

    input [24*7-1:0] stock_pile_input; 
    input [24*7-1:0] talon_pile_input;

    input [19*7-1:0] tableau1_input;
    input [19*7-1:0] tableau2_input;
    input [19*7-1:0] tableau3_input;
    input [19*7-1:0] tableau4_input;
    input [19*7-1:0] tableau5_input;
    input [19*7-1:0] tableau6_input;
    input [19*7-1:0] tableau7_input;

    input ready;
    input [3:0] source; //which place to pull card from
    input [3:0] destination; //which place to place card at
    // if source is 0, then the stock pile is used. if 1 <= source =< 7, then the source corresponds to the tableau number
    // if destination is 0, then the foundation pile is used. if 1 <= destination =< 7, then the destination corresponds to the tableau number
    input [3:0] source_offset; //if 0, then the lowest flipped card from the source is used. if 1, then the second lowest flipped card is used, and so on
    reg [19*7-1:0] currSource = 0;
    reg [19*7-1:0] currDestination = 0;

    output reg successful = 1;
    output reg [24*7-1:0] stock_pile = 0; 
    output reg [24*7-1:0] talon_pile = 0;

    output reg [19*7-1:0] tableau1 = 0;
    output reg [19*7-1:0] tableau2 = 0;
    output reg [19*7-1:0] tableau3 = 0;
    output reg [19*7-1:0] tableau4 = 0;
    output reg [19*7-1:0] tableau5 = 0;
    output reg [19*7-1:0] tableau6 = 0;
    output reg [19*7-1:0] tableau7 = 0;
    output reg [4*7-1:0] foundation_cards = 0;

    output reg move_ready = 0;


    function [19*7-1:0] getPile (input [3:0] deckNumber);
	    begin
	    	case (deckNumber)
	    		1: begin
	    			getPile = tableau1;
	    		end
	    		2: begin
	    			getPile = tableau2;
	    		end
	    		3: begin
	    			getPile = tableau3;
	    		end
	    		4: begin
	    			getPile = tableau4;
	    		end
	    		5: begin
	    			getPile = tableau5;
	    		end
	    		6: begin
	    			getPile = tableau6;
	    		end
	    		7: begin
	    			getPile = tableau7;
	    		end
	    	endcase
	    end
	endfunction

    function [1:0] setPile (input [3:0] deckNumber, [19*7-1:0] pileInput);
	    begin
	    	case (deckNumber)
	    		1: begin
	    			tableau1 = pileInput;
	    		end
	    		2: begin
	    			tableau2 = pileInput;
	    		end
	    		3: begin
	    			tableau3 = pileInput;
	    		end
	    		4: begin
	    			tableau4 = pileInput;
	    		end
	    		5: begin
	    			tableau5 = pileInput;
	    		end
	    		6: begin
	    			tableau6 = pileInput;
	    		end
	    		7: begin
	    			tableau7 = pileInput;
	    		end
	    	endcase
	    	setPile = 1;
	    end
	endfunction


	reg [6:0] sourceIndex = 18, destinationIndex = 18, i = 18;
	reg [3:0] offsetCounter = 0;
	reg offsetBegin = 0, sourceLoopComplete = 0;
	reg [1:0] setPileOutput;

    always @(clk) begin
	    if(ready & !clk & !move_ready) begin
	    	stock_pile = stock_pile_input;
	    	talon_pile = talon_pile_input;
	    	tableau1 = tableau1_input;
	    	tableau2 = tableau2_input;
	    	tableau3 = tableau3_input;
	    	tableau4 = tableau4_input;
	    	tableau5 = tableau5_input;
	    	tableau6 = tableau6_input;
	    	tableau7 = tableau7_input;
	    	move_ready = 1;
    	end
    	else if(ready & !clk) begin
	    	move_ready = 0;
    		successful = 0;

    		if(0 < source && source < 8 && 0 < destination && destination < 8) begin
    			currSource = getPile(source);
    			currDestination = getPile(destination);
    			offsetBegin = 0;
    			offsetCounter = source_offset;
    			sourceLoopComplete = 0;

    			for(i = 18; i != 0; i = i - 1) begin
    				if(!sourceLoopComplete) begin
	    				if(!offsetBegin && currSource[i*7] == 1) begin
	    					offsetBegin = 1;
	    				end
	    				else if(offsetBegin && currSource[i*7] == 1) begin
	    					offsetCounter = offsetCounter - 1;
	    				end
	    				else if(offsetBegin && currSource[i*7] == 0) begin
	    					//invalid input
	    				end

	    				if(offsetBegin && offsetCounter == 0) begin
	    					sourceLoopComplete = 1;
	    					sourceIndex = i;
	    				end
    				end
    			end
    			//For i == 0
				if(!sourceLoopComplete) begin
    				if(!offsetBegin && currSource[i*7] == 1) begin
    					offsetBegin = 1;
    				end
    				else if(offsetBegin && currSource[i*7] == 1) begin
    					offsetCounter = offsetCounter - 1;
    				end
    				else if(offsetBegin && currSource[i*7] == 0) begin
    					//invalid input
    				end

    				if(offsetBegin && offsetCounter == 0) begin
    					sourceLoopComplete = 1;
    					sourceIndex = i;
    				end
				end

    			offsetBegin = 0;
    			for(i = 18; i != 0; i = i - 1) begin
    				if(!offsetBegin && currDestination[i*7] == 1) begin
    					offsetBegin = 1;
    					destinationIndex = i;
    				end
    			end
    			//For i == 0
				if(!offsetBegin && currDestination[i*7] == 1) begin
					offsetBegin = 1;
					destinationIndex = i;
				end

    			if(sourceLoopComplete) begin
    				if(((currSource[sourceIndex*7+2 -: 2] == CLUBS && (currDestination[destinationIndex*7+2 -: 2] == HEARTS || currDestination[destinationIndex*7+2 -: 2] == DIAMONDS))
    				|| (currSource[sourceIndex*7+2 -: 2] == SPADES && (currDestination[destinationIndex*7+2 -: 2] == HEARTS || currDestination[destinationIndex*7+2 -: 2] == DIAMONDS))
    				|| (currSource[sourceIndex*7+2 -: 2] == HEARTS && (currDestination[destinationIndex*7+2 -: 2] == SPADES || currDestination[destinationIndex*7+2 -: 2] == CLUBS))
    				|| (currSource[sourceIndex*7+2 -: 2] == DIAMONDS && (currDestination[destinationIndex*7+2 -: 2] == SPADES || currDestination[destinationIndex*7+2 -: 2] == CLUBS)))
    				&& currSource[sourceIndex*7+6 -: 4] + 1 == currDestination[destinationIndex*7+6 -: 4]) begin
    					destinationIndex = destinationIndex + 1;

    					if(sourceIndex > 0)
    						currSource[(sourceIndex-1)*7] = 1'b1;

    					for(offsetCounter = 0; offsetCounter <= source_offset; offsetCounter = offsetCounter + 1) begin
    						currDestination[destinationIndex*7+6 -: 7] = currSource[sourceIndex*7+6 -: 7] | 7'b0000001;
    						currSource[sourceIndex*7+6 -: 7] = 7'b0000000;
    						destinationIndex = destinationIndex + 1;
    						sourceIndex = sourceIndex + 1;
    					end

	    				setPileOutput = setPile(source, currSource);
	    				setPileOutput = setPile(destination, currDestination);
	    				successful = 1;
    				end
    			end
    		end

    		else if(0 == source && 0 < destination && destination < 8 && talon_pile != 0) begin
    			currDestination = getPile(destination);

    			offsetBegin = 0;
    			for(i = 24; i != 0; i = i - 1) begin
    				if(!offsetBegin && talon_pile[(i-1)*7] == 1) begin
    					offsetBegin = 1;
    					sourceIndex = i-1;
    				end
    			end

    			offsetBegin = 0;
    			for(i = 19; i != 0; i = i - 1) begin
    				if(!offsetBegin && currDestination[(i-1)*7] == 1) begin
    					offsetBegin = 1;
    					destinationIndex = i-1;
    				end
    			end

    			if(sourceLoopComplete) begin
    				if(((talon_pile[sourceIndex*7+2 -: 2] == CLUBS && (currDestination[destinationIndex*7+2 -: 2] == HEARTS || currDestination[destinationIndex*7+2 -: 2] == DIAMONDS))
    				|| (talon_pile[sourceIndex*7+2 -: 2] == SPADES && (currDestination[destinationIndex*7+2 -: 2] == HEARTS || currDestination[destinationIndex*7+2 -: 2] == DIAMONDS))
    				|| (talon_pile[sourceIndex*7+2 -: 2] == HEARTS && (currDestination[destinationIndex*7+2 -: 2] == SPADES || currDestination[destinationIndex*7+2 -: 2] == CLUBS))
    				|| (talon_pile[sourceIndex*7+2 -: 2] == DIAMONDS && (currDestination[destinationIndex*7+2 -: 2] == SPADES || currDestination[destinationIndex*7+2 -: 2] == CLUBS)))
    				&& talon_pile[sourceIndex*7+6 -: 4] + 1 == currDestination[destinationIndex*7+6 -: 4]) begin
    					destinationIndex = destinationIndex + 1;

						currDestination[destinationIndex*7+6 -: 7] = talon_pile[sourceIndex*7+6 -: 7];
						talon_pile[sourceIndex*7+6 -: 7] = 7'b0000000;

	    				setPileOutput = setPile(destination, currDestination);
	    				successful = 1;
    				end
    			end
    		end

    		else if(0 == source && 0 == destination && talon_pile != 0) begin
    			offsetBegin = 0;
    			for(i = 24; i != 0; i = i - 1) begin
    				if(!offsetBegin && talon_pile[(i-1)*7] == 1) begin
    					offsetBegin = 1;
    					sourceIndex = i-1;
    				end
    			end

    			destinationIndex = 0;
    			destinationIndex[1:0] = talon_pile[sourceIndex+2 -: 2];

    			if(foundation_cards[destinationIndex*7+6 -: 4] + 1 == talon_pile[sourceIndex*7+6 -: 4]) begin
    				foundation_cards[destinationIndex*7+6 -: 7] = talon_pile[sourceIndex*7+6 -: 7];
    				talon_pile[sourceIndex*7+6 -: 7] = 7'b0000000;
    				successful = 1;
    			end
    		end

    		else if(0 < source && source < 8 && 0 == destination) begin
    			currSource = getPile(source);
    			offsetBegin = 0;
    			for(i = 19; i != 0; i = i - 1) begin
    				if(!offsetBegin && currSource[(i-1)*7] == 1) begin
    					offsetBegin = 1;
    					sourceIndex = i-1;
    				end
    			end

    			destinationIndex = 0;
    			destinationIndex[1:0] = currSource[sourceIndex+2 -: 2];

    			if(foundation_cards[destinationIndex*7+6 -: 4] + 1 == currSource[sourceIndex*7+6 -: 4]) begin
    				foundation_cards[destinationIndex*7+6 -: 7] = currSource[sourceIndex*7+6 -: 7];
    				currSource[sourceIndex*7+6 -: 7] = 7'b0000000;
	    			setPileOutput = setPile(source, currSource);
    				successful = 1;
    			end
    		end

    		else if(8 == source) begin
    			if(stock_pile == 0) begin
    				stock_pile = talon_pile;
    				talon_pile = 0;
    			end
    			offsetBegin = 0;
    			for(i = 0; i < 24; i = i+1) begin
    				if(!offsetBegin && stock_pile[i*7] == 1) begin
    					offsetBegin = 1;
    					sourceIndex = i;
    				end
    			end
    			
    			talon_pile[sourceIndex*7+6 -: 7] = stock_pile[sourceIndex*7+6 -: 7];
    			stock_pile[sourceIndex*7+6 -: 7] = 7'b0000000;

	    		successful = 1;
    		end
	    	move_ready = 1;
    	end
    end

endmodule