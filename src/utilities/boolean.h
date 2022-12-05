#pragma once

#include <functional>
#include <iostream>

struct BoolExpr {
    std::function<bool()> fn;
    BoolExpr(): fn([](){ return false; }) {}
    BoolExpr(std::function<bool()> fn) : fn(fn) {}
    BoolExpr(const BoolExpr& other): fn(other.fn) {}
    BoolExpr(bool value) { fn = [value]() { return value; }; }

    bool operator()() const { return fn(); }
    BoolExpr operator-() const { 
        std::function<bool()> copy = fn;
        return {[copy](){ return !(copy()); }}; 
    }
};

std::ostream& operator<<(std::ostream& out, const BoolExpr& expr);

BoolExpr operator&(const BoolExpr& lhs, const BoolExpr& rhs);

BoolExpr operator|(const BoolExpr& lhs, const BoolExpr& rhs);
