`timescale 1ps/1ps

module Decode_unit#(
    parameter REGISTER_WIDTH = 32
) (
    input wire [31:0]                   ExtImmD,
    input wire [(REGISTER_WIDTH - 1):0] PCPlus4D,
    input wire [(REGISTER_WIDTH - 1):0] PCD,
    input wire [4:0]                    RdD,
    input wire [4:0]                    Rs2D,
    input wire [4:0]                    Rs1D,
    input wire [(REGISTER_WIDTH - 1):0] RD1D,
    input wire [(REGISTER_WIDTH - 1):0] RD2D, 
    input wire                          RegWriteD,
    input wire [1:0]                    ResultSrcD,
    input wire                          MemWriteD,
    input wire                          JumpD,
    input wire                          BranchD,
    input wire [2:0]                    ALUControlD,
    input wire                          ALUSrcD,
    input wire                          BranchInvD,
    input wire                          FinishD,
    
    //Special inputs IE pipeline
    input  wire                         clk,
    input  wire                         CLR,

    output reg [31:0]                   ExtImmE,
    output reg [(REGISTER_WIDTH - 1):0] PCPlus4E,
    output reg [(REGISTER_WIDTH - 1):0] PCE,
    output reg [4:0]                    RdE,
    output reg [4:0]                    Rs2E,
    output reg [4:0]                    Rs1E,
    output reg [(REGISTER_WIDTH - 1):0] RD1E,
    output reg [(REGISTER_WIDTH - 1):0] RD2E,
    output reg                          RegWriteE,
    output reg [1:0]                    ResultSrcE,
    output reg                          MemWriteE,
    output reg                          JumpE,
    output reg                          BranchE,
    output reg [2:0]                    ALUControlE,
    output reg                          ALUSrcE,
    output reg                          BranchInvE,
    output reg                          FinishE
);

    always @(posedge clk) begin
        ExtImmE         <= ExtImmD;     
        PCPlus4E        <= PCPlus4D;   
        PCE             <= PCD;           
        RdE             <= RdD;              
        Rs2E            <= Rs2D;             
        Rs1E            <= Rs1D;            
        RD1E            <= RD1D;            
        RD2E            <= RD2D;          
        RegWriteE       <= RegWriteD;  
        ResultSrcE      <= ResultSrcD; 
        MemWriteE       <= MemWriteD;  
        JumpE           <= JumpD;          
        BranchE         <= BranchD;      
        ALUControlE     <= ALUControlD;
        ALUSrcE         <= ALUSrcD;  
        BranchInvE      <= BranchInvD;    
        FinishE         <= FinishD;      

        if (CLR) begin
            ExtImmE         <= 32'b0;
            PCPlus4E        <= {REGISTER_WIDTH{1'b0}};
            PCE             <= {REGISTER_WIDTH{1'b0}};
            RdE             <= 5'b0;
            Rs2E            <= 5'b0;
            Rs1E            <= 5'b0;
            RD1E            <= {REGISTER_WIDTH{1'b0}};
            RD2E            <= {REGISTER_WIDTH{1'b0}};
            RegWriteE       <= 1'b0;
            ResultSrcE      <= 2'b0;
            MemWriteE       <= 1'b0;
            JumpE           <= 1'b0;
            BranchE         <= 1'b0;
            ALUControlE     <= 3'b0;
            ALUSrcE         <= 1'b0;
            BranchInvE      <= 1'b0;
            FinishE         <= 1'b0;
        end
    end
endmodule