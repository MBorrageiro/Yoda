`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BitSkins
// Engineer: Mauro Borrageiro, Noel Loxton, Keenan Robinson
// 
// Create Date: 15.06.2020 15:44:51
// Design Name: LFSR Parallel Random Number Generator
// Module Name: for_loop
// Project Name: Parallel Rando-Lorian Number Generator PRNG04
// Target Devices: Nexus Artix 7
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
   input clk,               // 100MHz clock
   input [31:0]seed,        // start seed
   input [31:0] n,          // Number of random numbers to produce
   input [9:0] startAddr,   // Desired start address
   output prngDone,             // Done producing the random numbers
   output busy,             // Busy writing to memory
   output [31:0] checkA,    // See what values are written to Part A of BRAM 
   output [31:0] checkB     // See what values are written to Part B of BRAM 
  );
  
//___ Regs and Wire Deleclerations ___//

//LFSR regs
   reg lsb;                     //this stores the lsb for feedback to the msb
   reg [31:0]shiftVal = 32'b0;  //shifted Value
   reg [31:0] array [999:0];    //temp storage array
   reg [3:0] ii = 0 ;           //for loop iteration reg
   reg [31:0]checkN = 32'b0;    //ensure that only n random numbers are STORED.
   
//Handshacking regs
   reg r_prngDone = 0;
   reg r_busy = 0;
   
//BRAM Regs and Wires
   reg [15:0] countA = 15'b0;   //temp storage and BRAM indexing
   reg [15:0] countB = 15'b0;   //temp storage and BRAM indexing
   reg [31:0] dina = 32'b0;     //BRAM data in A port reg
   reg [31:0] dinb = 32'b0;     //BRAM data in B port reg
   reg [9:0] addra = 32'b0;     //BRAM A port address
   reg [9:0] addrb = 32'b0;     //BRAM B port address
   

//____ Module Instantiations ___//

   blk_mem_gen_0 BRAM(
      .clka(clk),     // input wire clka
      .ena(r_prngDone),   // input wire ena Device enable
      .wea(1'b1),     // input wire [0 : 0] write en A
      .addra(addra),  // input wire [9 : 0] addra
      .dina(dina),    // input wire [31 : 0] dina
      .douta(),       // output wire [31 : 0] douta
      .clkb(clk),     // input wire clkb
      .enb(r_prngDone),   // input wire enb Device enable
      .web(1'b1),     // input wire [0 : 0] write en B
      .addrb(addrb),  // input wire [9 : 0] addrb
      .dinb(dinb),    // input wire [31 : 0] dinb
      .doutb()        // output wire [31 : 0] doutb
    );
    
//___ Always Block Operations ___//    
 
     //LFSR PRNG always block
     always @(posedge clk)begin
        if(checkN >=n)
            r_prngDone = 1;     //Indicate to memory that PRNG generation is complete
        else begin
            for(ii = 0; ii<15; ii = ii + 1)begin
                shiftVal = seed + checkN*314159265;                         // Make each seed unique
                shiftVal = {shiftVal[0],shiftVal[31:1]};                    //concatenate lsb to msb - essentially an arithmetic shift right
                if (shiftVal[31])begin                                      //check value of lsb of seed
                shiftVal = shiftVal ^ 32'b00000000001000000000000000000011; //apply bitmask (based on optimal values to XOR of 32 bit number)
                                                                            //essentially XOR the values at bit-positions 1, 2 and 22
                end
                if(checkN<n)begin          //Check to only store n random numbers and no more.
                array[checkN] = shiftVal;  //Store the shifted value in the array
                checkN = checkN + 1;end
            end
        end
    end
   
   
   //Writing to BRAM always block
    always @(posedge clk)begin
        if(r_prngDone)begin
            if((countB == n))begin //When A and B address at their max, i.e Done
                r_busy <= 0;
                r_prngDone <=0;
            end
            else if(!r_busy && r_prngDone)begin
                countA <= 10'b0;  //Port A starts at the lowest address
                countB <= (n>>1); //Port B starts at half way from the maximum 
                r_busy <= 1;      //Busy sending data to memory.
            end
            else begin
                addra <= countA + startAddr;  //Move first half of array to BRAM and start at required address
                addrb <= countB + startAddr;  //Move second half of array to BRAM and start at required address
                dina <= array[countA];        //Add data at the current A address to dina
                dinb <= array[countB];        //Add data at the current B address to dinb
                countA <=countA +1;           //Increment A address
                countB <=countB +1;           //Increment B address
            end   
        end
    end

//___ Port Assignments ___//

    assign prngDone = r_prngDone; //Assign the state of prng to output done for viewing
    assign busy = r_busy;         //Assign the state of memory writing process to view
    assign checkA = dina;         //debugging vector to view values being assigned to BRAM data in lines
    assign checkB = dinb;         //debugging vector to view values being assigned to BRAM data in lines

endmodule