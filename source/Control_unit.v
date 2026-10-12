`timescale 1ps/1ps

// Control unit (image: op, funct3, funct7, Zero -> PCSrc, ResultSrc, MemWrite, ALUControl, ALUSrc, ImmSrc, RegWrite)
// TODO: write this block. All outputs are 0 for now so the core builds.
//
// Encodings the datapath expects:
//   PCSrc       00 = PC + 4            01 = PCTarget (PC + ImmExt)      10 = ALUResult (jalr)
//   ResultSrc    0 = ALUResult          1 = ReadData (lw ONLY: the core stalls one cycle on it)
//   ALUSrc       0 = RD2                1 = ImmExt
//   ImmSrc      00 = I   01 = S   10 = B   11 = J
//   ALUControl  000 add  001 sub  010 mul  011 sll
//   MemWrite / RegWrite: 1 = write
//   Finish       1 for jalr (ret): tells the core the job is done
// Branches: the control unit decides PCSrc itself from Zero / LT (e.g. blt -> PCSrc = LT ? 01 : 00).
module control_unit(
    input  wire [6:0] op,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    input  wire       Zero,

    output wire       PCSrc,
    output wire       ResultSrc,
    output wire       MemWrite,
    output wire [2:0] ALUControl,
    output wire       ALUSrc,
    output wire [1:0] ImmSrc,
    output wire       RegWrite,
    output wire       Finish
);
    wire [1:0] ALUOp;

    always @* begin
        case (op)
            7'b0110011: begin //R-Type (add, mul)
                ALUOp = 2'b10;          // funct decides
            end
            7'b0010011: begin //I-Type (addi, slli)
                ALUOp = 2'b11;          // funct3 decides
            end
            7'b0000011: begin //I-Type (lw)
                ALUOp = 2'b00;
            end
            7'b0100011: begin //S-Type (sw)
                ALUOp = 2'b00;
            end
            7'b1100011: begin //B-Type (beq, bne, blt, bge)
                ALUOp = 2'b01;          // subtract
            end
            7'b1100111: begin //I-Type (jalr, used by ret)
                ALUOp = 2'b00;
            end
            7'b1101111: begin //J-Type (jal)
                ALUOp = 2'b00;
            end
            default: begin
                ALUOp = 2'b00;
            end
        endcase

        case (ALUOp)
            2'b00: begin //R-Type (add, mul)
            end
            2'b01: begin //I-Type (addi, slli)
            end
            2'b10: begin //I-Type (lw)
            end
            2'b11: begin //S-Type (sw)
            end
            default: begin
            end
        endcase
    end

endmodule