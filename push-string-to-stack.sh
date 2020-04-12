#!/bin/bash
# Quick and dirty tool for generating instructions to push a long string on the stack (for x86 or x86_64)
#
# Usage: ./push-string-to-stack.sh <file containing string> <cluster size in bytes> <indentation>
# Example: ./push-string-to-stack.sh filename 8 "\t" | xclip
#
# Output may include null-bytes. To avoid them, make sure your string length is a multiple of your given cluster size
# and push a null byte on the stack like so:
#
#	xor eax, eax
#	push eax
#	push 0x........ ;your string here

file=$1
cluster=$(expr 2 \* ${2})
indent=$3

# Turn string into sequence of raw bytes and apply padding so that byte count is a multiple of $cluster
padding_len=$(expr 2 \* \( $cluster - $(wc -c $file | awk '{print $1}') % $cluster \))
padding=$(printf "%${padding_len}s" | tr ' ' '0')
rawbytes=$(xxd -g 1 $file | cut -c 11-57 | sed 's/\ //g' | tr -d "\n")$padding

# Reverse sequence of bytes
# (in order to be able to use the stack pointer as a pointer to the string after pushing)
revbytes=$(echo $rawbytes | sed 's/\([0-9|a-f]\{2\}\)/\1\n/g' | tac | tr -d "\n")

# Push in clusters of $2 bytes and apply indentation for easy copy-pasting
printf $revbytes | sed "s/\\([0-9|a-f]\{${cluster}\}\\)/0x\1\\n/g" | awk "{print \"${indent}push \" \$1}"

