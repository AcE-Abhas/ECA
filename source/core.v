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
    // Control signals (from the control unit)
    // ---------------------------------------------------------------
    wire       PCSrc;
    wire       ResultSrc;
    wire       MemWrite;
    wire [2:0] ALUControl;
    wire       ALUSrc;
    wire [1:0] ImmSrc;
    wire       RegWrite;
    wire       Finish;// Not specified

    // ---------------------------------------------------------------
    // Datapath signals
    // ---------------------------------------------------------------
    reg  [(REGISTER_WIDTH - 1):0] PC;                 // byte address
    wire [(REGISTER_WIDTH - 1):0] PCPlus4, PCTarget, PCNext;
    wire [(REGISTER_WIDTH - 1):0] RD2;
    wire [31:0]                   ImmExt;
    wire [(REGISTER_WIDTH - 1):0] SrcA, SrcB;
    wire [(REGISTER_WIDTH - 1):0] ALUResult;
    wire                          Zero;
    wire [(REGISTER_WIDTH - 1):0] ReadData;
    wire [(REGISTER_WIDTH - 1):0] Result;

    // ---------------------------------------------------------------
    // lw takes two cycles: the RAM answers one clk after the address.
    //   address phase (lw_wait = 0): PC held, no register write
    //   data phase    (lw_wait = 1): ReadData valid, register written, PC advances
    // ---------------------------------------------------------------
    reg  lw_wait;
    reg  finish_r;
    wire stall = ResultSrc & ~lw_wait;
    wire RegWrite_eff = RegWrite & ~stall;

    // ---------------------------------------------------------------
    // Program counter
    // ---------------------------------------------------------------
    assign PCPlus4  = PC + 4;
    assign PCTarget = PC + ImmExt;
    assign PCNext = PCSrc ? PCTarget : PCPlus4;

    always @(posedge clk) begin
        if (reset) begin
            PC       <= {REGISTER_WIDTH{1'b0}};
            lw_wait  <= 1'b0;
            finish_r <= 1'b0;
        end else begin
            lw_wait <= stall;
            if (Finish)
                finish_r <= 1'b1;
            if (!stall && !finish_r)
                PC <= PCNext;
        end
    end

    // Instruction memory (the ROM in the test bench is addressed per word)
    assign instruction_memory_address = PC[(INSTRUCTION_MEMORY_ADDRESS_WIDTH + 1):2];

    // ---------------------------------------------------------------
    // Control unit
    // ---------------------------------------------------------------
    control_unit ControlUnit (
        .op(instruction_memory_read[6:0]),
        .funct3(instruction_memory_read[14:12]),
        .funct7(instruction_memory_read[31:25]),
        .Zero(Zero),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .Finish(Finish)// Not specified
    );

    // ---------------------------------------------------------------
    // Register file and extend
    // ---------------------------------------------------------------
    register_file #(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) RegFile (
        .clk(clk), 
        .reset(reset),
        .A1(instruction_memory_read[19:15]),   // rs1
        .A2(instruction_memory_read[24:20]),   // rs2
        .A3(instruction_memory_read[11:7]),    // rd
        .WD3(Result),
        .WE3(RegWrite_eff),
        .RD1(SrcA),
        .RD2(RD2)
    );

    extend Extend (
        .Instr(instruction_memory_read[31:7]),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    // ---------------------------------------------------------------
    // ALU
    // ---------------------------------------------------------------
    assign SrcB = ALUSrc ? ImmExt : RD2;

    alu #(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) aluBlock (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    // ---------------------------------------------------------------
    // Data memory (the RAM in the test bench: A, WD, WE, RD)
    // ---------------------------------------------------------------
    assign data_memory_address = ALUResult[(DATA_MEMORY_ADDRESS_WIDTH + 1):2];   // A  (byte -> word address)
    assign data_write_value    = RD2;                                           // WD
    assign data_write_enable   = MemWrite;                                      // WE
    assign ReadData            = data_memory_read;                              // RD

    // ---------------------------------------------------------------
    // Write back
    // ---------------------------------------------------------------
    assign Result = ResultSrc ? ReadData : ALUResult;

    assign core_finish_signal = finish_r;

endmodule