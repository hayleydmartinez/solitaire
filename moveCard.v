`include "parameters.v"

module moveCard(clk, rst, deck, stock_pile, talon_pile, tableau1, tableau2, tableau3, tableau4, tableau5, tableau6, tableau7, ready)
    input clk, rst;
    input [6:0] deck [0:51];
    input ready;

    input [6:0] stock_pile_input [0:2]; 
    input [6:0] talon_pile_input [0:23];

    input [6:0] tableau1_input [0:12];
    input [6:0] tableau2_input [0:13];
    input [6:0] tableau3_input [0:14];
    input [6:0] tableau4_input [0:15];
    input [6:0] tableau5_input [0:16];
    input [6:0] tableau6_input [0:17];
    input [6:0] tableau7_input [0:18];
    input [6:0] foundation_cards_input [51:0];

    input ready;
    input [3:0] source; //which place to pull card from
    input [3:0] destination; //which place to place card at
    // if source is 0, then the stock pile is used. if 1 <= source =< 7, then the source corresponds to the tableau number
    // if destination is 0, then the foundation pile is used. if 1 <= destination =< 7, then the destination corresponds to the tableau number
    input [3:0] source_offset; //if 0, then the lowest flipped card from the source is used. if 1, then the second lowest flipped card is used, and so on
    reg [19*7-1:0] currSource = 0;
    reg [19*7-1:0] currDestination = 0;

    output reg successful = 0;
    output reg [6:0] stock_pile [0:2] = 0; 
    output reg [6:0] talon_pile [0:23] = 0;

    output reg [19*7-1:0] tableau1 = 0;
    output reg [19*7-1:0] tableau2 = 0;
    output reg [19*7-1:0] tableau3 = 0;
    output reg [19*7-1:0] tableau4 = 0;
    output reg [19*7-1:0] tableau5 = 0;
    output reg [19*7-1:0] tableau6 = 0;
    output reg [19*7-1:0] tableau7 = 0;
    output reg [6:0] foundation_cards [51:0] = 0;


    function [19*7-1:0] getPile (input [3:0] deckNumber);
	    begin
	    	case (deckNumber)
	    		1: begin
	    			getPile = tableau1_input;
	    		end
	    		2: begin
	    			getPile = tableau2_input;
	    		end
	    		3: begin
	    			getPile = tableau3_input;
	    		end
	    		4: begin
	    			getPile = tableau4_input;
	    		end
	    		5: begin
	    			getPile = tableau5_input;
	    		end
	    		6: begin
	    			getPile = tableau6_input;
	    		end
	    		7: begin
	    			getPile = tableau7_input;
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

    always @(posedge clk) begin
    	if(ready) begin
    		//set all outputs to inputs
    		successful = 0;

    		if(1 =< source && source =< 7 && 1 =< destination && destination =< 7) begin
    			currSource = getPile(source);
    			currDestination = getPile(destination);
    			offsetBegin = 0;
    			offsetCounter = source_offset;
    			sourceLoopComplete = 0;

    			for(i = 18; i >= 0; i = i - 1) begin
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

    			offsetBegin = 0;
    			for(i = 18; i >= 0; i = i - 1) begin
    				if(!offsetBegin && currSource[i*7] == 1) begin
    					offsetBegin = 1;
    					destinationIndex = i;
    				end
    			end

    			if(sourceLoopComplete) begin
    				if(((currSource[sourceIndex*7+2 -: 2] == CLUBS && (currDestination[destinationIndex*7+2 -: 2] == HEARTS || currDestination[destinationIndex*7+2 -: 2] == DIAMONDS))
    				|| (currSource[sourceIndex*7+2 -: 2] == SPADES && (currDestination[destinationIndex*7+2 -: 2] == HEARTS || currDestination[destinationIndex*7+2 -: 2] == DIAMONDS))
    				|| (currSource[sourceIndex*7+2 -: 2] == HEARTS && (currDestination[destinationIndex*7+2 -: 2] == SPADES || currDestination[destinationIndex*7+2 -: 2] == CLUBS))
    				|| (currSource[sourceIndex*7+2 -: 2] == DIAMONDS && (currDestination[destinationIndex*7+2 -: 2] == SPADES || currDestination[destinationIndex*7+2 -: 2] == CLUBS)))
    				&& currSource[sourceIndex*7+6 -: 4] + 1 == currDestination[destinationIndex*7+6 -: 4]) begin
    					destinationIndex = destinationIndex + 1;

    					if(sourceIndex > 0)
    						currSource[(sourceIndex-1)*7] = 1;

    					for(offsetCounter = 0; offsetCounter <= source_offset; offsetCounter = offsetCounter = offsetCounter + 1) begin
    						currDestination[destinationIndex+6 -: 7] = currSource[sourceIndex+6 -: 7] | 7'b0000001;
    						currSource[sourceIndex+6 -: 7] = 7'b0000000;
    						destinationIndex = destinationIndex + 1;
    						sourceIndex = sourceIndex + 1;
    					end
    				end

    				setPile(source, currSource);
    				setPile(destination, currDestination);
    				successful = 1;
    			end
    		end

    	end
    end

endmodule