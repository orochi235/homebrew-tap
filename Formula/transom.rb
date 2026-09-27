class Transom < Formula
  desc "Wall for AI-generated renders that forgets them unless you pin one"
  homepage "https://michaelbaker.tech/transom/"
  url "https://github.com/orochi235/transom/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "94eb6e39b90d5cba05e2844ed4dbf9149902ca2efc7f87d3d7252bdbde4d8123"
  license "MIT"
  head "https://github.com/orochi235/transom.git", branch: "main"

  depends_on :macos
  depends_on "node"

  def install
    libexec.install Dir["*"]
    cd libexec do
      system "npm", "ci", "--no-audit", "--no-fund"
    end
    # Through opt, not the Cellar: transom writes this path into its LaunchAgents
    # and into Claude's settings, and the Cellar path dies on upgrade.
    (bin/"transom").write_env_script opt_libexec/"bin/transom", TRANSOM_HOME: opt_libexec
  end

  def caveats
    <<~EOS
      Start the wall (daemon on :8787, page on :7750) as LaunchAgents:
        transom install
      Then open http://localhost:7750 on the monitor it lives on.

      Point the Claude Code agents on this machine at it:
        transom wire

      HTML pages and 3D models are shot with Google Chrome, and video
      needs ffmpeg:
        brew install ffmpeg
    EOS
  end

  test do
    (testpath/"probe").mkpath
    cd testpath/"probe" do
      assert_equal "probe", shell_output("#{bin}/transom zone").strip
    end

    # Not the daemon: the test sandbox denies its file watcher. The runner loader
    # because the keg is read-only here and the default writes a temp config into it.
    cd libexec do
      system "node_modules/.bin/vite", "build", "--configLoader", "runner", "--logLevel", "warn",
             "--outDir", testpath/"dist", "--emptyOutDir"
    end
    assert_path_exists testpath/"dist/index.html"
  end
end
