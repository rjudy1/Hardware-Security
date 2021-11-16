import sys
validInstruction = ["ADC", "ADD", "ADIW", "AND", "ANDI", "ASR", "BCLR", "BLD", "BRBS", "BREQ", "BRGE", "BRLT", "BRCS", "BRBC", "BRNE", "BRCC", "BSET", "BST", "CALL", "CBI", "CBR", "CLI", "CLR", "COM", "CP", "CPC", "CPI", "CPSE", "DEC", "ELPM", "EOR", "FMUL", "FMULS", "FMULSU", "ICALL", "IN", "INC", "IJMP", "JMP", "LDD", "LDI", "LDS", "LPM", "LSL", "LSR", "MOV", "MOVW", "MULSU", "MULS", "NEG", "NOP", "NOT", "OR", "ORI", "OUT", "POP", "PUSH", "RCALL", "RET", "RETI", "ROR", "RJMP", "ROL", "SBC", "SBCI", "SBI", "SBIC", "SBIS", "SBIW", "SBRC", "SBRS", "SDS", "SDD", "SER", "SPM", "STD", "STS", "SUB", "SUBI", "SWAP", "WDR"]
invalidRange = ["0x22", "0x23", "0x24", "0x25", "0x26", "0x27", "0x28", "0x29", "0x2D", "0x2E", "0x2F", "0x30", "0x31", "0x32", "0x33", "0x34", "0x35", "0x36", "0x37", "0x38", "0x39", "0x3A", "0x3B", "0x3C", "0x3D", "0x3E", "0x3F", "0x40", "0x41", "0x42", "0x43", "0x44", "0x45", "0x46", "0x47", "0x48", "0x49", "0x4A", "0x4B", "0x4C", "0x4D", "0x4E", "0x4F", "0x50", "0x51", "0x52", "0x53", "0x54", "0x55", "0x56", "0x57", "0x58", "0x59", "0x5A", "0x5B", "0x5C", "0x5D", "0x5E"]

#Functions
def waitForInput():
    a = input('Press enter to exit')
    if a:
        pass


#Running code
if len(sys.argv) != 2:
    print("checkInstructions: Missing file operand (lss file)")
    waitForInput()
    exit(1)

try:
    if sys.argv[1][-4:].lower() != ".lss":
        print("File is not of extention .lss")
        waitForInput()
        exit(1)

    file = open(sys.argv[1], 'r')
except FileNotFoundError as e:
    print("File was not found or is not accessible. Make sure you selected a valid lss file.")
    waitForInput()
    exit(1)

# File is assumed to be right from this point on

Lines = file.readlines()

seenInstructions = []
invalidInstruction = []

print("These instructions may have invalid registers:")

for line in Lines:
    if line[0].lower() == " ":          #only lines with spaces have instructions
        tokens = line.split()
        if tokens[0][-1] == ":":        #instructions always start with addr:
            if(tokens[3].upper() not in seenInstructions):
                seenInstructions.append(tokens[3].upper())
                if(tokens[3].upper() not in validInstruction):
                    invalidInstruction.append(tokens[3].upper())

            if any(s in line for s in invalidRange):
                print(line)



invalidInstruction.sort()

if len(invalidInstruction) != 0:
    print("These instructions are not in the valid instruction list:\n")
    print(*invalidInstruction, sep = "\n")        #Print each invalid instruction on a new line


def waitForInput():
    a = input('Press enter to exit')
    if a:
        pass
