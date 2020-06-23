`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BitSkins
// Engineer: Noel Loxton
// 
// Create Date: 15.06.2020 15:44:51
// Design Name: 
// Module Name: for_loop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module for_loop(
   input clk,
   input [31:0]seed,  // start seed
   input [31:0] n,    // Number of random numbers to produce
   output done , // timing
   output busy,
   output [31:0] checkA,
   output [31:0] checkB
  );
   //for loop variables
   reg [3:0] i = 0; 
   reg [3:0] ii = 0 ;

   //regs
   reg [31:0]shiftVal = 32'b0;     //shifted Value
   reg [31:0] array [99:0];           //Storage array
 
   reg lsb; //this stores the lsb for feedback to the msb
//   reg [3:0] count = 4'b0000; //to produce multiple random numbers
//   reg [31:0] lfsr = 32'b11001100011010001110011010011110; //input seed (will not be necessary when start_state initialsed in full program)

//Handshacking vars
   reg r_done = 0;
   reg r_busy = 0;
// BRAM Regs and Wires
   reg [15:0] countA = 15'b0;
   reg [15:0] countB = 15'b0;
   reg [31:0] dina = 32'b0;
   reg [31:0] dinb = 32'b0;
   reg [9:0] addra = 32'b0;
   reg [9:0] addrb = 32'b0;

    //reg r_doon = 0;

   blk_mem_gen_0 BRAM(
      .clka(clk),    // input wire clka
      .ena(r_done),      // input wire ena Device enable
      .wea(1'b1),      // input wire [0 : 0] write en A
      .addra(addra),  // input wire [9 : 0] addra
      .dina(dina),    // input wire [31 : 0] dina
      .douta(),  // output wire [31 : 0] douta
      .clkb(clk),    // input wire clkb
      .enb(r_done),      // input wire enb Device enable
      .web(1'b1),      // input wire [0 : 0] write en B
      .addrb(addrb),  // input wire [9 : 0] addrb
      .dinb(dinb),    // input wire [31 : 0] dinb
      .doutb()  // output wire [31 : 0] doutb
    );
    
    reg [31:0]checkN = 32'b0;
 
     always @(posedge clk)begin
        if(checkN >=n)
            r_done = 1;
        else begin
            for(ii = 0; ii<15; ii = ii + 1)begin
                shiftVal = seed + checkN*314159265;//ii*314159265;        // Make each seed unique
                shiftVal = {shiftVal[0],shiftVal[31:1]}; //concatenate lsb to msb - essentially an arithmetic shift right
                if (shiftVal[31])begin //check value of lsb of seed
                shiftVal = shiftVal ^ 32'b00000000001000000000000000000011; //apply bitmask (based on optimal values to XOR of 32 bit number)
                                                                    //essentially XOR the values at bit-positions 1, 2 and 22
                end
                if(checkN<n)begin
                array[checkN] = shiftVal;            //Store the shifted value in the array
                checkN = checkN + 1;end
            end
        end
    end
    
    always @(posedge clk)begin
        if(r_done)begin
            if((countB == n))begin //When A and B address at their max Done
                r_busy <= 0;
                r_done <=0;
            end
            else if(!r_busy && r_done)begin
                countA <= 10'b0;
                countB <= (n>>1);
                r_busy <= 1;
            end
            else begin
                addra <= countA; //Move first half of array to BRAM
                addrb <= countB; //Move second half of array to BRAM
                dina <= array[countA];
                dinb <= array[countB];
                countA <=countA +1; //Increment A address
                countB <=countB +1; //Increment B address
            end   
        end
    end
    
    assign done = r_done;
    assign busy = r_busy;
//    assign checkA = dina;
//    assign checkB = dinb;

endmodule