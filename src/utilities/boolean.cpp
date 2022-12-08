#include "boolean.h"

std::ostream& operator<<(std::ostream& out, const BoolExpr& expr) {
    out << expr();
    return out;
}

BoolExpr operator&(const BoolExpr& lhs, const BoolExpr& rhs) {
    return {[lhs, rhs]() { return lhs() && rhs(); }};
}

BoolExpr operator|(const BoolExpr& lhs, const BoolExpr& rhs) {
    return {[lhs, rhs]() { return lhs() || rhs(); }};
}
