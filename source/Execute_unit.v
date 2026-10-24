`timescale 1ps/1ps

module Execute_unit#(
    parameter REGISTER_WIDTH = 32
) (
    input wire [(REGISTER_WIDTH - 1):0] PCPlus4E,
    input wire [(REGISTER_WIDTH - 1):0] AluResultE,
    input wire [4:0]                    RdE,
    input wire [(REGISTER_WIDTH - 1):0] WriteDataE, 
    input wire                          RegWriteE,
    input wire [1:0]                    ResultSrcE,
    input wire                          MemWriteE,
    input wire                          FinishE,
    
    //Special inputs IE pipeline
    input  wire                         clk,
    input wire                          reset,

    output reg [(REGISTER_WIDTH - 1):0] PCPlus4M,
    output reg [(REGISTER_WIDTH - 1):0] AluResultM,
    output reg [4:0]                    RdM,
    output reg [(REGISTER_WIDTH - 1):0] WriteDataM, 
    output reg                          RegWriteM,
    output reg [1:0]                    ResultSrcM,
    output reg                          MemWriteM,
    output reg                          FinishM
);
    always @(posedge clk) begin
        if (reset) begin
            PCPlus4M   <= {REGISTER_WIDTH{1'b0}};
            AluResultM <= {REGISTER_WIDTH{1'b0}};
            RdM        <= 5'b0;
            WriteDataM <= {REGISTER_WIDTH{1'b0}};
            RegWriteM  <= 1'b0;
            ResultSrcM <= 2'b0;
            MemWriteM  <= 1'b0;
            FinishM    <= 1'b0;
        end else begin
            PCPlus4M   <= PCPlus4E;
            AluResultM <= AluResultE;
            RdM        <= RdE;
            WriteDataM <= WriteDataE;
            RegWriteM  <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM  <= MemWriteE;
            FinishM    <= FinishE;
        end       
    end
endmodule