#pragma once

#include <functional>
#include <iostream>
#include <string>
#include <unordered_map>
#include <unordered_set>

struct StringExpr {
    std::function<std::string()> fn;
    StringExpr(): fn([](){ return ""; }) {}
    StringExpr(std::function<std::string()> fn) : fn(fn) {}
    StringExpr(const StringExpr& other): fn(other.fn) {}
    StringExpr(std::string value) { fn = [value]() { return value; }; }

    std::string operator()() const { return fn(); }
};

std::ostream& operator<<(std::ostream& out, const StringExpr& expression);

StringExpr operator/(const StringExpr& lhs, const StringExpr& rhs);

class StringsModule {
    std::unordered_map<std::string, std::string> variables;
    std::unordered_set<std::string> constants;
    std::unordered_map<std::string, int> var_length;

    int length;

public:
    bool declare(const std::string& variable, bool constant = false);
    bool set(const std::string& variable, const std::string& value);
    std::string& get(const std::string& variable);
    bool has(const std::string& variable);
    
    void set_length(int n);
    StringExpr get_strexpr(const std::string& variable);
};
