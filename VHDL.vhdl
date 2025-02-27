module NineCoreProcessor(
    input clk,
    input reset,
    input [3:0] opcode,
    input [1:0] reg1, reg2,
    input [3:0] address,
    output reg [1:0] result
);
    
    reg [1:0] registers [3:0];  // 4 registers (A, B, C, D) storing 2-bit values
    reg [1:0] memory [15:0];    // 16 memory locations storing 2-bit values
    reg [3:0] pc; // Program counter
    reg [1:0] core_results [8:0]; // Results from 9 cores
    reg [3:0] active_core; // Keeps track of active core
    reg [2:0] pipeline_stage; // Pipelining stage tracker
    
    // Task Scheduling: Distributes tasks across 9 cores
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            registers[0] <= 2'b00;
            registers[1] <= 2'b00;
            registers[2] <= 2'b00;
            registers[3] <= 2'b00;
            result <= 2'b00;
            pc <= 4'b0000;
            active_core <= 4'b0000;
            pipeline_stage <= 3'b000;
        end else begin
            if (pipeline_stage == 3'b000) begin
                active_core <= (active_core + 1) % 9; // Round-robin task distribution
                pipeline_stage <= 3'b001;
            end else if (pipeline_stage == 3'b001) begin
                case (opcode)
                    4'b0001: // MOV reg1, reg2
                        registers[reg1] <= registers[reg2];
                    
                    4'b0010: // ADD reg1, reg2
                        core_results[active_core] <= registers[reg1] ^ registers[reg2];
                    
                    4'b0011: // AND reg1, reg2
                        core_results[active_core] <= registers[reg1] & registers[reg2];
                    
                    4'b0100: // OR reg1, reg2
                        core_results[active_core] <= registers[reg1] | registers[reg2];
                    
                    4'b0101: // NOT reg1
                        core_results[active_core] <= ~registers[reg1];
                    
                    4'b0110: // LOAD reg1, address
                        registers[reg1] <= memory[address];
                    
                    4'b0111: // STORE reg1, address
                        memory[address] <= registers[reg1];
                    
                    4'b1000: // JMP address
                        pc <= address;
                    
                    4'b1001: // JZ address (Jump if Zero)
                        if (registers[2] == 2'b00) 
                            pc <= address;
                    
                    default: // NOP (No Operation)
                        result <= core_results[active_core];
                endcase
                pipeline_stage <= 3'b010;
            end else if (pipeline_stage == 3'b010) begin
                pc <= pc + 1; // Increment program counter
                pipeline_stage <= 3'b000;
            end
        end
    end
endmodule

// Testbench for NineCoreProcessor
module NineCoreProcessor_tb();
    reg clk;
    reg reset;
    reg [3:0] opcode;
    reg [1:0] reg1, reg2;
    reg [3:0] address;
    wire [1:0] result;
    
    NineCoreProcessor uut (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .reg1(reg1),
        .reg2(reg2),
        .address(address),
        .result(result)
    );
    
    // Clock Generation
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        
        // Test MOV
        opcode = 4'b0001; reg1 = 2'b01; reg2 = 2'b10; #10;
        
        // Test ADD
        opcode = 4'b0010; reg1 = 2'b01; reg2 = 2'b11; #10;
        
        // Test AND
        opcode = 4'b0011; reg1 = 2'b00; reg2 = 2'b01; #10;
        
        // Test OR
        opcode = 4'b0100; reg1 = 2'b10; reg2 = 2'b11; #10;
        
        // Test NOT
        opcode = 4'b0101; reg1 = 2'b01; #10;
        
        // Test LOAD
        opcode = 4'b0110; reg1 = 2'b00; address = 4'b0001; #10;
        
        // Test STORE
        opcode = 4'b0111; reg1 = 2'b10; address = 4'b0010; #10;
        
        // Test JMP
        opcode = 4'b1000; address = 4'b0100; #10;
        
        // Test JZ
        opcode = 4'b1001; address = 4'b0101; #10;
        
        $stop;
    end
endmodule
