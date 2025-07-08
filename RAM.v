`timescale 1ns / 1ps
module RAM #(
    parameter NUMBER = 0,
    parameter WIDTH = 8,
    parameter NEURON_ADR = 5,
    parameter WEIGHTS = 31    
)(
    input wire clk,
    input wire we,
    input wire [NEURON_ADR : 0] a,
    input wire [NEURON_ADR : 0] dpra,
    input wire [WEIGHTS : 0]  di,
    output reg [WEIGHTS : 0] dpo
);

    // Khai báo RAM (dùng chung cho sim & synth)
    reg [WEIGHTS : 0] RAM [0 : 255];

    // Simulation-only logic
    `ifndef SYNTHESIS
        reg [255:0] filename;

        // Load RAM content from file in simulation
        initial begin
            $sformat(filename, "/home/caonam/TEMP/RAM/RAM%0d.mif", NUMBER);
            $readmemb(filename, RAM);
            $display("Reading ...");
            $display("Tên tệp: %s", filename);
        end

        // Write to RAM and back to file during simulation
        always @(posedge clk) begin
            if (we) begin
                RAM[a] <= di;
                $sformat(filename, "/home/caonam/TEMP/RAM/RAM%0d.mif", NUMBER);
                $writememb(filename, RAM);
                $display("Writing ...");
            end
        end
    `else
        // Synthesizable write logic
        always @(posedge clk) begin
            if (we)
                RAM[a] <= di;
        end
    `endif

    // Read logic (same for both sim and synth)
    always @(*) begin
        dpo = RAM[dpra];
    end

endmodule
