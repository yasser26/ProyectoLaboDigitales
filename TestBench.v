`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:49:08 06/19/2018 
// Design Name: 
// Module Name:    TestBench 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TestBench;

		// Inputs
	reg clk;
	reg BTN_EAST;
	reg BTN_WEST;
	reg Reset;
	// Outputs
	wire vga_R;
	wire vga_B;
	wire vga_G;
	wire vga_h_sync;
	wire vga_v_sync;
//	wire [7:0] oLed;
	
 
//	reg acuaA, acuaB;
	pong uut (
		.clk(clk),
		.BTN_EAST(BTN_EAST),
	   .BTN_WEST(BTN_WEST),
		.BTN_NORT(BTN_NORT),
		.Reset(Reset),
		.vga_h_sync(vga_h_sync), 
		.vga_v_sync(vga_v_sync), 
		.vga_R(vga_R), 
		.vga_G(vga_G), 
		.vga_B(vga_B)
	//	.oLed(oLed)
	);

	always
	begin
		#5  clk =  ! clk;

	end

	initial begin
		// Initialize Inputs
		clk = 0;
		Reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
		Reset = 1;
		#50
		Reset = 0;
        
		// Add stimulus here

	end


endmodule
