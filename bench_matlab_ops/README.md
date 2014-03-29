bench_matlab_ops
==================

## Summary

This is a tool to measure the performance of basic Matlab function call and property access operations. It does this by roughly assessing the overhead of no-op or "nop" function calls.

This tool is not interested in the performance of numeric operations, useful functions, or anything else that does real calculations.

This is a reproduction of the code used to produce the benchmarks in this StackOverflow question. http://stackoverflow.com/questions/1693429/is-matlab-oop-slow-or-am-i-doing-something-wrong

Your measurement results may vary between machines, operating systems, Matlab releases, 32-bit vs 64-bit architectures, and phase of the moon. The numbers should only be taken as indicative of the relative cost of operations within a given Matlab environment, and between Matlab releases. They are not precise or broadly applicable.

## Usage

To use this tool, open Matlab, `cd` to this directory, and run `bench_matlab_ops`. For details, see its helptext and source code.

## Code Style

The code style in this tool is written to minimize the chance of interfering with the measurement of the operations being benchmarked. There's a good deal of copy-and-paste code, un-scoped functions, and redundancy. Don't take this as indicative of what normal Matlab code should look like (or what I normally write, for that matter).

## Build Notes

### MEX Functions

The binary MEX functions were built with the default `mex mexnop.c` command, under the following environments.

* Windows (x86 and x64): Windows 7 SDK on Windows 7 SP1
* Mac OS X: LLVM-gcc from Xcode 5.1 on OS X 10.9 Mavericks
* Linux: gcc 4.7.2 on Debian 7.4

### Tic/toc

The code uses Matlab's `tic`/`toc` functions to do timing. There is an issue with them returning incorrect timings on certain processors. (An issue with CPU frequency scaling and the hardware timer.) If tic/toc hits this bug on your CPU, the results will be wrong here.

### Assumptions


* Calling stuff from within a local function is as cheap as calling it from a top-level function.
* The "end" syntax for function definitions doesn't affect performance of things you call from that function
* tic/toc works and returns wall time (untrue on some CPUs due to a timer bug)
* A couple frames sitting on the function call stack don't affect performance.

