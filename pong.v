`include "bottons.v"

module pong(clk,BTN_EAST, BTN_WEST, Reset, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B, oLed);
input clk;
input wire BTN_EAST, BTN_WEST;
input Reset;
output vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B;
output wire [7:0] oLed;

wire inDisplayArea;
wire [9:0] CounterX;
wire [8:0] CounterY;
reg [7:0] oLedCount;
reg [8:0] PaddlePosition;
reg [9:0] ballX;
reg [8:0] ballY;
reg ball_inX, ball_inY;
reg ball_dirX, ball_dirY;

hvsync_generator syncgen(.clk(clk),.Reset(Reset), .vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), 
                            .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));

wire left, right;

debounce deboright(.PB(BTN_EAST), .clk(clk), .PB_state(),.PB_down(right),.PB_up());
debounce deboleft (.PB(BTN_WEST), .clk(clk), .PB_state(),.PB_down(left),.PB_up());

always @(posedge clk)
if(left ^ right)
begin
	if(right)
	begin
		if(~&PaddlePosition)        // make sure the value doesn't overflow
			PaddlePosition <= PaddlePosition + 64;

	end
	else
	begin
		if(|PaddlePosition)        // make sure the value doesn't underflow
			PaddlePosition <= PaddlePosition - 64;

	end
end



//////////////////////
always @(posedge clk)
if(ball_inX==0) 
	ball_inX <= (CounterX==ballX) & ball_inY; 
	else
		ball_inX <= !(CounterX==ballX+16);

always @(posedge clk)
if(ball_inY==0) 
	ball_inY <= (CounterY==ballY); 
	else 
		ball_inY <= !(CounterY==ballY+16);

wire ball = ball_inX & ball_inY;
//////////////////////


// Draw a border around the screen
wire border = (CounterX[9:3]==0) || (CounterX[9:3]==79) || (CounterY[8:3]==0) || (CounterY[8:3]==59);
wire paddle = (CounterX>=PaddlePosition+8) && (CounterX<=PaddlePosition+120) && (CounterY[8:4]==27);
wire borderDown = (CounterY[8:3]==59);

////////
wire BouncingObject = border | paddle; // active if the border or paddle is redrawing itself

reg ResetCollision;
always @(posedge clk) ResetCollision <= (CounterY==500) & (CounterX==0);  // active only once for every video frame

reg CollisionX1, CollisionX2, CollisionY1, CollisionY2, collisionPaddle, collisionDown;
always @(posedge clk) if(ResetCollision) CollisionX1<=0; else if(BouncingObject & (CounterX==ballX   ) & (CounterY==ballY+ 8)) CollisionX1<=1;
always @(posedge clk) if(ResetCollision) CollisionX2<=0; else if(BouncingObject & (CounterX==ballX+16) & (CounterY==ballY+ 8)) CollisionX2<=1;
always @(posedge clk) if(ResetCollision) CollisionY1<=0; else if(BouncingObject & (CounterX==ballX+ 8) & (CounterY==ballY   )) CollisionY1<=1;
always @(posedge clk) if(ResetCollision) CollisionY2<=0; else if(BouncingObject & (CounterX==ballX+ 8) & (CounterY==ballY+16)) CollisionY2<=1;
always @(posedge clk) if(ResetCollision) collisionPaddle<=0; else if(paddle & (CounterX==ballX+ 8) & (CounterY==ballY+16)) collisionPaddle<=1;
always @(posedge clk) if(ResetCollision) collisionDown<=0; else if(borderDown & (CounterX==ballX+ 8) & (CounterY==ballY+16)) collisionDown<=1;


/////////////////////////////////////////////////////////////////
wire UpdateBallPosition = ResetCollision;  // update the ball position at the same time that we reset the collision detectors

reg [3:0] velocity;
reg newGame;

always @(posedge clk)
begin
if (collisionDown)
		newGame<=0;
	else 
		newGame<=1;
end 

always @(posedge clk)
if(UpdateBallPosition && newGame)
begin
	if(collisionPaddle)
	begin
		oLedCount <= oLedCount + 1;
	end	
	if (oLedCount <9)
		velocity <= 1;
	if (oLedCount > 9 && oLedCount < 19)
		velocity <= 2;
	if (oLedCount > 19 && oLedCount < 25)
		velocity <= 3;
	if (oLedCount > 25 && oLedCount < 31)
		velocity <= 4;

	if(~(CollisionX1 & CollisionX2))        // if collision on both X-sides, don't move in the X direction
	begin
		ballX <= ballX + (ball_dirX ? -velocity : velocity);
		if(CollisionX2)
			ball_dirX <= 1; 
			else if(CollisionX1)
				ball_dirX <= 0;
	end

	if(~(CollisionY1 & CollisionY2))        // if collision on both Y-sides, don't move in the Y direction
	begin
		ballY <= ballY + (ball_dirY ? -velocity : velocity);
		if(CollisionY2) 
			begin
			ball_dirY <= 1; 
			end
			else if(CollisionY1) 
				ball_dirY <= 0;
	end

end



assign oLed = oLedCount;
/////////////////////////////////////////////////////////////////
wire R = BouncingObject | ball;
wire G = BouncingObject ;
wire B = BouncingObject | ball;

reg vga_R, vga_G, vga_B;
always @(posedge clk)
begin
  vga_R <= R & inDisplayArea;
  vga_G <= G & inDisplayArea;
  vga_B <= B & inDisplayArea;
end

endmodule 


