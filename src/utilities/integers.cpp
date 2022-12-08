#include "integers.h"

std::ostream& operator<<(std::ostream& out, const IntExpr& expression) {
    out << expression();
    return out;
}

IntExpr operator+(const IntExpr& lhs, const IntExpr& rhs) {
    return {[lhs, rhs]() { return lhs() + rhs(); }};
}

IntExpr operator-(const IntExpr& lhs, const IntExpr& rhs) {
    return {[lhs, rhs]() { return lhs() - rhs(); }};
}

IntExpr operator*(const IntExpr& lhs, const IntExpr& rhs) {
    return {[lhs, rhs]() { return lhs() * rhs(); }};
}

IntExpr operator/(const IntExpr& lhs, const IntExpr& rhs) {
    return {[lhs, rhs]() { return lhs() / rhs(); }};
}

IntExpr operator%(const IntExpr& lhs, const IntExpr& rhs) {
    return {[lhs, rhs]() { return lhs() % rhs(); }};
}

bool IntegersModule::declare(const std::string& variable) {
    if (variables.count(variable)) {
        return false;
    }

    variables.emplace(variable, 0);
    return true;
}

bool IntegersModule::set(const std::string& variable, int value) {
    auto it = variables.find(variable);
    if (it == variables.end()) {
        return false;
    }

    it->second = value;
    return true;
}

int& IntegersModule::get(const std::string& variable) {
    auto it = variables.find(variable);
    if (it != variables.end()) {
        return it->second;
    }

    std::cerr << "Could not find integer variable called";
    std::cerr <<  "(\"" + variable + "\"). I am sorry." << std::endl;
    abort();
}

bool IntegersModule::has(const std::string& variable) {
    return variables.count(variable);
}

IntExpr IntegersModule::get_intexpr(const std::string& variable) {
    return {[this, variable]() {
        return get(variable);
    }};
}