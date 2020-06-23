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
//integer tic;
//integer toc;
wire done;
wire busy;

for_loop uut(clk,seed,n,done,busy);

    initial begin
//        #50;
        clk = 1;
        n = 100;
        seed = 32'b11001100011010001110011010011110;
        $display("kerman");
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