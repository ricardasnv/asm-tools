#!/bin/bash
# Makes shellcode from a given binary
# Usage: ./make-shellcode.sh <path to binary>
# Example: ./make-shellcode.sh a.out | xclip

# Get raw machine code
rawbytes=$(objdump -d a.out | cut -c 11-30 | grep -v '[g-z]' | tr -d "\ \n")

# Format and print
printf $rawbytes | sed 's/\([0-9a-f]\{2\}\)/\\x\1/g' | sed 's/\(^.*$\)/\"\1\"/g'

