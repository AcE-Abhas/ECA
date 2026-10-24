`timescale 1ps/1ps

// Register file (image: A1, A2, A3, WD3, WE3, CLK, RD1, RD2)
//  - two combinational read ports (A1 -> RD1, A2 -> RD2)
//  - one write port: if WE3 = 1, WD3 is written to register A3 on the rising edge of clk
//  - x0 always reads 0 and ignores writes
//  - reset clears all registers: the program's final "ret" reads ra (x1) and expects 0
module register_file#(
    parameter REGISTER_WIDTH = 32
) (
    input  wire                          clk,   // CLK
    input  wire                          reset,   // clears all registers
    input  wire [4:0]                    A1,      // read address 1 (rs1)
    input  wire [4:0]                    A2,      // read address 2 (rs2)
    input  wire [4:0]                    A3,      // write address  (rd)
    input  wire [(REGISTER_WIDTH - 1):0] WD3,     // write data
    input  wire                          WE3,     // write enable
    output wire [(REGISTER_WIDTH - 1):0] RD1,     // read data 1
    output wire [(REGISTER_WIDTH - 1):0] RD2      // read data 2
);

    reg [(REGISTER_WIDTH - 1):0] registers [0:31];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= {REGISTER_WIDTH{1'b0}};
        end else if (WE3 && (A3 != 5'd0)) begin
            registers[A3] <= WD3;
        end
    end

    assign RD1 = (A1 == 5'd0) ? 0 : (WE3 && A3 == A1) ? WD3 : registers[A1];
    assign RD2 = (A2 == 5'd0) ? 0 : (WE3 && A3 == A2) ? WD3 : registers[A2];

endmodule