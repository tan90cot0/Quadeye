#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <path_to_input_file> <build_threshold> <liquidate_threshold> <path_to_output_file>"
    exit 1
fi

# Assign arguments to variables
INPUT_FILE_PATH=$1
BUILD_THRESHOLD=$2
LIQUIDATE_THRESHOLD=$3
OUTPUT_FILE_PATH=$4

# Run the Python script with the provided arguments
python code_daywise_Pnl.py "$INPUT_FILE_PATH" "$BUILD_THRESHOLD" "$LIQUIDATE_THRESHOLD" "$OUTPUT_FILE_PATH"
