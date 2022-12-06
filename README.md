# Fortran95 Interpreter
## How to use?
1. First, you need to build interpreter
```
cmake -B build
cmake --build build
```

2. If the build completes successfully, the interpreter binary will be located at ```./bin/interpreter```. So, you can run it like so:
```
./bin/interpreter <path/to/file>
```

## Testing
This repo also provides some testing tools. Testing program should be built by hands like so:
```
g++ -std=c++17 ./testing/main.cpp -o tester
```
Then, you can run tests like so:
```
./tester <path/to/interpreter> <path/to/tests>
```
Where tests folder must have following structure
```
tests
├── answers
│   ├── test1.txt
│   ├── test2.txt
└── tests
    ├── test1.txt
    └── test2.txt
````
If you do not want to make tests yourself, you can use ours (```./testing/tests```)
