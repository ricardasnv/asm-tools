#!/bin/bash
# Quick and dirty tool for generating instructions to push a long string on the stack (for x86 or x86_64)
# Usage: ./push-string-to-stack.sh <file containing string> <cluster size in bytes> <register to use> <indentation>
# Example: ./push-string-to-stack.sh filename 8 rax "\t" | xclip

file=$1
cluster=$(expr 2 \* ${2})
register=$3
indent=$4

# Turn string into sequence of raw bytes and apply padding so that byte count is a multiple of $cluster
padding_len=$(expr 2 \* \( $cluster - $(wc -c $file | awk '{print $1}') % $cluster \))
padding=$(printf "%${padding_len}s" | tr ' ' '0')
rawbytes=$(xxd -g 1 $file | cut -c 11-57 | sed 's/\ //g' | tr -d "\n")$padding

# Reverse sequence of bytes
# (in order to be able to use the stack pointer as a pointer to the string after pushing)
revbytes=$(echo $rawbytes | sed 's/\([0-9|a-f]\{2\}\)/\1\n/g' | tac | tr -d "\n")

# Push in clusters of $2 bytes and apply indentation for easy copy-pasting
printf $revbytes | sed "s/\\([0-9|a-f]\{${cluster}\}\\)/0x\1\\n/g" | awk "{print \"${indent}mov $register, \" \$1 \"\n${indent}push $register\"}"

