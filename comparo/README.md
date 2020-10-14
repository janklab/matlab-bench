# matlab-bench comparo README

This subtree contains code for comparing the relative performance of different programming languages.

## Dir structure

### `results/`

The results database. Results are stored in the format:

* `results/`
  * `<cpu>/`
    * `<language> - <version> - <os>.json`

Where:

* `<language>` is the programming language
* `<version>` is the version of the compiler or the runtime for `<language>`
  * For interpreted languages like Matlab or Python, it's the runtime version
  * For compiled languages like C++ or Go, it's the compiler version
* `<cpu>` is the model of CPU running the benchmark
* `<os>` is `Mac`, `Windows`, or `Linux`

We ignore everything about hardware except for the CPU, assuming OOP overhead is largely CPU-bound.
(God help you if you managed to write a language where method dispatch overhead is RAM-intensive.)

The JSON files are of the format:

```json
{
  'meta' => {a string=>string/number object of some human-readable stuff},
  'results' => {<op> => <usec>}
}
```

Where:

* `<op>` is an operation code from below, as string
* `<usec>` is the average operation time in microseconds

### `code/`

The code directory contains all the language-specific benchmark code, each in a `code/<language>` subdirectory. The compilation and execution process for all the languages is specific to each language; see READMEs in those subdirs for details.

### Operations

These are the operations we measure the execution times of. We try to define them in abstract, language-neutral terms where the operations are either applicable to all languages, or degenerate to natural functional equivalents in the case of languages that don't support these specific things.

| Code             | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| method           | Instance method call on an object                            |
| method_inh_3     | Instance method call, through 3 levels of inheritance        |
| prop             | Instance property access (get/read)                          |
| prop_inh_3       | Instance property access, through 3 levels of inheritance    |
| static_method    | Static method call                                           |
| prop_write       | Mutation of a property on an object                          |

All operations do no useful work. Any work done inside them is just inserted to prevent the compiler from optimizing the entire operation away and busting our benchmark.

## Design Notes

The whole results database is checked in to the repo, because I want to create a central record that anyone can use to run reports on. I think (and hope) that the results are not so system-dependent that we'd want to support the use case of different people maintaining their different results databases.
