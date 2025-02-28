import random

class Core:
    """Represents a standard processing core."""
    def __init__(self, core_id, special_core):
        self.core_id = core_id
        self.registers = {'A': 0, 'B': 0, 'C': 0, 'D': 0}  # ✅ Registers – Store values for computation
        self.special_core = special_core
        self.stack = []  # ✅ Stack for PUSH/POP operations
    
    def execute(self, instruction, operand1=None, operand2=None):
        """Executes a given instruction."""
        if instruction == 'MOV':
            self.registers[operand1] = operand2
        elif instruction == 'ADD':
            self.registers[operand1] += self.registers[operand2]  # ✅ ALU (Arithmetic Logic Unit) – Perform operations like addition or bitwise logic
        elif instruction == 'SUB':
            self.registers[operand1] -= self.registers[operand2]
        elif instruction == 'MUL':
            self.registers[operand1] *= self.registers[operand2]
        elif instruction == 'DIV':
            self.registers[operand1] //= self.registers[operand2] if self.registers[operand2] != 0 else 1
        elif instruction == 'MOD':
            self.registers[operand1] %= self.registers[operand2] if self.registers[operand2] != 0 else 1
        elif instruction == 'AND':
            self.registers[operand1] &= self.registers[operand2]
        elif instruction == 'OR':
            self.registers[operand1] |= self.registers[operand2]
        elif instruction == 'XOR':
            self.registers[operand1] ^= self.registers[operand2]
        elif instruction == 'NOT':
            self.registers[operand1] = ~self.registers[operand1]
        elif instruction == 'SHL':
            self.registers[operand1] <<= operand2
        elif instruction == 'SHR':
            self.registers[operand1] >>= operand2
        elif instruction == 'PUSH':
            self.stack.append(self.registers[operand1])
        elif instruction == 'POP':
            if self.stack:
                self.registers[operand1] = self.stack.pop()
        elif instruction == 'JMP':
            return operand1
        elif instruction == 'JZ':
            return operand1 if self.registers['A'] == 0 else None
        elif instruction == 'JNZ':
            return operand1 if self.registers['A'] != 0 else None
        elif instruction == 'CMP':
            self.registers['C'] = (self.registers[operand1] == self.registers[operand2])
        elif instruction == 'HLT':
            return 'HALT'
        elif operand1 == '0 or 1':
            return self.special_core.resolve()
        return self.registers

class SpecialCore:
    """Represents the 9th core that handles unstable states (0 or 1) for all cores."""
    def resolve(self):
        """Resolves unstable state probabilistically."""
        return random.choice([0, 1])

class Memory:
    """Handles memory read and write operations."""
    def __init__(self, size=256):
        self.memory = [0] * size  # ✅ Memory Interface – Read/write data
    
    def load(self, address):
        return self.memory[address]
    
    def store(self, address, value):
        self.memory[address] = value

class ControlUnit:
    """Manages instruction flow and core allocation."""
    def __init__(self):
        self.special_core = SpecialCore()
        self.cores = [Core(i, self.special_core) for i in range(8)]  # Standard cores 0-7
        self.memory = Memory()
    
    def execute_instruction(self, core_id, instruction, operand1=None, operand2=None):
        """Executes an instruction on the specified core."""
        if core_id < 8:
            return self.cores[core_id].execute(instruction, operand1, operand2)
        elif core_id == 8:
            return self.special_core.resolve()
        else:
            raise ValueError("Invalid core ID")
    
    def memory_operation(self, operation, address, value=None):
        """Handles memory read and write operations."""
        if operation == 'LOAD':
            return self.memory.load(address)
        elif operation == 'STORE':
            self.memory.store(address, value)
        else:
            raise ValueError("Invalid memory operation")

# ✅ Core Components of the CPU
# ✅ Neutral Trinary CPU Instruction Set
# ✅ Neutral Trinary CPU Pipeline
# ✅ Sample Program Execution

# Example Usage:
if __name__ == "__main__":
    cu = ControlUnit()
    
    # Standard core execution
    print("Core 0 Executing MOV A, 5")
    print(cu.execute_instruction(0, 'MOV', 'A', 5))
    
    print("Core 0 Executing ADD A, A")
    print(cu.execute_instruction(0, 'ADD', 'A', 'A'))
    
    print("Core 0 Executing CMP A, B")
    print(cu.execute_instruction(0, 'CMP', 'A', 'B'))
    
    print("Core 0 Executing HLT")
    print(cu.execute_instruction(0, 'HLT'))
    
    # Special core resolving unstable state for all cores
    print("Special Core Resolving '0 or 1'")
    print(cu.execute_instruction(8, None))
    
    # Memory operations
    print("Storing 42 at memory address 10")
    cu.memory_operation('STORE', 10, 42)
    print("Loading from memory address 10")
    print(cu.memory_operation('LOAD', 10))
