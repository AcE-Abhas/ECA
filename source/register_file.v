`timescale 1ps/1ps

module register_file#(
    parameter REGISTER_WIDTH = 32
) (
    input  wire                          clk,
    input  wire                          reset,   
    input  wire [4:0]                    A1,      // RS1
    input  wire [4:0]                    A2,      // RS2
    input  wire [4:0]                    A3,      // RD
    input  wire [(REGISTER_WIDTH - 1):0] WD3,     // WD
    input  wire                          WE3,     // WE
    output wire [(REGISTER_WIDTH - 1):0] RD1,     
    output wire [(REGISTER_WIDTH - 1):0] RD2      
);

    reg [(REGISTER_WIDTH - 1):0] registers [0:31];
    reg [(REGISTER_WIDTH - 1):0] RD1_r, RD2_r;
    integer i;

    assign RD1 = RD1_r;
    assign RD2 = RD2_r;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= {REGISTER_WIDTH{1'b0}};
        end else if (WE3 && (A3 != 5'd0)) begin //WD3 is written to register A3
            registers[A3] <= WD3;
        end
    end

    always @* begin
        if (A1 == 5'd0)
            RD1_r = {REGISTER_WIDTH{1'b0}};
        else if (WE3 && (A3 == A1))
            RD1_r = WD3;
        else
            RD1_r = registers[A1];

        if (A2 == 5'd0)
            RD2_r = {REGISTER_WIDTH{1'b0}};
        else if (WE3 && (A3 == A2))
            RD2_r = WD3;
        else
            RD2_r = registers[A2];
    end
    

endmodule