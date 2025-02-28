module Core #(parameter ID = 0) (
    input clk,
    input rst,
    input [1:0] instr,
    input [7:0] operand1,
    input [7:0] operand2,
    output reg [7:0] result
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 8'b0;
        else begin
            case(instr)
                2'b00: result <= operand1 + operand2; // ADD
                2'b01: result <= operand1 & operand2; // AND
                2'b10: result <= operand1 | operand2; // OR
                2'b11: result <= ~operand1; // NOT
                default: result <= 8'b0;
            endcase
        end
    end
endmodule

module SpecialCore (
    input clk,
    input rst,
    output reg [7:0] resolved_value
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            resolved_value <= 8'b0;
        else 
            resolved_value <= ($random % 2) ? 8'b1 : 8'b0; // Random 0 or 1
    end
endmodule

module Processor (
    input clk,
    input rst,
    input [3:0] core_id,
    input [1:0] instr,
    input [7:0] operand1,
    input [7:0] operand2,
    output [7:0] result
);
    wire [7:0] core_results[0:7];
    wire [7:0] special_core_result;
    
    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin: cores
            Core #(i) core_inst (
                .clk(clk),
                .rst(rst),
                .instr(instr),
                .operand1(operand1),
                .operand2(operand2),
                .result(core_results[i])
            );
        end
    endgenerate
    
    SpecialCore special_core (
        .clk(clk),
        .rst(rst),
        .resolved_value(special_core_result)
    );
    
    assign result = (core_id == 4'b1000) ? special_core_result : core_results[core_id];
endmodule
