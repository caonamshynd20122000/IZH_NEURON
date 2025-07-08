`timescale 1ns / 1ps

module RAM_09 #(
    parameter NUMBER      = 0,                // MIF index
    parameter WIDTH       = 10,               // Bit width (not directly used here)
    parameter NEURON_ADR  = 5,                // Address width
    parameter WEIGHTS     = 10                // Data width
)(
    input  wire                       clk,
    input  wire                       we,
    input  wire [NEURON_ADR:0]        a,       // write address
    input  wire [NEURON_ADR:0]        dpra,    // read address
    input  wire [WEIGHTS:0]           di,      // data input
    output reg  [WEIGHTS:0]           dpo      // data output
);

    localparam DEPTH = 64;

    // Memory declaration
    reg [WEIGHTS:0] RAM [0:DEPTH-1];

    // Initialization from file
    initial begin
        string file_name;
        file_name = $sformatf("RAM%0d.mif", NUMBER);
        $readmemb(file_name, RAM); // Use $readmemh if using hex instead of binary
    end

    // Write logic
    always @(posedge clk) begin
        if (we)
            RAM[a] <= di;
    end

    // Asynchronous read
    always @(*) begin
        dpo = RAM[dpra];
    end

endmodule
