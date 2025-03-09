#!/bin/bash
if [ -z "$1" ]; then
  echo "Использование: $0 <N>"
  exit 1
fi
N=$1
sum=0
for ((i=1; i<=N; i++)); do
  sum=$((sum + i))
done
echo "Сумма чисел от 1 до $N: $sum" > result_loops.txt
