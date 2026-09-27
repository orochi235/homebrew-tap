class Slopboard < Formula
  desc "Wall for AI-generated renders that forgets them unless you pin one"
  homepage "https://michaelbaker.tech/slopboard/"
  url "https://github.com/orochi235/slopboard/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b17b9dd2ce06505f29a2bf47c0401b8901ef672e9d520db870c54d9e2acd034d"
  license "MIT"
  head "https://github.com/orochi235/slopboard.git", branch: "main"

  depends_on :macos
  depends_on "node"

  def install
    libexec.install Dir["*"]
    cd libexec do
      system "npm", "ci", "--no-audit", "--no-fund"
    end
    # Through opt, not the Cellar: wall writes this path into its LaunchAgents
    # and wire into Claude's settings, and the Cellar path dies on upgrade.
    %w[slop wall wire].each do |cmd|
      (bin/cmd).write_env_script opt_libexec/"bin"/cmd, SLOPBOARD_HOME: opt_libexec
    end
  end

  def caveats
    <<~EOS
      Start the wall (daemon on :8787, page on :5183) as LaunchAgents:
        wall install
      Then open http://localhost:5183 on the monitor it lives on.

      Point the Claude Code agents on this machine at it:
        wire

      HTML pages and 3D models are shot with Google Chrome, and video
      needs ffmpeg:
        brew install ffmpeg
    EOS
  end

  test do
    (testpath/"probe").mkpath
    cd testpath/"probe" do
      assert_equal "probe", shell_output("#{bin}/slop --print-zone").strip
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
