
// ---------------------------------------------------------------
    // Data memory (the RAM in the test bench: A, WD, WE, RD)
    // ---------------------------------------------------------------
module Data_memory#(
    parameter REGISTER_WIDTH = 32,
    parameter DATA_MEMORY_ADDRESS_WIDTH = 5
) (
    input  wire clk,
    input  wire WE,
    input  wire [(REGISTER_WIDTH - 1):0] A,
    input  wire [(REGISTER_WIDTH - 1):0] WD,
    input  wire [(REGISTER_WIDTH - 1): 0] data_memory_read,
    output reg  [(REGISTER_WIDTH - 1):0] RD,
    output reg [(DATA_MEMORY_ADDRESS_WIDTH - 1):0] data_memory_address,
    output reg [(REGISTER_WIDTH - 1):0] data_write_value,
    output reg data_write_enable
);

    assign data_write_enable   = WE;

    always @(posedge clk) begin
        if (WE) begin
            data_memory_address = A[(DATA_MEMORY_ADDRESS_WIDTH + 1):2];   // byte -> word address
            data_write_value    = WD;
        end else begin
            RD            = data_memory_read;
        end
    end

endmodule