# ECE-2220-Term-Project
Implementing a Whac-A-Mole game onto the DE10 standard FPGA.
---

For our term project for ECE 2220, we decided to implement a Whac-A-Mole game using Verilog and a FPGA. The code for simulating the game was written using Verilog and demonstrated on the DE10-Standard FPGA-SoC. To provide a user friendly interface, the game utilized 4 push-buttons, 4 seven segment displays, 10 slide switches and 10 LEDs on the FPGA to perform all of the functions of the game.


The idea of mimicking a Whac-A-Mole game on the FPGA depends on the LEDs and slide switches. The board would randomly generate a mole on one of the 10 LEDs. This would be indicated by the LED lighting up. The user would have to toggle the corresponding slide switch to whack the mole. Upon a successful hit, the score would be increase by 1 point on the seven segment displays up to a maximum score of 32.


Additionally, the board would display a timer of 30, 20 or10 seconds selected by the player before the game is started. The objective is to hit as many moles as possible, to a maximum of 32, within the timer. Successfully hitting all 32 moles with the time would turn all LEDs off indicating that the game is over. A single push button is responsible for starting and resetting the game while the other three push buttons set the timer.


**Team Members:**

- Ohm Patel
- Manal Shahab
- Aida Mesgar Zadeh
- Hana Dunlop
