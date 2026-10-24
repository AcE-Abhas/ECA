`timescale 1ps/1ps

module Fetch_unit#(
    parameter REGISTER_WIDTH = 32
) (
    input  wire [(REGISTER_WIDTH - 1):0] InstrF,
    input  wire [(REGISTER_WIDTH - 1):0] PCPlus4F,
    input  wire [(REGISTER_WIDTH - 1):0] PCF,
    input  wire       clk,
    input  wire       EN,
    input  wire       CLR,

    output reg [(REGISTER_WIDTH - 1):0] InstrD, //done
    output reg [(REGISTER_WIDTH - 1):0] PCPlus4D, //done
    output reg [(REGISTER_WIDTH - 1):0] PCD
);

    always @(posedge clk) begin
        if (EN) begin
            InstrD   <= InstrF;
            PCPlus4D <= PCPlus4F;
            PCD      <= PCF;
        end

        if (CLR) begin
            InstrD   <=  {REGISTER_WIDTH{1'b0}};
            PCPlus4D <=  {REGISTER_WIDTH{1'b0}};
            PCD      <=  {REGISTER_WIDTH{1'b0}};
        end
    end
endmodule