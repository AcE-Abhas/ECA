`timescale 1ps/1ps

module Hazard_unit#(
    parameter REGISTER_WIDTH = 32
) (
    input wire [4:0]                    Rs1D,
    input wire [4:0]                    Rs2D,
    input wire [4:0]                    RdE,
    input wire [4:0]                    Rs2E,
    input wire [4:0]                    Rs1E,
    input wire                          PCSrcE,
    input wire                          ResultSrcE,
    input wire [4:0]                    RdM,
    input wire                          RegWriteM, 
    input wire [4:0]                    RdW,
    input wire                          RegWriteW,

    output reg                          StallF,
    output reg                          StallD, 
    output reg                          FlushD, 
    output reg                          FlushE,
    output reg [1:0]                    ForwardAE, 
    output reg [1:0]                    ForwardBE
);
    reg lwStall;

    always @* begin
        if ((Rs1E != 5'd0) && RegWriteM && (Rs1E == RdM))
            ForwardAE = 2'b10;
        else if ((Rs1E != 5'd0) && RegWriteW && (Rs1E == RdW))
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
 
        if ((Rs2E != 5'd0) && RegWriteM && (Rs2E == RdM))
            ForwardBE = 2'b10;
        else if ((Rs2E != 5'd0) && RegWriteW && (Rs2E == RdW))
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
 
        // Load-use: lw in E, its result needed by the instruction in D
        lwStall = ResultSrcE && (RdE != 5'd0) && ((RdE == Rs1D) || (RdE == Rs2D));
 
        StallF = lwStall;
        StallD = lwStall;
        FlushE = lwStall | PCSrcE;   // bubble into E (stall or taken branch/jump)
        FlushD = PCSrcE;             // drop the instruction fetched behind a taken branch/jump
    end
endmodule