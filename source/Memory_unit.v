`timescale 1ps/1ps

module Memory_unit#(
    parameter REGISTER_WIDTH = 32
) (
    input wire [(REGISTER_WIDTH - 1):0] PCPlus4M,
    input wire [(REGISTER_WIDTH - 1):0] AluResultM, 
    input wire [(REGISTER_WIDTH - 1):0] ReadDataM, 
    input wire [4:0]                    RdM,
    input wire                          RegWriteM, 
    input wire [1:0]                    ResultSrcM, 
    input wire                          FinishM, 
    
    //Special inputs IE pipeline
    input  wire                         clk,
    input wire                          reset,

    output reg [(REGISTER_WIDTH - 1):0]  PCPlus4W,
    output reg [(REGISTER_WIDTH - 1):0]  AluResultW, 
    output wire [(REGISTER_WIDTH - 1):0] ReadDataW, 
    output reg [4:0]                     RdW,
    output reg                           RegWriteW, 
    output reg [1:0]                     ResultSrcW, 
    output reg                           FinishW
);
    assign ReadDataW = ReadDataM;
    always @(posedge clk) begin
        if (reset) begin
            PCPlus4W   <= {REGISTER_WIDTH{1'b0}};
            AluResultW <= {REGISTER_WIDTH{1'b0}};
            RdW        <= 5'b0;
            RegWriteW  <= 1'b0;
            ResultSrcW <= 2'b0;
            FinishW    <= 1'b0;
        end else begin
            PCPlus4W   <= PCPlus4M;
            AluResultW <= AluResultM;
            RdW        <= RdM;
            RegWriteW  <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            FinishW    <= FinishM;
        end               
    end
endmodule