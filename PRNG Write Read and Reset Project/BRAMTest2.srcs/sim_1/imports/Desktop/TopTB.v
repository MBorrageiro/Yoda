`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2020 16:07:09
// Design Name: 
// Module Name: test_new
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


module test_new();
//Inputs Regs
reg clk;
reg Reset;
reg [31:0] seed;
reg [31:0] n;
reg [9:0] startAddr;
reg readRqst;
//Output Wires
wire done;
wire busy;
wire [31:0] CheckA;
wire [31:0] CheckB;
wire [31:0] readA;
wire [31:0] readB;


top uut(clk,Reset,seed,n,startAddr,readRqst,done,busy,CheckA,CheckB,readA,readB);

    initial begin
        clk = 1;
        n = 50;
        seed = 32'b1;//11001100011010001110011010011110;
        startAddr = 10'b00001111;
        readRqst = 1'b0;
        Reset = 1'b0;
        # 500 
        readRqst = 1'b1;
        #50
        Reset = 1'b1;
        #10
        Reset = 1'b0; 
    end

    always begin
      #5  clk = ~ clk;
    end

//    always @(posedge done)begin
//    $display($realtime,"tic");
//    end

//    always @(posedge doon)begin
//    $display($realtime,"toc");
//    end

endmodule