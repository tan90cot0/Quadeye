#!/bin/bash

# Compile the C++ program
g++ -o my_program src/main.cpp

# Check if the compilation was successful
if [ $? -ne 0 ]; then
  echo "Compilation failed"
  exit 1
fi

# Run the program with the provided arguments
./my_program "$1" "$2"

# 19
# /Users/aryan/Desktop/humbug/test_cases/level7.txt
