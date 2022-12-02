#include "integers.h"

std::ostream& operator<<(std::ostream& out, const IntExpr& expr) {
    out << expr();
    return out;
}

IntExpr operator+(const IntExpr& lhs, const IntExpr& rhs) {
    auto l = [lhs, rhs]() {
        return lhs() + rhs();
    };

    return {l};
}

IntExpr operator-(const IntExpr& lhs, const IntExpr& rhs) {
    auto l = [lhs, rhs]() {
        return lhs() - rhs();
    };

    return {l};
}

IntExpr operator*(const IntExpr& lhs, const IntExpr& rhs) {
    auto l = [lhs, rhs]() {
        return lhs() * rhs();
    };

    return {l};
}

IntExpr operator/(const IntExpr& lhs, const IntExpr& rhs) {
    auto l = [lhs, rhs]() {
        return lhs() / rhs();
    };

    return {l};
}

IntExpr operator%(const IntExpr& lhs, const IntExpr& rhs) {
    auto l = [lhs, rhs]() {
        return lhs() % rhs();
    };

    return {l};
}