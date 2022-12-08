#include "driver.hh"
#include "parser.hh"

Driver::Driver() 
    : location_debug(false)
    , trace_parsing(false)
    , trace_scanning(false)
    , scanner(*this)
    , parser(scanner, *this) 
{}

int Driver::parse(const std::string& f) {
    file = f;
    location.initialize(&file);
    scan_begin();
    parser.set_debug_level(trace_parsing);
    int res = parser();
    scan_end();
    return res;
}

void Driver::scan_begin() {
    scanner.set_debug(trace_scanning);
    if (file.empty () || file == "-") {
    
    } else {
        stream.open(file);
        scanner.yyrestart(&stream);
    }
}

void Driver::process_if_blocks() {
    auto clear = [&]() {
        conditions_for_if_blocks.clear();
        if_blocks.clear();
    };

    auto process_block = [&](size_t i) {
        auto& if_block = if_blocks[i];
        for (auto& f : if_block) {
            f();
        }

        clear();
    };

    size_t n = conditions_for_if_blocks.size();
    for (size_t i = 0; i < n; ++i) {
        bool condition = conditions_for_if_blocks[i]();
        if (!condition) {
            continue;
        }

        process_block(i);
        return;
    }

    if (n != if_blocks.size()) {
        assert(if_blocks.size() > 1);
        process_block(if_blocks.size() - 1);
        return;
    }

    clear();
}

std::function<bool()> Driver::get_eq_comparison(IntExpr lhs, IntExpr rhs) {
    return [lhs, rhs]() {
        return lhs() == rhs();
    };
}

std::function<bool()> Driver::get_ls_comparison(IntExpr lhs, IntExpr rhs) {
    return [lhs, rhs]() {
        return lhs() < rhs();
    };
}

void Driver::print(const std::string& variable) {
    statement_queue.push_back([variable, this]() {
        if (integers.has(variable)) {
            std::cout << integers.get(variable) << std::endl;
            return;
        } 
        
        if (strings.has(variable)) {
            std::cout << strings.get(variable) << std::endl;
            return;
        }

        std::cerr << "Could not find variable called";
        std::cerr <<  "(\"" + variable + "\"). I am sorry." << std::endl;
        abort();
    });
}

void Driver::assign_variable(const std::string& variable, IntExpr expression) {
    statement_queue.push_back([expression, variable, this]() {
        integers.get(variable) = expression();
    });
}

void Driver::assign_variable(const std::string& variable, StringExpr expression) {
    statement_queue.push_back([expression, variable, this]() {
        strings.get(variable) = expression();
    });
}

void Driver::assert_program_label(const std::string& label) {
    if (label == program_label) {
        return;
    }

    std::cerr << "Expected label \"" << program_label;
    std::cerr << "\"" << std::endl;
    abort();
}

void Driver::set_program_label(const std::string& label) {
    program_label = label;
}

void Driver::scan_end() {
    stream.close();
}
