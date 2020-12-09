module solitaire_tb;
	reg clk = 0, rst = 0;

	solitaire slt(.clk(clk), .rst(rst));

	initial begin
		rst = 1;
		#50;
		rst = 0;
	end

    always begin
      clk = 1'b1;
      #5;
      clk = 1'b0;
      #5;
    end



endmodule