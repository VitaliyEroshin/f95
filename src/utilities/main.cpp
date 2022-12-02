#include "boolean.h"
#include <iostream>

#include <any>

int main() {
    std::function<bool()> l = []() {
        return true;
    };
    BoolExpr bx = l;
}