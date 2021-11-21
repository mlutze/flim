# flim

A Flix implementation of the SLIM programming language,
as described in _Concrete Abstractions_ by Max Hailperin, Barbara Kaiser, and Karl Knight.


### Building

Requires [Stephen Tetley](https://github.com/stephentetley)'s [flix-regex](https://github.com/stephentetley/flix-regex) [flix-parsec](https://github.com/stephentetley/flix-parsec)

Forks of these can be installed locally with the following commands:
```bash
flix install mlutze/flix-regex
flix install mlutze/flix-parsec
```

### Usage
```
flim [-s <stack size>] [-r <registers>] <slim file>
```