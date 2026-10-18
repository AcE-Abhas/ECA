`timescale 1ps/1ps

// ALU (image: SrcA, SrcB, ALUControl, ALUResult, Zero) - purely combinational
//   ALUControl  000 = add     (add, addi, lw/sw address, branch/jalr target)
//               001 = sub     (beq/bne: Zero = (A - B) == 0)
//               010 = mul     (low 32 bits of the product)
//               011 = sll     (shift SrcA left by SrcB[4:0], for slli)
//               100 = blt/bge (signed comparison)
module alu#(
    parameter REGISTER_WIDTH = 32
) (
    input  wire [(REGISTER_WIDTH - 1):0] SrcA,
    input  wire [(REGISTER_WIDTH - 1):0] SrcB,
    input  wire [2:0]                    ALUControl,
    output reg  [(REGISTER_WIDTH - 1):0] ALUResult,
    output reg                          Zero
);

    always @* begin
        case (ALUControl)
            3'b000:  ALUResult = SrcA + SrcB;
            3'b001:  ALUResult = SrcA - SrcB;
            3'b010:  ALUResult = SrcA * SrcB;
            3'b011:  ALUResult = SrcA << SrcB[4:0];
            3'b100:  ALUResult = {{(REGISTER_WIDTH - 1){1'b0}}, ($signed(SrcA) < $signed(SrcB))};   // slt: 1 if SrcA < SrcB (signed), else 0
            default: ALUResult = {REGISTER_WIDTH{1'b0}};
        endcase

        if (ALUResult == {REGISTER_WIDTH{1'b0}}) begin
            Zero = 1;
        end else begin
            Zero = 0;
        end
    end

endmodule