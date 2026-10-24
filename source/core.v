`timescale 1ps/1ps
module CustomCore#(
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDRESS_WIDTH = 5,
    parameter INSTRUCTION_MEMORY_ADDRESS_WIDTH = 5,
    parameter DATA_MEMORY_ADDRESS_WIDTH = 5
) (
    input wire                                            clock,
    input wire                                            reset,

    input wire[(REGISTER_WIDTH - 1): 0]                   instruction_memory_read,  // Read data from memory location indicated by instruction_memory_address
    input wire[(REGISTER_WIDTH - 1): 0]                   data_memory_read,         // Read back data from RAM

    output wire[(INSTRUCTION_MEMORY_ADDRESS_WIDTH - 1):0] instruction_memory_address, // ROM word to read
    output wire[(DATA_MEMORY_ADDRESS_WIDTH - 1):0]        data_memory_address,        // Address of the RAM location to read from or write to
    output wire[(REGISTER_WIDTH - 1):0]                   data_write_value,           // Write data to memory register
    output wire                                           data_write_enable,          // 1 = write value to RAM, 0 = read
    output wire                                           core_finish_signal          // 1 = job is done
);

    wire clk;
    assign clk = clock;

    // ---------------------------------------------------------------
    // Hazard unit outputs
    // ---------------------------------------------------------------
    wire       StallF, StallD, FlushD, FlushE;
    wire [1:0] ForwardAE, ForwardBE;

    // ---------------------------------------------------------------
    // Fetch stage
    // ---------------------------------------------------------------
    reg  [(REGISTER_WIDTH - 1):0] PC;
    wire [(REGISTER_WIDTH - 1):0] PCPlus4F, PCNextF;

    // ---------------------------------------------------------------
    // Decode stage
    // ---------------------------------------------------------------
    wire [(REGISTER_WIDTH - 1):0] InstrD, PCD, PCPlus4D;
    wire [(REGISTER_WIDTH - 1):0] RD1D, RD2D;
    wire [31:0]                   ExtImmD;
    wire       RegWriteD, MemWriteD, JumpD, BranchD, BranchInvD, ALUSrcD, FinishD;
    wire [1:0] ResultSrcD, ImmSrcD;
    wire [2:0] ALUControlD;

    // ---------------------------------------------------------------
    // Execute stage
    // ---------------------------------------------------------------
    wire [(REGISTER_WIDTH - 1):0] PCE, PCPlus4E, RD1E, RD2E;
    wire [31:0]                   ExtImmE;
    wire [4:0]                    Rs1E, Rs2E, RdE;
    wire       RegWriteE, MemWriteE, JumpE, BranchE, BranchInvE, ALUSrcE, FinishE;
    wire [1:0] ResultSrcE;
    wire [2:0] ALUControlE;
    reg  [(REGISTER_WIDTH - 1):0] SrcAE, WriteDataE;
    wire [(REGISTER_WIDTH - 1):0] SrcBE, AluResultE, PCTargetE;
    wire       ZeroE, PCSrcE;

    // ---------------------------------------------------------------
    // Memory stage
    // ---------------------------------------------------------------
    wire [(REGISTER_WIDTH - 1):0] PCPlus4M, AluResultM, WriteDataM, ReadDataM;
    wire [4:0] RdM;
    wire       RegWriteM, MemWriteM, FinishM;
    wire [1:0] ResultSrcM;

    // ---------------------------------------------------------------
    // Write stage
    // ---------------------------------------------------------------
    wire [(REGISTER_WIDTH - 1):0] PCPlus4W, AluResultW, ReadDataW;
    reg  [(REGISTER_WIDTH - 1):0] ResultW;
    wire [4:0] RdW;
    wire       RegWriteW, FinishW;
    wire [1:0] ResultSrcW;

    // ---------------------------------------------------------------
    // Program counter
    // ---------------------------------------------------------------
    assign PCPlus4F = PC + 4;
    assign PCNextF  = PCSrcE ? PCTargetE : PCPlus4F;

    always @(posedge clk) begin
        if (reset)
            PC <= {REGISTER_WIDTH{1'b0}};
        else if (!StallF)
            PC <= PCNextF;
    end

    // Instruction memory (the ROM in the test bench is addressed per word)
    assign instruction_memory_address = PC[(INSTRUCTION_MEMORY_ADDRESS_WIDTH + 1):2];

    // ---------------------------------------------------------------
    // Fetch unit
    // ---------------------------------------------------------------
    Fetch_unit#(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) Fetch_unit (
        .InstrF(instruction_memory_read),
        .PCPlus4F(PCPlus4F),
        .PCF(PC),
        .clk(clk),
        .EN(~StallD),
        .CLR(FlushD | reset),
        .InstrD(InstrD),
        .PCPlus4D(PCPlus4D),
        .PCD(PCD)
    );

    // ---------------------------------------------------------------
    // Decode unit
    // ---------------------------------------------------------------

    Decode_unit#(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) Decode_unit (
        .ExtImmD(ExtImmD),
        .PCPlus4D(PCPlus4D),
        .PCD(PCD),
        .RdD(InstrD[11:7]),
        .Rs2D(InstrD[24:20]),
        .Rs1D(InstrD[19:15]),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .BranchInvD(BranchInvD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .FinishD(FinishD),
        .clk(clk),
        .CLR(FlushE | reset),
        .ExtImmE(ExtImmE),
        .PCPlus4E(PCPlus4E),
        .PCE(PCE),
        .RdE(RdE),
        .Rs2E(Rs2E),
        .Rs1E(Rs1E),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .BranchInvE(BranchInvE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .FinishE(FinishE)
    );

     // ---------------------------------------------------------------
    // Register file and extend
    // ---------------------------------------------------------------
    register_file #(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) RegFile (
        .clk(clk),
        .reset(reset),
        .A1(InstrD[19:15]),
        .A2(InstrD[24:20]),
        .A3(RdW),
        .WD3(ResultW),
        .WE3(RegWriteW),
        .RD1(RD1D),
        .RD2(RD2D)
    );

    extend Extend (
        .Instr(InstrD[31:7]),
        .ImmSrc(ImmSrcD),
        .ImmExt(ExtImmD)
    );

    // ---------------------------------------------------------------
    // Control unit
    // ---------------------------------------------------------------
    control_unit ControlUnit (
        .op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[31:25]),
        .RegWrite(RegWriteD),
        .ResultSrc(ResultSrcD),
        .MemWrite(MemWriteD),
        .Jump(JumpD),
        .Branch(BranchD),
        .BranchInv(BranchInvD),
        .ALUControl(ALUControlD),
        .ALUSrc(ALUSrcD),
        .ImmSrc(ImmSrcD),
        .Finish(FinishD)
    );
    
    // ---------------------------------------------------------------
    // Execute unit
    // ---------------------------------------------------------------

    Execute_unit#(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) Execute_unit (
        .PCPlus4E(PCPlus4E),
        .AluResultE(AluResultE),
        .RdE(RdE),
        .WriteDataE(WriteDataE),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .FinishE(FinishE),
        .clk(clk),
        .reset(reset),
        .PCPlus4M(PCPlus4M),
        .AluResultM(AluResultM),
        .RdM(RdM),
        .WriteDataM(WriteDataM),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .FinishM(FinishM)
    );

    always @* begin
        case (ForwardAE)
            2'b01:   SrcAE = ResultW;
            2'b10:   SrcAE = AluResultM;
            default: SrcAE = RD1E;
        endcase
        case (ForwardBE)
            2'b01:   WriteDataE = ResultW;
            2'b10:   WriteDataE = AluResultM;
            default: WriteDataE = RD2E;
        endcase
    end

    assign PCTargetE = PCE + ExtImmE;
    // ---------------------------------------------------------------
    // ALU
    // ---------------------------------------------------------------
    assign SrcBE = ALUSrcE ? ExtImmE : WriteDataE;

    alu #(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) aluBlock (
        .SrcA(SrcAE),
        .SrcB(SrcBE),
        .ALUControl(ALUControlE),
        .ALUResult(AluResultE),
        .Zero(ZeroE)
    );

    assign PCSrcE    = JumpE | (BranchE & (ZeroE ^ BranchInvE));
    // ---------------------------------------------------------------
    // Memory unit
    // ---------------------------------------------------------------
    assign data_memory_address = AluResultM[(DATA_MEMORY_ADDRESS_WIDTH + 1):2];
    assign data_write_value    = WriteDataM;
    assign data_write_enable   = MemWriteM;
    assign ReadDataM           = data_memory_read; 

    Memory_unit#(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) Memory_unit (
        .PCPlus4M(PCPlus4M),
        .AluResultM(AluResultM),
        .ReadDataM(ReadDataM),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .FinishM(FinishM),
        .clk(clk),
        .reset(reset),
        .PCPlus4W(PCPlus4W),
        .AluResultW(AluResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .FinishW(FinishW)
    );

    // ---------------------------------------------------------------
    // Write back
    // ---------------------------------------------------------------
    always @* begin
        case (ResultSrcW)
            2'b01:   ResultW = ReadDataW;
            2'b10:   ResultW = PCPlus4W;
            default: ResultW = AluResultW;
        endcase
    end

    // ---------------------------------------------------------------
    // Finish: sticky flag once ret reaches write back
    // ---------------------------------------------------------------
    reg finish_r;
    always @(posedge clk) begin
        if (reset)        finish_r <= 1'b0;
        else if (FinishW) finish_r <= 1'b1;
    end
    assign core_finish_signal = finish_r;

    // ---------------------------------------------------------------
    // Hazard unit
    // ---------------------------------------------------------------
    Hazard_unit#(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) Hazard_unit (
        .Rs1D(InstrD[19:15]),
        .Rs2D(InstrD[24:20]),
        .RdE(RdE),
        .Rs2E(Rs2E),
        .Rs1E(Rs1E),
        .PCSrcE(PCSrcE),
        .ResultSrcE(ResultSrcE[0]),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

endmodule