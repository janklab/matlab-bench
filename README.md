# matlab-bench

This is a small collection of utilities for exploring and learning about the behavior of the Matlab interpreter and IDE.

Each of the tools is in its own subdirectory from which it can be run.

This is the benchmark used in [the "Is Matlab OOP slow?" Stack Overflow answer](https://stackoverflow.com/questions/1693429/is-matlab-oop-slow-or-am-i-doing-something-wrong#:~:text=The%20short%20answer%20is%3A%20yes,you%20can%20).

## Caveats

The results of these tools are inherently system-dependent. Be careful about extrapolating what you learn from them.

These tools are not intended for use in production code. The code in this project is not suitable for reuse. It does not define any stable or public APIs.

## License

This software is released under the MIT License. See `LICENSE.txt` for details.

## Quick Start

All the code can be run from within Matlab.

To benchmark the overhead of function and method calls:

```matlab
cd bench_matlab_ops
bench_matlab_nops
```

## Tools

* `bench_matlab_ops` – Benchmarks the overhead of function calls and basic OO operations.
* `bench_matlab_ops/compareStringAndCharOps` – Compare speed of equivalent operations on char and string arrays.
* `java_lib_versions` – Detects the versions of Java libraries that Matlab ships with (work in progress).

## Author

Andrew Janke <janke@pobox.com>, <https://apjanke.net>.

This is an independent project. It is not affiliated with The MathWorks, creators of Matlab.

This project is part of the [Janklab](https://janklab.net/) suite of open-source libraries for Matlab.
