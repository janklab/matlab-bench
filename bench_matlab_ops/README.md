bench_matlab_ops
==================

## Summary

This is a tool to measure the performance of basic Matlab function call and property access operations. It does this by roughly assessing the overhead of no-op or "nop" function calls.

This tool is not interested in the performance of numeric operations, useful functions, or anything else that does real calculations.

This is a reproduction of the code used to produce the benchmarks in this StackOverflow question. http://stackoverflow.com/questions/1693429/is-matlab-oop-slow-or-am-i-doing-something-wrong

Your measurement results may vary between machines, operating systems, Matlab releases, 32-bit vs 64-bit architectures, and phase of the moon. The numbers should only be taken as indicative of the relative cost of operations within a given Matlab environment, and between Matlab releases. They are not precise or broadly applicable.

## Usage

To use this tool, run `bench_matlab_ops` from within Matlab. For details, see its helptext and source code.

## Code Style

The code style in this tool is written to minimize the chance of interfering with the measurement of the operations being benchmarked. There's a good amount of copy-and-paste code, un-scoped functions, and redundancy. Don't take this as indicative of what normal Matlab code should look like.

