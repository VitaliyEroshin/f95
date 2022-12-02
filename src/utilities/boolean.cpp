#include "boolean.h"

std::ostream& operator<<(std::ostream& out, const BoolExpr& expr) {
    out << expr();
    return out;
}

BoolExpr operator&(const BoolExpr& lhs, const BoolExpr& rhs) {
    auto l = [lhs, rhs](){
        return lhs() && rhs();
    };
    return {l};
}

BoolExpr operator|(const BoolExpr& lhs, const BoolExpr& rhs) {
    auto l = [lhs, rhs](){
        return lhs() || rhs();
    };
    return {l};
}
