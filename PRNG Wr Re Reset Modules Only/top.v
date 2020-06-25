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
//  Firstly it was realised too late that the follwoing code is slightly over complicated and convoluted.
//  It was realised too late that the code can be significantly simplifed with a state machine and is left
//  as an improvement for simplification for a later iteration of the code.
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
//Inputs
   input clk,               // 100MHz clock
   input Reset,             // reset to clear logic and begin again
   input [31:0]seed,        // start seed
   input [31:0] n,          // Number of random numbers to produce
   input [9:0] startAddr,   // Desired start address
   input readRqst,          // Read request for BRAM
//Outputs
   output prngDone,         // Done producing the random numbers
   output busy,             // Busy writing to memory
   output [31:0] checkA,    // DEBUG See what values are written to Part A of BRAM 
   output [31:0] checkB,    // DEBUG See what values are written to Part B of BRAM
   output [31:0] readA,     // BRAM port A read output
   output [31:0] readB      // BRAM port B read output
  );
  
//___ Regs and Wire Deleclerations ___//

//LFSR regs
   reg lsb;                     //this stores the lsb for feedback to the msb
   reg [31:0]shiftVal = 32'b0;  //shifted Value
   reg [31:0] array [999:0];    //temp storage array
   reg [3:0] ii = 0 ;           //for loop iteration reg
   reg [31:0]checkN = 32'b0;    //ensure that only n random numbers are STORED.
   
//Handshacking regs
   reg r_prngDone = 0;          //Random numbers complete generating
   reg r_busy = 0;              //Busy writing to BRAM
   reg r_readReady = 0;         //ready to read from BRAM
   reg END = 0;                 //Entire process complete
   
//BRAM Regs and Wires
   reg [15:0] countA = 15'b0;   //temp storage and BRAM indexing
   reg [15:0] countB = 15'b0;   //temp storage and BRAM indexing
   reg [31:0] dina = 32'b0;     //BRAM data in A port reg
   reg [31:0] dinb = 32'b0;     //BRAM data in B port reg
   reg [9:0] addra = 32'b0;     //BRAM A port address
   reg [9:0] addrb = 32'b0;     //BRAM B port address
   wire [31:0] douta;           //BRAM data out port A
   wire [31:0] doutb;           //BRAM data out port B
   

//____ Module Instantiations ___//

   blk_mem_gen_0 BRAM(
      .clka(clk),       // input wire clka
      .ena(r_prngDone), // input wire ena Device enable
      .wea(r_busy),     // input wire 1-bit write en A
      .addra(addra),    // input wire [9 : 0] addra
      .dina(dina),      // input wire [31 : 0] dina
      .douta(douta),       // output wire [31 : 0] douta
      .clkb(clk),       // input wire clkb
      .enb(r_prngDone), // input wire enb Device enable
      .web(r_busy),     // input wire 1-bit write en B
      .addrb(addrb),    // input wire [9 : 0] addrb
      .dinb(dinb),      // input wire [31 : 0] dinb
      .doutb(doutb)        // output wire [31 : 0] doutb
    );
    
//___ Always Block Operations ___//    
 
     //LFSR PRNG always block
     always @(posedge clk)begin
        if(!END)begin
            if(checkN >=n)
                r_prngDone = 1;     //Indicate to memory that PRNG generation is complete
            else if(!r_prngDone)begin
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
    end
   
   
   //BRAM interaction always block
    always @(posedge clk)begin
        if(Reset)begin
            checkN <= 32'b0;
            r_prngDone <= 0; 
            r_busy <= 0;     
            r_readReady <= 0;
            countA <= 10'b0;   //reset counts for read operation
            countB <= (n>>1); 
            END <= 0;        
        end
        else if(!END)begin
        //Write Operation of BRAM
            if(r_prngDone && !r_readReady)begin
                if((countB == n))begin //When A and B address at their max, i.e Done
                    r_busy <= 0;
                    r_readReady <=1;   //ready to ready
                    countA <= 10'b0;   //reset counts for read operation
                    countB <= (n>>1); 
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
            //Read Operation of BRAM
            else if(r_readReady && readRqst)begin
                if(countB == n)begin                   //Stop reading when all RNs are output
                    r_readReady <=0;
                    r_prngDone <= 0;
                    END <=1;
                end
                else begin
                    addra <= countA + startAddr;  //Move first half of array to BRAM and start at required address
                    addrb <= countB + startAddr;
                    countA <=countA +1;           //Increment A address
                    countB <=countB +1;           //Increment B address
                end
            end
         end
    end
    

//___ Port Assignments ___//

    assign prngDone = r_prngDone; //Assign the state of prng to output done for viewing
    assign busy = r_busy;         //Assign the state of memory writing process to view
    assign readA = douta;         //Assign BRAM data out port A to read A
    assign readB = doutb;         //Assign BRAM data out port A to read A
    //debug vectors   
    assign checkA = dina;         //debugging vector to view values being assigned to BRAM data in lines
    assign checkB = dinb;         //debugging vector to view values being assigned to BRAM data in lines

endmodule