#pragma once

#include <functional>
#include <iostream>

struct IntExpr {
    std::function<int()> fn;
    IntExpr(): fn([](){ return 0; }) {}
    IntExpr(std::function<int()> fn) : fn(fn) {}
    IntExpr(const IntExpr& other): fn(other.fn) {}
    IntExpr(int value) { fn = [value]() { return value; }; }

    int operator()() const { return fn(); }
    IntExpr operator-() const {
        std::function<int()> copy = fn;
        return {[copy](){ return !copy(); }}; 
    }
};

std::ostream& operator<<(std::ostream& out, const IntExpr& expr);

IntExpr operator+(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator-(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator*(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator/(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator%(const IntExpr& lhs, const IntExpr& rhs);