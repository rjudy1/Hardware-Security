import sys
validInstruction = ["ADC", "ADD", "ADIW", "AND", "ANDI", "ASR", "BCLR", "BLD", "BRBS", "BRBC", "BSET", "BST", "CALL", "CBI", "CBR", "CLR", "COM", "CP", "CPC", "CPI", "CPSE", "DEC", "ELPM", "EOR", "FMUL", "FMULS", "FMULSU", "ICALL", "IN", "INC", "IJMP", "JMP", "LDD", "LDI", "LDS", "LPM", "LSL", "LSR", "MOV", "MOVW", "MULSU", "MULS", "NEG", "NOP", "NOT", "OR", "ORI", "OUT", "POP", "PUSH", "RCALL", "RET", "RETI", "ROR", "RJMP", "ROL", "SBC", "SBCI", "SBI", "SBIC", "SBIS", "SBIW", "SBRC", "SBRS", "SDS", "SDD", "SER", "SPM", "STD", "STS", "SUB", "SUBI", "SWAP", "WDR"]


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

for line in Lines:
    if line[0].lower() == " ":          #only lines with spaces have instructions
        tokens = line.split()
        if tokens[0][-1] == ":":        #instructions always start with addr:
            if(tokens[3].upper() not in seenInstructions):
                seenInstructions.append(tokens[3].upper())
                if(tokens[3].upper() not in validInstruction):
                    invalidInstruction.append(tokens[3].upper())

invalidInstruction.sort()

if len(invalidInstruction) != 0:
    print("These instructions are not in the valid instruction list:\n")
    print(*invalidInstruction, sep = "\n")        #Print each invalid instruction on a new line


def waitForInput():
    a = input('Press enter to exit')
    if a:
        pass
