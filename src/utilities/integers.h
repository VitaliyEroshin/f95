#pragma once

#include <functional>
#include <iostream>
#include <optional>
#include <unordered_map>

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

std::ostream& operator<<(std::ostream& out, const IntExpr& expression);

IntExpr operator+(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator-(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator*(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator/(const IntExpr& lhs, const IntExpr& rhs);

IntExpr operator%(const IntExpr& lhs, const IntExpr& rhs);

class IntegersModule {
    std::unordered_map<std::string, int> variables;

public:
    bool declare(const std::string& variable);
    bool set(const std::string& variable, int value);
    int& get(const std::string& variable);
    bool has(const std::string& variable);

    IntExpr get_intexpr(const std::string& variable);
};
