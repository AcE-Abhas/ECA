`timescale 1ps/1ps

module control_unit(
    input  wire [6:0] op,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    input  wire       Zero,

    output wire       PCSrc, //done
    output reg       ResultSrc, //done
    output reg       MemWrite, //done
    output reg [2:0] ALUControl, //done
    output reg       ALUSrc, //done
    output reg [1:0] ImmSrc, //done
    output reg       RegWrite,
    output wire       Finish
);
    reg [1:0] ALUOp; //done
    reg Branch;

    assign PCSrc = Branch && Zero;

    always @* begin
        case (op)
            7'b0110011: begin //R-Type (add, mul)
                ALUOp = 2'b10;          // funct decides
                ImmSrc = 2'b00;
                ALUSrc = 1'b0;
                RegWrite = 1'b1;
                ResultSrc = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
            end
            7'b0010011: begin //I-Type (addi, slli)
                ALUOp = 2'b11;          // funct3 decides
                ImmSrc = 2'b00;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
                ResultSrc = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
            end
            7'b0000011: begin //I-Type (lw)
                ALUOp = 2'b00;
                ImmSrc = 2'b00;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
                ResultSrc = 1'b1;
                MemWrite = 1'b0;
                Branch = 1'b0;
            end
            7'b1100111: begin //I-Type (jalr, used by ret)
                ALUOp = 2'b00;
                ImmSrc = 2'b00;
                ALUSrc = 1'b1;
                RegWrite = 1'b0;
                ResultSrc = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
            end
            7'b0100011: begin //S-Type (sw)
                ALUOp = 2'b00;
                ImmSrc = 2'b01;
                ALUSrc = 1'b1;
                RegWrite = 1'b0;
                ResultSrc = 1'b0;
                MemWrite = 1'b1;
                Branch = 1'b0;
            end
            7'b1100011: begin //B-Type (beq, bne, blt, bge)
                ALUOp = 2'b01;          // subtract
                ImmSrc = 2'b10;
                ALUSrc = 1'b0;
                RegWrite = 1'b0;
                ResultSrc = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b1;
            end
            7'b1101111: begin //J-Type (jal)
                ALUOp = 2'b00;
                ImmSrc = 2'b11;
                ALUSrc = 1'b1;
                RegWrite = 1'b0;
                ResultSrc = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
            end
            default: begin
                ALUOp = 2'b00;
                ImmSrc = 2'b00;
                ALUSrc = 1'b0;
                RegWrite = 1'b0;
                ResultSrc = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
            end
        endcase

        

        case (ALUOp)
            2'b10: begin //R-Type (add, mul)
                case (funct7)
                    7'b0000000: begin // ADD
                        ALUControl = 3'b000;
                    end
                    7'b0000001: begin // MUL
                        ALUControl = 3'b010;
                    end
                    default: begin
                        ALUControl = 3'b000;
                    end
                endcase
            end
            2'b11: begin //I-Type (addi, slli)
                case (funct3)
                    3'b000: begin // ADDI
                        ALUControl = 3'b000;
                    end
                    3'b001: begin // SLLI
                        ALUControl = 3'b011;
                    end
                    default: begin
                        ALUControl = 3'b000;
                    end
                endcase
            end
            2'b00: begin //I-Type (lw) and S-Type (sw)
                ALUControl = 3'b000;
            end
            2'b01: begin //B-Type (beq, bne, blt, bge)
                case (funct3)
                    3'b000: begin //BEQ
                        ALUControl = 3'b001;
                    end
                    3'b001: begin //BNE
                        ALUControl = 3'b001;
                    end
                    3'b100: begin //BLT
                        ALUControl = 3'b100;
                    end 
                    3'b101: begin //BGE
                        ALUControl = 3'b100;
                    end 
                    default: begin 
                        ALUControl = 3'b000;
                    end
                endcase
            end
            default: begin
                ALUControl = 3'b000;
            end
        endcase
    end

endmodule