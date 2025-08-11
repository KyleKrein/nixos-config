{
  custom,
  lib,
  jq,
  deploy-rs,
  ...
}:
custom.writeCppScriptBin {
  name = "deploy-rs-online";
  code = ''
    #include <string>
    #include <vector>
    #include <print>
    #include <format>
    #include <cstdlib>
    #include <cstdio>
    #include <memory>
    #include <stdexcept>
    #include <sstream>
    #include <algorithm>

    constexpr auto RED    = "\033[0;31m";
    constexpr auto GREEN  = "\033[0;32m";
    constexpr auto YELLOW = "\033[0;33m";
    constexpr auto NC     = "\033[0m";

    std::string execCmd(const std::string& cmd) {
        std::array<char, 4096> buffer{};
        std::string result;
        FILE* pipe = popen(cmd.c_str(), "r");
        if (!pipe) throw std::runtime_error("popen() failed");
        while (fgets(buffer.data(), buffer.size(), pipe)) {
            result += buffer.data();
        }
        pclose(pipe);
        if (!result.empty() && result.back() == '\n') result.pop_back();
        return result;
    }

    bool runCmd(const std::string& cmd) {
        return std::system(cmd.c_str()) == 0;
    }

    int main(int argc, char** argv) {
        std::string flakePath = ".";
        std::vector<std::string> deployArgs;

        if (argc > 1) {
            flakePath = argv[1];
        }

        // Collect args after "--"
        for (int i = 2; i < argc; ++i) {
            deployArgs.emplace_back(argv[i]);
        }

        bool skipChecksSet = false;
        for (auto& arg : deployArgs) {
            if (arg == "--skip-checks" || arg == "-s") {
                skipChecksSet = true;
                break;
            }
        }
        if (!skipChecksSet) {
            deployArgs.push_back("-s");
        }

        if (!skipChecksSet) {
            std::println("Running nix flake check on {}", flakePath);
            if (!runCmd(std::format("nix flake check {}", flakePath))) {
                std::println("{}Flake check failed! Aborting deployment.{}", RED, NC);
                return 1;
            }
        }

        std::string nodes = execCmd(std::format(
            "nix eval --json {}#deploy.nodes | {} -r 'keys[]'",
            flakePath,
            "${lib.getExe jq}"
        ));
        std::istringstream iss(nodes);
        std::vector<std::string> nodeList;
        for (std::string node; std::getline(iss, node); ) {
            nodeList.push_back(node);
        }

        std::vector<std::string> results;

        for (auto& node : nodeList) {
            std::string host = execCmd(std::format(
                "nix eval --raw {}#deploy.nodes.{}.hostname",
                flakePath, node
            ));

            std::print("Checking {} ({})... ", node, host);
            if (runCmd(std::format("ssh -o ConnectTimeout=3 -o BatchMode=yes {} true", host))) {
                std::println("{}ONLINE ✅{} — deploying", GREEN, NC);
                std::string deployCmd = std::format("{} {}#{}",
                    "${lib.getExe deploy-rs}",
                    flakePath,
                    node
                );
                for (auto& arg : deployArgs) {
                    deployCmd += " " + arg;
                }
                if (runCmd(deployCmd)) {
                    results.push_back(std::format("{}: {}OK{}", node, GREEN, NC));
                } else {
                    results.push_back(std::format("{}: {}DEPLOY ERROR{}", node, RED, NC));
                }
            } else {
                std::println("{}OFFLINE ❌{} — skipping", RED, NC);
                results.push_back(std::format("{}: {}OFFLINE{}", node, YELLOW, NC));
            }
        }

        std::println("\n===== Deployment summary =====");
        for (auto& r : results) {
            std::println("{}", r);
        }
    }
  '';
}
