class Kouhai < Formula
  desc "Ledger of what Claude Code sessions owe you: questions and pending instructions"
  homepage "https://github.com/orochi235/kouhai"
  # The release asset, not the tag's archive: it carries the page prebuilt.
  url "https://github.com/orochi235/kouhai/releases/download/v0.3.0/kouhai-0.3.0.tar.gz"
  sha256 "8d9748cbd9350cc0851168ea48a6d0749e09596597e960862037273c8ff98c66"
  license "MIT"
  head "https://github.com/orochi235/kouhai.git", branch: "main"

  depends_on :macos
  depends_on "node"

  def install
    libexec.install Dir["*"], ".claude-plugin"
    (var/"log/kouhai").mkpath
    (bin/"kouhai").write_env_script libexec/"bin/kouhai", PATH: "#{formula_opt_bin("node")}:$PATH"
  end

  service do
    run [formula_opt_bin("node")/"node", "--disable-warning=ExperimentalWarning",
         opt_libexec/"src/cli.ts", "daemon"]
    keep_alive true
    log_path var/"log/kouhai/daemon.log"
    error_log_path var/"log/kouhai/daemon.log"
  end

  def caveats
    <<~EOS
      Start the daemon, which serves the page on http://localhost:8771:
        brew services start kouhai

      Then, once per Claude config directory:
        claude plugin marketplace add orochi235/kouhai
        claude plugin install kouhai@kouhai

      The ledger lives in ~/.kouhai (KOUHAI_HOME moves it).
    EOS
  end

  test do
    ENV["KOUHAI_HOME"] = testpath/".kouhai"
    assert_match "a ledger of what Claude sessions owe you", shell_output("#{bin}/kouhai help 2>&1")
    assert_match "nothing", shell_output("#{bin}/kouhai ls all")
    assert_path_exists libexec/"outlets/web/dist/index.html"
  end
end
