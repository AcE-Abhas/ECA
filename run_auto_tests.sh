#!/bin/bash
# Usage: bash run_tests.sh [number_of_tests]   (default: all test/output/test*.out)
N=${1:-$(ls test/output/test*.out | wc -l)}
pass=0

for ((i = 0; i < N; i++)); do
    vvp convolution_testbench +X=$i > /dev/null
    if diff -q test_result.out test/output/test$i.out > /dev/null; then
        echo "test $i: PASS"
        pass=$((pass + 1))
    else
        echo "test $i: FAIL"
    fi
done

echo "$pass / $N passed"