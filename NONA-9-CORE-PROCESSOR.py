import random

class NineCoreProcessor:
    def __init__(self, memory_size=16, seed=None):
        """
        Initializes a 9-core processor with 8 binary cores and 1 special core.
        """
        self.registers = {"A": '0', "B": '0', "C": '0', "D": '0'}
        self.memory = ['0'] * memory_size  # Simple memory model
        self.pc = 0  # Program counter
        self.instructions = []  # Loaded instructions
        self.cores = ["Binary Core" for _ in range(8)] + ["Special Core"]
    
    def set_register(self, reg, value):
        """Sets a register with a value ('0', '1', or '0 or 1')."""
        if reg in self.registers and value in ['0', '1', '0 or 1']:
            self.registers[reg] = value
        else:
            raise ValueError("Invalid register or value. Allowed values: '0', '1', '0 or 1'.")
    
    def resolve_state(self, value, core_id):
        """Resolves an unstable '0 or 1' probabilistically only on the special core."""
        if core_id == 8 and value == '0 or 1':  # Special core handles instability
            return '0' if random.randint(0, 1) == 0 else '1'
        return value
    
    def execute(self, instruction):
        """Executes a single instruction."""
        parts = instruction.split()
        opcode = parts[0]
        core_id = self.pc % 9  # Assigns instruction execution to a core
        
        if opcode == "MOV":
            reg, val = parts[1], parts[2]
            self.set_register(reg, val)
        
        elif opcode == "ADD":
            reg1, reg2 = parts[1], parts[2]
            v1 = self.resolve_state(self.registers[reg1], core_id)
            v2 = self.resolve_state(self.registers[reg2], core_id)
            self.registers["C"] = str(int(v1) ^ int(v2))  # XOR logic
        
        elif opcode == "AND":
            reg1, reg2 = parts[1], parts[2]
            v1 = self.resolve_state(self.registers[reg1], core_id)
            v2 = self.resolve_state(self.registers[reg2], core_id)
            self.registers["C"] = str(int(v1) & int(v2))  # AND logic
        
        elif opcode == "OR":
            reg1, reg2 = parts[1], parts[2]
            v1 = self.resolve_state(self.registers[reg1], core_id)
            v2 = self.resolve_state(self.registers[reg2], core_id)
            self.registers["C"] = str(int(v1) | int(v2))  # OR logic
        
        elif opcode == "NOT":
            reg = parts[1]
            v1 = self.resolve_state(self.registers[reg], core_id)
            self.registers["C"] = '1' if v1 == '0' else '0'
        
        elif opcode == "JMP":
            addr = int(parts[1])
            self.pc = addr - 1  # Jump (subtract 1 because pc increments after execution)
        
        elif opcode == "JZ":
            addr = int(parts[1])
            if self.registers["C"] == '0':
                self.pc = addr - 1
        
        elif opcode == "LOAD":
            reg, addr = parts[1], int(parts[2])
            self.registers[reg] = self.memory[addr]
        
        elif opcode == "STORE":
            reg, addr = parts[1], int(parts[2])
            self.memory[addr] = self.registers[reg]
        
        else:
            raise ValueError(f"Unknown instruction: {opcode}")
    
    def load_program(self, program):
        """Loads a list of instructions into memory."""
        self.instructions = program
    
    def run(self):
        """Executes loaded program instruction by instruction across 9 cores."""
        while self.pc < len(self.instructions):
            self.execute(self.instructions[self.pc])
            self.pc += 1
    
# Example usage
if __name__ == "__main__":
    cpu = NineCoreProcessor()
    program = [
        "MOV A 0 or 1",
        "MOV B 1",
        "ADD A B",
        "STORE C 0",
        "JMP 2"
    ]
    cpu.load_program(program)
    cpu.run()
    print("Final Register State:", cpu.registers)
    print("Memory:", cpu.memory)
