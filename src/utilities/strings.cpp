#include "strings.h"

std::ostream& operator<<(std::ostream& out, const StringExpr& expression) {
    out << expression();
    return out;
}

StringExpr operator/(const StringExpr& lhs, const StringExpr& rhs) {
    return { [lhs, rhs]() { return lhs() + rhs(); }};
}

bool StringsModule::declare(const std::string& variable, bool constant) {
    if (variables.count(variable)) {
        return false;
    }

    if (constant) {
        constants.insert(variable);
    }

    var_length.emplace(variable, length);

    variables.emplace(variable, "");
    return true;
}

bool StringsModule::set(const std::string& variable, const std::string& value) {
    auto it = variables.find(variable);
    if (it == variables.end()) {
        return false;
    }

    if (constants.count(variable)) {
        std::cout << "You cannot assign to constant string";
        std::cout << std::endl;
        abort();
    }

    if (value.size() > var_length[variable]) {
        std::cout << "You should pass string of length <= ";
        std::cout << var_length[variable] << std::endl;
        abort();
    }

    it->second = value;
    return true;
}

std::string& StringsModule::get(const std::string& variable) {
    auto it = variables.find(variable);
    if (it != variables.end()) {
        return it->second;
    }

    std::cerr << "Could not find string variable called";
    std::cerr << "(\"" + variable + "\"). I am sorry." << std::endl;
    abort();
}

bool StringsModule::has(const std::string& variable) {
    return variables.count(variable);
}

void StringsModule::set_length(int n) {
    length = n;
}

StringExpr StringsModule::get_strexpr(const std::string& variable) {
    return {[this, variable]() {
        return get(variable);
    }};
}
