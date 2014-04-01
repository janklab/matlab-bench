matlab-bench
============

This is a small collection of utilities for exploring and learning about the behavior of the Matlab interpreter and IDE.

Each of the tools is in its own subdirectory from which it can be run.

## Author

Andrew Janke <janke@pobox.com>

This is an independent project. It is not affiliated with The MathWorks, creators of Matlab.

## Caveats

The results of these tools are inherently system-dependent. Be careful about extrapolating what you learn from them.

These tools are not intended for use in production code. The code in this project is not suitable for reuse. It does not define any stable or public APIs.

## License

This software is released under the MIT License. See LICENSE.txt for details.

## Quick Start

All the code can be run from within Matlab.

To benchmark the overhead of function and method calls:

    cd bench_matlab_ops
    bench_matlab_nops

## Tools

* bench_matlab_ops – Benchmarks the overhead of function calls and basic OO operations
* java_lib_versions – Detects the versions of Java libraries that Matlab ships with (work in progress)
