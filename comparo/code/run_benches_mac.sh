#!/bin/bash

# Set up CPU info

cpu_str=$(sysctl -n machdep.cpu.brand_string)
mfgr=$(echo "$cpu_str" | cut -d ' ' -f 1)
if [[ "$mfgr" = "Intel(R)" ]]; then
  cpu_make="Intel"
  cpu_model=$(echo "$cpu_str" | cut -d ' ' -f 3)
elif [[ "$mfgr" = "AMD" ]]; then
  cpu_make="AMD"
else
  echo "Unrecognized CPU manufacturer: '$mfgr'" >&2
  exit 1
fi

export BENCHMAT_CPU_MAKE="$cpu_make"
export BENCHMAT_CPU_MODEL="$cpu_model"
export BENCHMAT_CPU_ID="$cpu_make $cpu_model"

# Run benchmarks on everything

echo "Running Python benchmark..."
PYTHONPATH="./python" python3 python/run_benchmark.py

echo "All benchmarks done."