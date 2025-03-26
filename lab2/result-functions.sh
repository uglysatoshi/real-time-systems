#!/bin/bash
if [ $# -ne 3 ]; then
  echo "Использование: $0 <число1> <число2> <число3>"
  exit 1
fi
average() {
  local sum=$(( $1 + $2 + $3 ))
  echo "Среднее значение: $(echo "$sum / 3" | bc -l)"
}
average $1 $2 $3 > /home/lab2/results/result_functions.txt
