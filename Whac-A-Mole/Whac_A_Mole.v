/*
Whac_A_Mole.v

COURSE:      		ECE 2220 - Digital logic systems - A01
INSTRUCTOR:  		Douglas Thomson
ASSIGNMENT:  		Term Project
AUTHORS:     		Ohm Patel - 7928829
						Manal Shahab - 7933204
						Aida Mesgar Zadeh - 7933484 
						Hana Dunlop - 7907031
VERSION:     		December 02, 2022
PURPOSE:    		Implement a Whac-A-Mole game through the DE10 board by utilizing 10 switches, 10 LEDs, 4 SSDs and a push button.
		
		
GAME STRUCTURE:  	main module ──> Whac_A_Mole	
						───────────────────────────
						      |
								├─── sub_bin2bcd       
								|                      
								├─── sub_timerCount
			    			   |    |
								|    └── sub_timerClock 		
								| 
								└─── sub_scoreCount    
							        |
								     └── sub_debounce     

								

			  
GAME COMPONENTS:		|	  Component                 |       Pin Name       |   Function 
						 --|------------------------------|----------------------|-----------------------------
						  1|    10 Slide switch           |       SW[0]          |   Toggle switches to 'hit' a mole
						   |                              |       SW[1]          |
							|                              |       SW[2]          |
							|                              |       SW[3]          |
							|                              |       SW[4]          |
							|                              |       SW[5]          |
							|                              |       SW[6]          |
							|                              |       SW[7]          |
							|                              |       SW[8]          |
							|                              |       SW[9]          |
							|                              |                      |
						  2|	  10 LEDS                   |       LEDR[0]        |   Moles are randomly displayed on an LED
						   |                              |       LEDR[1]        |
							|                              |       LEDR[2]        |
							|                              |       LEDR[3]        |
							|                              |       LEDR[4]        |
							|                              |       LEDR[5]        |
							|                              |       LEDR[6]        |
							|                              |       LEDR[7]        |
							|                              |       LEDR[8]        |
							|                              |       LEDR[9]        |
							|                              |                      |
						  3|	  4 Pushbuttons             |       KEY[0]         |   Start/Restart the game
                     |	                            |       KEY[1]         |   Set 10 second timer
							|	                            |       KEY[2]         |   Set 20 second timer
							|	                            |       KEY[3]         |   Set 30 second timer
						   |                              |                      |
						  4|	  4 Seven segment displays  |       HEX0[0:6]      |   Display ones digit for score
						   |                              |       HEX1[0:6]      |   Display tens digit for score
                     |                              |       HEX4[0:6]      |   Display ones digit for timer
                     |                              |       HEX5[0:6]      |   Display tens digit for timer
	
*/

`timescale 1ns/1ps

module Whac_A_Mole( //top module
	input clk,
	input [9:0] sw,
	input reset,
	input [2:0] key,
	output [9:0] led,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3
	);

	wire timer_out;
	wire [1:0] counter_out;
	wire [3:0] timer_ones,timer_tens,score_ones,score_tens;
	wire [6:0] score_count;
	wire [4:0] timer_count;
	
	sub_bin2bcd bcd(timer_count, score_count, timer_ones, timer_tens, score_ones, score_tens);
		
	sub_7segDisplay ssd0(score_ones,HEX0[6:0]);
	sub_7segDisplay ssd1(score_tens,HEX1[6:0]);
	sub_7segDisplay ssd2(timer_ones,HEX2[6:0]);
	sub_7segDisplay ssd3(timer_tens,HEX3[6:0]);	
	
	sub_timerClock tclk(clk, timer_out);
	sub_timerCount tcnt(clk, reset, timer_count, key);
	
	sub_scoreCount scr(clk, sw, reset, key, led, score_count);
	
endmodule


module sub_bin2bcd(
	input [7:0] timerInput,
	input [7:0] scoreInput,
	output [3:0] timerOnes, 	
	output [3:0] timerTens,
	output [3:0] scoreOnes,
	output [3:0] scoreTens
	); 	
	
	assign timerOnes = timerInput % 10;
	assign timerTens = ((timerInput-timerOnes)/10) % 10;

	assign scoreOnes = scoreInput % 10;
	assign scoreTens = ((scoreInput-scoreOnes)/10) % 10;
	
endmodule


module sub_7segDisplay( 
	input[3:0] hex,
	output reg[6:0] ssd
	);
	always@(hex)
		begin
			case(hex)
				0: ssd=7'b1000000;
				1: ssd=7'b1111001;
				2: ssd=7'b0100100;
				3: ssd=7'b0110000;
				4: ssd=7'b0011001;
				5: ssd=7'b0010010;
				6: ssd=7'b0000010;
				7: ssd=7'b1111000;
				8: ssd=7'b0000000;
				9: ssd=7'b0010000;
				10: ssd=7'b0001000;
				11: ssd=7'b0000011;
				12: ssd=7'b1000110;
				13: ssd=7'b0100001;
				14: ssd=7'b0000110;
				15: ssd=7'b0001110;
			endcase
		end
endmodule


module sub_timerClock(
	input clk_in,
	output  reg clk_out
	);

	reg [27:0] period_count = 0;

	always @ (posedge clk_in)
		if (period_count != 50000000 - 1) //50 Mhz DE10 clock
			begin
				period_count<=  period_count + 1;
				clk_out <= 0; 
			end  
		else
			begin
				period_count <= 0;
				clk_out <= 1;
			end
 
endmodule


module sub_timerCount(
	input clk,
	input reset,
	output [4:0] count,
	input [2:0] key 
	);
	
	//note that the keys were assigned to key[3:1]
	//on the FPGA. key[0] was used for reset button
	
	wire clk_out;
	
	sub_timerClock c1(clk, clk_out);
	
	reg [4:0] timer = 0;
	
	always @(posedge clk_out) 
		begin
		
		if (key[2]==0) //press key[2] to set 30 second timer
					begin
						 if(reset)
							  timer <= 30;
						 else if(timer == 0)
							  timer <= timer; //stop timer at 0 seconds
						 else if(timer >= 1)
							  timer <= timer - 1; 
						 else
							  timer <= timer;
					end
		
		if (key[1]==0) //press key[1] to set 20 second timer
					begin
						 if(reset)
							  timer <= 20;
						 else if(timer == 0)
							  timer <= timer;
						 else if(timer >= 1)
							  timer <= timer - 1; 
						 else
							  timer <= timer;
					end		

		if (key[0]==0) //press key[0] to set 10 second timer
					begin
						 if(reset)
							  timer <= 10;
						 else if(timer == 0)
							  timer <= timer;
						 else if(timer >= 1)
							  timer <= timer - 1; 
						 else
							  timer <= timer;
					end		
		
		end
		
	assign count = timer; //provide output of the count
	
endmodule


module sub_debounce(
	input clk,
	input reset,
	output reg reset_db
	);
	
	reg key1,key2;
	reg [15:0] count;
	
	always @(posedge clk)
		begin
			key1 <= reset;
			key2 <= key1;
			if(reset_db==key2)
				count <=0;
			else
				begin
					count <= count + 1'b1;
					if(count==16'hffff)
						reset_db  <= ~reset_db;
				end
		end
endmodule


module sub_scoreCount(
	input clk,
	input [9:0] sw,
	input rst,
	input [2:0] key,
	output reg [9:0] led,
	output reg [5:0] score 
	);

	localparam //set the score count to 32
		S000000 = 0, 
		S000001 = 1, 
		S000010 = 2, 
		S000011 = 3, 
		S000100 = 4, 
		S000101 = 5, 
		S000110 = 6, 
		S000111 = 7, 
		S001000 = 8, 
		S001001 = 9, 
		S001010 = 10, 
		S001011 = 11, 
		S001100 = 12, 
		S001101 = 13, 
		S001110 = 14, 
		S001111 = 15, 
		S010000 = 16, 
		S010001 = 17, 
		S010010 = 18, 
		S010011 = 19, 
		S010100 = 20, 
		S010101 = 21, 
		S010110 = 22, 
		S010111 = 23, 
		S011000 = 24, 
		S011001 = 25, 
		S011010 = 26, 
		S011011 = 27, 
		S011100 = 28, 
		S011101 = 29, 
		S011110 = 30, 
		S011111 = 31, 
		S100000 = 32; 
		
	reg [5:0] current=0; //current score
	reg [5:0] next=0; //next score
	
	sub_debounce(clk,rst,reset);

	always @(posedge clk)
		begin
			if (reset)
				current <= S000000; //reset score
			else
				current <= next;
		end
		
	always @(current, sw[9:0])
	
		if (key[2]==0 | key[1]==0 | key[0]==0)

			begin
				case(current)
				
					S000000: begin //0          
									next <= S000000;
									led[9:0] <= 0;
									score <= 6'b000000;
									led[6] <= 1;
										if (sw[6]==1) 
											//if correct switch toggled
											next <= S000001; //increment score
										else
											next <= S000000; 
											//else remain same
								end
					
					S000001: begin //1
									score <= 6'b000001;
									led[9:0] <= 0;
									led[0] <= 1;
										if (sw[0]==1)
											next <= S000010;
										else
											next <= S000001;
								end					
				
					S000010: begin //2
									score <= 6'b000010;
									led[9:0] <= 0;
									led[8] <= 1;
										if (sw[8]==1)
											next <= S000011;
										else
											next <= S000010;
								end				
									
					S000011: begin //3
									score <= 6'b000011;
									led[9:0] <= 0;
									led[4] <= 1;
										if (sw[4]==1)
											next <= S000100;
										else
											next <= S000011;
								end			
					
					S000100: begin //4
									score <= 6'b000100;
									led[9:0] <= 0;
									led[9] <= 1;
										if (sw[9]==1)
											next <= S000101;
										else
											next <= S000100;
								end			
										
					S000101: begin //5
									score <= 6'b000101;
									led[9:0] <= 0;
									led[3] <= 1;
										if (sw[3]==1)
											next <= S000110;
										else
											next <= S000101;
								end	
						
					S000110: begin //6
									score <= 6'b000110;
									led[9:0] <= 0;
									led[2] <= 1;
										if (sw[2]==1)
											next <= S000111;
										else
											next <= S000110;
								end				
		
					S000111: begin //7
									score <= 6'b000111;
									led[9:0] <= 0;
									led[7] <= 1;
										if (sw[7]==1)
											next <= S001000;
										else
											next <= S000111;
								end
	
					S001000: begin //8
									score <= 6'b001000;
									led[9:0] <= 0;
									led[1] <= 1;
										if (sw[1]==1)
											next <= S001001;
										else
											next <= S001000;
								end
	
					S001001: begin //9
									score <= 6'b001001;
									led[9:0] <= 0;
									led[5] <= 1;
										if (sw[5]==1)
											next <= S001010;
										else
											next <= S001001;
								end
		
					S001010: begin //10
									score <= 6'b001010;
									led[9:0] <= 0;
									led[1] <= 1;
										if (sw[1]==0)
											next <= S001011;
										else
											next <= S001010;
								end
								
					S001011: begin //11
									score <= 6'b001011;
									led[9:0] <= 0;
									led[7] <= 1;
										if (sw[7]==0)
											next <= S001100;
										else
											next <= S001011;
								end
	
					S001100: begin //12
									score <= 6'b001100;
									led[9:0] <= 0;
									led[5] <= 1;
										if (sw[5]==0)
											next <= S001101;
										else
											next <= S001100;
								end							
	
					S001101: begin //13
									score <= 6'b001101;
									led[9:0] <= 0;
									led[9] <= 1;
										if (sw[9]==0)
											next <= S001110;
										else
											next <= S001101;
								end
								
					S001110: begin //14
									score <= 6'b001110;
									led[9:0] <= 0;
									led[6] <= 1;
										if (sw[6]==0)
											next <= S001111;
										else
											next <= S001110;
								end
	
					S001111: begin //15
									score <= 6'b001111;
									led[9:0] <= 0;
									led[0] <= 1;
										if (sw[0]==0)
											next <= S010000;
										else
											next <= S001111;
								end
	
					S010000: begin //16
									score <= 6'b010000;
									led[9:0] <= 0;
									led[4] <= 1;
										if (sw[4]==0)
											next <= S010001;
										else
											next <= S010000;
								end
	
					S010001: begin //17
									score <= 6'b010001;
									led[9:0] <= 0;
									led[3] <= 1;
										if (sw[3]==0)
											next <= S010010;
										else
											next <= S010001;
								end
	
					S010010: begin //18
									score <= 6'b010010;
									led[9:0] <= 0;
									led[8] <= 1;
										if (sw[8]==0)
											next <= S010011;
										else
											next <= S010010;
								end
	
					S010011: begin //19
									score <= 6'b010011;
									led[9:0] <= 0;
									led[2] <= 1;
										if (sw[2]==0)
											next <= S010100;
										else
											next <= S010011;
								end
					
					S010100: begin //20
									score <= 6'b010100;
									led[9:0] <= 0;
									led[8] <= 1;
										if (sw[8]==1)
											next <= S010101;
										else
											next <= S010100;
								end
					
	
					S010101: begin //21
									score <= 6'b010101;
									led[9:0] <= 0;
									led[7] <= 1;
										if (sw[7]==1)
											next <= S010110;
										else
											next <= S010101;
								end
	
					S010110: begin //22
									score <= 6'b010110;
									led[9:0] <= 0;
									led[2] <= 1;
										if (sw[2]==1)
											next <= S010111;
										else
											next <= S010110;
								end
	
					S010111: begin //23
									score <= 6'b010111;
									led[9:0] <= 0;
									led[4] <= 1;
										if (sw[4]==1)
											next <= S011000;
										else
											next <= S010111;
								end
	
					S011000: begin //24
									score <= 6'b011000;
									led[9:0] <= 0;
									led[4] <= 1;
										if (sw[4]==1)
											next <= S011001;
										else
											next <= S011000;
								end
	
					S011001: begin //25
									score <= 6'b011001;
									led[9:0] <= 0;
									led[0] <= 1;
										if (sw[0]==1)
											next <= S011010;
										else
											next <= S011001;
								end
	
					S011010: begin //26
									score <= 6'b011010;
									led[9:0] <= 0;
									led[6] <= 1;
										if (sw[6]==1)
											next <= S011011;
										else
											next <= S011010;
								end
	
					S011011: begin //27
									score <= 6'b011011;
									led[9:0] <= 0;
									led[9] <= 1;
										if (sw[9]==1)
											next <= S011100;
										else
											next <= S011011;
								end
	
					S011100: begin //28
									score <= 6'b011100;
									led[9:0] <= 0;
									led[3] <= 1;
										if (sw[3]==1)
											next <= S011101;
										else
											next <= S011100;
								end
	
					S011101: begin //29
									score <= 6'b011101;
									led[9:0] <= 0;
									led[5] <= 1;
										if (sw[5]==1)
											next <= S011110;
										else
											next <= S011101;
								end
	
					S011110: begin //30
									score <= 6'b011110;
									led[9:0] <= 0;
									led[0] <= 1;
										if (sw[0]==0)
											next <= S011111;
										else
											next <= S011110;
								end
		
					S011111: begin //31
									score <= 6'b011111;
									led[9:0] <= 0;
									led[1] <= 1;
										if (sw[1]==0)
											next <= S100000;
										else
											next <= S011111;
								end	
				
					S100000: begin //32
									next <= S100000;
									score <= 6'b100000;
									led[9:0] <= 0;
								end					
					
					default: begin
									next = S000000;
								end
				endcase
			end
endmodule

//End of program