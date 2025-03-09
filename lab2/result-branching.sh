#!/bin/bash
if [ -z "$1" ]; then
  echo "Использование: $0 <число>"
  exit 1
fi
echo "Квадрат числа $1: $(( $1 * $1 ))" > result_branching.txt
