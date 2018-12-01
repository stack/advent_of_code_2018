#!/bin/bash

# Errors make everything fail
set -e

# Compile
swiftc main.swift LineReader.swift -o LineReaderTest

# Test
./LineReaderTest < input.txt

