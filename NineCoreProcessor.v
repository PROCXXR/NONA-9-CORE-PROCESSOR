module NineCoreProcessor(
    input clk,
    input reset,
    input [3:0] core_id,
    input [7:0] instruction,
    input [7:0] operand1,
    input [7:0] operand2,
    output reg [7:0] result
);

    reg [7:0] registers [0:7][0:3]; // 8 cores, each with 4 registers (A, B, C, D)
    reg [7:0] memory [0:255]; // Memory Interface
    reg [7:0] stack [0:15]; // Stack for function calls
    integer sp; // Stack pointer
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 8'b0;
            sp <= 0;
        end else begin
            case (instruction)
                8'h00: registers[core_id][operand1] <= operand2; // MOV
                8'h01: registers[core_id][operand1] <= registers[core_id][operand1] + registers[core_id][operand2]; // ADD
                8'h02: registers[core_id][operand1] <= registers[core_id][operand1] - registers[core_id][operand2]; // SUB
                8'h03: registers[core_id][operand1] <= registers[core_id][operand1] * registers[core_id][operand2]; // MUL
                8'h04: registers[core_id][operand1] <= (registers[core_id][operand2] != 0) ? (registers[core_id][operand1] / registers[core_id][operand2]) : 8'b1; // DIV
                8'h05: registers[core_id][operand1] <= (registers[core_id][operand2] != 0) ? (registers[core_id][operand1] % registers[core_id][operand2]) : 8'b1; // MOD
                8'h06: registers[core_id][operand1] <= registers[core_id][operand1] & registers[core_id][operand2]; // AND
                8'h07: registers[core_id][operand1] <= registers[core_id][operand1] | registers[core_id][operand2]; // OR
                8'h08: registers[core_id][operand1] <= registers[core_id][operand1] ^ registers[core_id][operand2]; // XOR
                8'h09: registers[core_id][operand1] <= ~registers[core_id][operand1]; // NOT
                8'h0A: registers[core_id][operand1] <= registers[core_id][operand1] << operand2; // SHL
                8'h0B: registers[core_id][operand1] <= registers[core_id][operand1] >> operand2; // SHR
                
                // Fix: Wrap in `begin-end`
                8'h0C: begin
                    stack[sp] <= registers[core_id][operand1]; 
                    sp <= sp + 1; 
                end // PUSH

                // Fix: Prevent stack underflow
                8'h0D: begin 
                    if (sp > 0) begin 
                        sp <= sp - 1; 
                        registers[core_id][operand1] <= stack[sp]; 
                    end 
                end // POP

                8'h0E: begin
                    result <= operand1;
                end // JMP

                8'h0F: begin
                    if (registers[core_id][0] == 8'b0) 
                        result <= operand1;
                end // JZ

                8'h10: begin
                    if (registers[core_id][0] != 8'b0) 
                        result <= operand1;
                end // JNZ

                8'h11: begin
                    registers[core_id][2] <= (registers[core_id][operand1] == registers[core_id][operand2]) ? 8'b1 : 8'b0;
                end // CMP

                // Fix: Prevent stack overflow
                8'h12: begin
                    if (sp < 15) begin 
                        sp <= sp + 1; 
                        stack[sp] <= operand1; 
                    end 
                end // CALL

                // Fix: Prevent stack underflow
                8'h13: begin
                    if (sp > 0) begin 
                        sp <= sp - 1; 
                        result <= stack[sp]; 
                    end 
                end // RET

                8'h14: begin
                    result <= 8'b11111111;
                end // HLT (HALT)

                8'h15: ; // NOP (No operation)

                8'h16: begin
                    registers[core_id][operand1] <= memory[operand2];
                end // LOAD

                8'h17: begin
                    memory[operand2] <= registers[core_id][operand1];
                end // STORE

                default: begin
                    result <= 8'b00000000;
                end // DEFAULT
            endcase
        end
    end
endmodule
