module NineCoreProcessor(
    input logic clk,
    input logic rst,
    input logic [31:0] instruction,
    output logic [31:0] result
);

    logic [31:0] core_outputs[8:0];
    logic [31:0] alu_result;
    logic [31:0] register_data;
    logic [31:0] memory_data;

    // Standard Binary Cores (8 Cores)
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : standard_cores
            Core core (
                .clk(clk),
                .rst(rst),
                .instruction(instruction),
                .output_data(core_outputs[i])
            );
        end
    endgenerate

    // Probabilistic Core (Handles unstable states)
    ProbabilisticCore core_8 (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .output_data(core_outputs[8])
    );

    // ALU
    ALU alu (
        .clk(clk),
        .input_data(core_outputs),
        .result(alu_result)
    );

    // Registers
    Registers registers (
        .clk(clk),
        .write_data(alu_result),
        .read_data(register_data)
    );

    // Memory Controller
    MemoryController mem_ctrl (
        .clk(clk),
        .read_data(memory_data),
        .write_data(register_data)
    );

    // Logic Control Unit
    LCU lcu (
        .clk(clk),
        .instruction(instruction)
    );

    assign result = alu_result;

endmodule
