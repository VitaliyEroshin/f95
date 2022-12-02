#include <iostream>
#include <driver.hh>

int main(int argc, char** argv) {
    int result = 0;
    Driver driver;

    for (int i = 1; i < argc; ++i) {
        if (driver.parse(argv[i])) {
            result = 1;
        }
    }

    return result;
}