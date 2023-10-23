import argparse
import os


vars = dict()

bin_line = ""

opCodes = {
    "add": "000000",
    "addi": "001000",
    "sub": "000000",
    "and": "000000",
    "or": "000000",
    "slt": "000000",
    "beq": "000100",
    "bne": "000101",
    "lw": "100011",
    "sw": "101011",
    "j": "000010",
    "jal": "000011",
    "jr": "000000",
}


r_type = ["add", "sub", "and", "or", "slt", "jr"]
i_type = ["addi", "lw", "sw", "beq", "bne"]



R_function = {
    "add": "100000",
    "sub": "100010",
    "and": "100100",
    "or": "100101"
}

registers = {
    "$zero": "00000",
    "$at": "00001",
    "$v0": "00010",
    "$v1": "00011",
    "$a0": "00100",
    "$a1": "00101",
    "$a2": "00110",
    "$a3": "00111",
    "$t0": "01000",
    "$t1": "01001",
    "$t2": "01010",
    "$t3": "01011",
    "$t4": "01100",
    "$t5": "01101",
    "$t6": "01110",
    "$t7": "01111",
    "$s0": "10000",
    "$s1": "10001",
    "$s2": "10010",
    "$s3": "10011",
    "$s4": "10100",
    "$s5": "10101",
    "$s6": "10110",
    "$s7": "10111",
    "$t8": "11000",
    "$t9": "11001",
    "$k0": "11010",
    "$k1": "11011",
    "$gp": "11100",
    "$sp": "11101",
    "$fp": "11110",
    "$ra": "11111"
}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
                    prog='MIPS-parser',
                    description='basic parser from MIPS assembly to binary')
    parser.add_argument('-i', '--inline', action='store_true')
    parser.add_argument('-f', '--file', type=str)
    args = parser.parse_args()
    print(args)
    
    
    if not args.inline:    
        if args.file and os.path.exists(args.file):
            print(f"{args.file} exists")
        else:
            print("File does not exist")
            exit(1)
        output = open("output.txt", "w")
        with open(args.file, 'r') as f:
            line = f.readline()
            while line:
                print(line)
                items = line.split(' ')
                items = [item.strip() for item in items]
                if line.startswith('#DEFINE'):
                    vars[items[1]] = int(items[2])
                    print(vars)
                else:
                    if items[0] in r_type:
                        try:
                            print(items)
                            bin_line = "000000"+ registers[items[1]]+ registers[items[2]] + registers[items[3]] + "00000" + R_function[items[0]]
                            print(bin_line)
                        except KeyError as e:
                            print("Invalid syntax", e)
                            
                    elif items[0] in i_type:
                        try:
                            print(items)
                            immediate = vars[items[3]] if items[3] in vars else int(items[3])
                            immediate_bin = format(immediate, 'b').zfill(16)
                            bin_line = opCodes[items[0]] + registers[items[1]]+ registers[items[2]] + immediate_bin
                        except KeyError as e:
                            print("Invalid syntax", e)
                output.write(bin_line + "\n")
                line = f.readline()
                
        output.close()
                
    print(vars)
    
    
    