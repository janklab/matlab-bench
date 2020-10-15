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

echo "Running Matlab benchmarks..."
for mver in 2019b 2020a 2020b; do
  app_dir="/Applications/MATLAB_R${mver}.app"
  if [[ -e $app_dir ]]; then
    echo "Running Matlab R${mver} benchmark..."
    matlab_exe="$app_dir/bin/matlab"
    bench_cmd="addpath('matlab'); run_benchmark; exit"
    $matlab_exe -nodisplay -nosplash -batch "$bench_cmd"
  fi
done

echo "All benchmarks done."