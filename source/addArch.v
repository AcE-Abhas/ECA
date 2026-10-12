`timescale 1ps/1ps

module addArch#(
    parameter REGISTER_WIDTH = 32
) ( //R-Type
    input wire clock,   // clk
    input wire reset,   // reset
    input wire[(REGISTER_WIDTH - 1):0] value1,
    input wire[(REGISTER_WIDTH - 1):0] value2,
    input wire run_add,  // activate block

    output wire[(REGISTER_WIDTH - 1):0] result
);

endmodule