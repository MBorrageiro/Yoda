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
reg clk;
reg [31:0] n;
reg [31:0] seed;
reg [9:0] startAddr;
//integer tic;
//integer toc;
wire done;
wire busy;
wire [31:0] CheckA;
wire [31:0] CheckB;

for_loop uut(clk,seed,n,startAddr,done,busy,CheckA,CheckB);

    initial begin
//        #50;
        clk = 1;
        n = 4;
        seed = 32'b1;//11001100011010001110011010011110;
        startAddr = 10'b00001111;
//        $display("kerman");
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