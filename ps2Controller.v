module keyboard(
	input wire ps2_clk, // Clock pin form keyboard
	input wire ps2_data, //Data pin form keyboard
	output reg [1:0] outData //Printing input data to led
);

	reg [7:0] data_curr;
	reg [7:0] data_pre;
	reg [3:0] b;
	reg flag;

	initial
	begin
		b<=4'h1;
		flag<=1'b0;
		data_curr<=8'hf0;
		data_pre<=8'hf0;
		outData<=2'b00;
	end

	always @(negedge ps2_clk) //Activating at negative edge of clock from keyboard
	begin
	case(b)
		1:; //first bit
		2:data_curr[0]<=ps2_data;
		3:data_curr[1]<=ps2_data;
		4:data_curr[2]<=ps2_data;
		5:data_curr[3]<=ps2_data;
		6:data_curr[4]<=ps2_data;
		7:data_curr[5]<=ps2_data;
		8:data_curr[6]<=ps2_data;
		9:data_curr[7]<=ps2_data;
		10:flag<=1'b1; //Parity bit
		11:flag<=1'b0; //Ending bit
	endcase

	if(b<=10)
 		b<=b+1;
 	else 
	if(b==11)
 		b<=1;
	end 

	always@(posedge flag) // Printing data obtained to led
	begin
		if(data_curr==8'hf0)
			if(data_pre == 8'h1c)
				outData<=2'b01;
			else
				outData<=2'b00;
	else
		begin
			outData<=2'b00;
			data_pre<=data_curr;
		end
	end
 
endmodule
