
module hvsync_generator(clk,Reset, vga_h_sync, vga_v_sync, inDisplayArea, CounterX, CounterY);
input clk;
input Reset;
output vga_h_sync, vga_v_sync;
output inDisplayArea;
output [9:0] CounterX;
output [8:0] CounterY;

//////////////////////////////////////////////////
reg pixelReg;
wire pixelNext, pixelClock ;

reg [9:0] CounterX;
reg [8:0] CounterY;
wire CounterXmaxed = (CounterX==800);

// Generate 25 MHz VGA clock
	assign pixelNext = ~pixelReg; // next state is complement of current
	assign pixelClock = (pixelReg == 0);
	
always @(posedge clk,posedge Reset)
begin
	if(Reset) // If reset, all values are set to zero
		pixelReg <=0;
		else
			pixelReg <= pixelNext;
end

always @(posedge pixelClock)
if(CounterXmaxed)
	CounterX <= 0;
else
	CounterX <= CounterX + 1;

always @(posedge pixelClock)
if(CounterXmaxed) CounterY <= CounterY + 1;

reg	vga_HS, vga_VS;
always @(posedge pixelClock)
begin
	vga_HS <= (CounterX[9:4]==6'h29); // change this value to move the display horizontally
	vga_VS <= (CounterY==480); // change this value to move the display vertically
end

reg inDisplayArea;
always @(posedge pixelClock)
if(inDisplayArea==0)
	inDisplayArea <= (CounterXmaxed) && (CounterY<480);
else
	inDisplayArea <= !(CounterX==639);
	
assign vga_h_sync = ~vga_HS;
assign vga_v_sync = ~vga_VS;

endmodule
