#include <iostream>
#include <filesystem>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <string>
#include <array>
#include <fstream>
#include <sstream>

namespace fs = std::filesystem;

std::string exec(std::string cmd) {
    static const int max_buffer_size = 128;
    std::array<char, max_buffer_size> buffer;
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd.data(), "r"), pclose);
    if (!pipe) {
        throw std::runtime_error("popen() failed!");
    }

    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    return result;
}

std::string read_file(std::string path) {
    std::ifstream index;
    index.open(path);

    std::stringstream ss;
    ss << index.rdbuf();
    return ss.str();
}

void crop(std::string& s) {
    while (!s.empty() && s.back() == '\n') {
        s.pop_back();
    }
}
int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cout << "./testing <interpreter_path> <tests_path>" << std::endl;
        return 1;
    }

    std::string interpreter_path = argv[1];
    std::string path = argv[2];
    std::string tests_path = path + "/tests/";
    std::string answers_path = path + "/answers/";

    for (auto& test : fs::directory_iterator(tests_path)) {
        std::string test_path = test.path();
        std::string test_filename = test.path().filename();

        std::string answer = read_file(answers_path + test_filename);
        std::string output = exec("./" + interpreter_path + " " + test_path);

        crop(answer);
        crop(output);

        std::cout << "[" << test_filename << "] ";
        if (answer == output) {
            std::cout << "OK" << std::endl;
            continue;
        }
        std::cout << "Failed" << std::endl;
        std::cout << "      output: \"" << output << "\"" << std::endl;
        std::cout << "      answer: \"" << answer << "\"" << std::endl;
    }

    return 0;
}